/**
 * HTTP 请求连接池
 * 基于鸿蒙 @ohos.net.http，实现并发限制、请求队列、重试与 Keep-Alive，保证高可用与高性能
 * 参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/remote-communication-rcp
 */

import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type {
  HttpPoolConfig,
  HttpRequestOverrides,
  PendingTask,
  HttpPoolRequestOptions
} from './HttpPoolTypes';

const TAG = 'HttpConnectionPool';
const DOMAIN = 0x0000;

interface HeaderObject {
  Connection?: string;
  'Keep-Alive'?: string;
}

interface HttpPoolConfigInternal {
  maxConcurrent: number;
  connectTimeout: number;
  readTimeout: number;
  retryCount: number;
  retryDelayMs: number;
  keepAlive: boolean;
}

/** 默认连接池配置 */
const DEFAULT_CONFIG: HttpPoolConfigInternal = {
  maxConcurrent: 6,
  connectTimeout: 15000,
  readTimeout: 15000,
  retryCount: 2,
  retryDelayMs: 500,
  keepAlive: true
};

/**
 * HTTP 连接池：限制并发、排队、重试、统一超时与 Keep-Alive
 */
export class HttpConnectionPool {
  private config: HttpPoolConfigInternal;
  private activeCount: number = 0;
  private queue: Array<PendingTask<Object>> = [];

  constructor(config?: HttpPoolConfig) {
    this.config = this.mergeConfig(config);
  }

  private mergeConfig(config?: HttpPoolConfig): HttpPoolConfigInternal {
    let maxConcurrent = DEFAULT_CONFIG.maxConcurrent;
    if (config !== undefined && config.maxConcurrent !== undefined) {
      maxConcurrent = config.maxConcurrent;
    }
    let connectTimeout = DEFAULT_CONFIG.connectTimeout;
    if (config !== undefined && config.connectTimeout !== undefined) {
      connectTimeout = config.connectTimeout;
    }
    let readTimeout = DEFAULT_CONFIG.readTimeout;
    if (config !== undefined && config.readTimeout !== undefined) {
      readTimeout = config.readTimeout;
    }
    let retryCount = DEFAULT_CONFIG.retryCount;
    if (config !== undefined && config.retryCount !== undefined) {
      retryCount = config.retryCount;
    }
    let retryDelayMs = DEFAULT_CONFIG.retryDelayMs;
    if (config !== undefined && config.retryDelayMs !== undefined) {
      retryDelayMs = config.retryDelayMs;
    }
    let keepAlive = DEFAULT_CONFIG.keepAlive;
    if (config !== undefined && config.keepAlive !== undefined) {
      keepAlive = config.keepAlive;
    }
    return {
      maxConcurrent,
      connectTimeout,
      readTimeout,
      retryCount,
      retryDelayMs,
      keepAlive
    };
  }

  /**
   * 发起 JSON 请求，返回解析后的结果；受连接池并发与重试策略控制
   */
  requestJson<T>(url: string, options: HttpPoolRequestOptions, overrides?: HttpRequestOverrides): Promise<T> {
    let task: PendingTask<T> = {
      url,
      options,
      resolve: (value: T) => {},
      reject: (_reason: Error) => {},
      overrides
    };
    let p = new Promise<T>((resolve: (value: T) => void, reject: (reason: Error) => void) => {
      task.resolve = resolve;
      task.reject = reject;
    });
    this.enqueue(task as PendingTask<Object>);
    return p;
  }

  private enqueue(task: PendingTask<Object>): void {
    if (this.activeCount < this.config.maxConcurrent) {
      this.runTask(task);
    } else {
      this.queue.push(task);
    }
  }

  private dequeueNext(): void {
    if (this.queue.length > 0 && this.activeCount < this.config.maxConcurrent) {
      let next = this.queue.shift();
      if (next !== undefined) {
        this.runTask(next);
      }
    }
  }

  private runTask(task: PendingTask<Object>): void {
    this.activeCount++;
    this.executeWithRetry(task)
      .then((result: Object) => {
        task.resolve(result);
        this.onTaskFinished();
      })
      .catch((err: Error) => {
        task.reject(err);
        this.onTaskFinished();
      })
  }

  private onTaskFinished(): void {
    this.activeCount--;
    this.dequeueNext();
  }

  private buildRequestOptions(task: PendingTask<Object>): http.HttpRequestOptions {
    let connectTimeout = this.config.connectTimeout;
    let readTimeout = this.config.readTimeout;
    if (task.overrides !== undefined) {
      if (task.overrides.connectTimeout !== undefined) {
        connectTimeout = task.overrides.connectTimeout;
      }
      if (task.overrides.readTimeout !== undefined) {
        readTimeout = task.overrides.readTimeout;
      }
    }
    let header: HeaderObject | undefined = undefined;
    if (this.config.keepAlive) {
      header = {
        Connection: 'keep-alive',
        'Keep-Alive': 'timeout=30, max=10'
      };
    }
    let method: http.RequestMethod = http.RequestMethod.GET;
    if (task.options.method !== undefined) {
      method = task.options.method;
    }
    let expectDataType: http.HttpDataType | undefined = undefined;
    if (task.options.expectDataType !== undefined) {
      expectDataType = task.options.expectDataType;
    }
    let opts: http.HttpRequestOptions = {
      method,
      header,
      connectTimeout,
      readTimeout
    };
    if (expectDataType !== undefined) {
      opts.expectDataType = expectDataType;
    }
    if (task.options.extraData !== undefined) {
      opts.extraData = task.options.extraData;
    }
    if (task.options.usingCache !== undefined) {
      opts.usingCache = task.options.usingCache;
    }
    if (task.options.priority !== undefined) {
      opts.priority = task.options.priority;
    }
    if (task.options.caPath !== undefined) {
      opts.caPath = task.options.caPath;
    }
    return opts;
  }

  private getRetryCount(task: PendingTask<Object>): number {
    if (task.overrides !== undefined && task.overrides.retryCount !== undefined) {
      return task.overrides.retryCount;
    }
    return this.config.retryCount;
  }

  private executeOne(requestOptions: http.HttpRequestOptions, url: string): Promise<Object> {
    let httpRequest = http.createHttp();
    return httpRequest.request(url, requestOptions)
      .then((response: http.HttpResponse) => {
        httpRequest.destroy();
        let result = response.result;
        return result as Object;
      })
      .catch((err: Error) => {
        httpRequest.destroy();
        throw err;
      });
  }

  private executeWithRetry(task: PendingTask<Object>): Promise<Object> {
    let requestOptions = this.buildRequestOptions(task);
    let maxRetry = this.getRetryCount(task);
    let attempt = 0;

    const tryRequest = (): Promise<Object> => {
      return this.executeOne(requestOptions, task.url)
        .catch((err: Error) => {
          attempt++;
          if (attempt <= maxRetry) {
            let delay = this.config.retryDelayMs * attempt;
            hilog.warn(DOMAIN, TAG, 'request failed, retry %{public}d/%{public}d after %{public}d ms, url=%{public}s',
              attempt, maxRetry, delay, task.url);
            return this.delay(delay).then(() => tryRequest());
          }
          hilog.error(DOMAIN, TAG, 'request failed after retries: %{public}s', JSON.stringify(err));
          throw err;
        });
    };
    return tryRequest();
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(resolve, ms);
    });
  }

  /** 当前活跃请求数 */
  getActiveCount(): number {
    return this.activeCount;
  }

  /** 当前排队数量 */
  getQueueLength(): number {
    return this.queue.length;
  }

  /** 更新池配置（仅影响后续请求） */
  updateConfig(config: HttpPoolConfig): void {
    if (config.maxConcurrent !== undefined) {
      this.config.maxConcurrent = config.maxConcurrent;
    }
    if (config.connectTimeout !== undefined) {
      this.config.connectTimeout = config.connectTimeout;
    }
    if (config.readTimeout !== undefined) {
      this.config.readTimeout = config.readTimeout;
    }
    if (config.retryCount !== undefined) {
      this.config.retryCount = config.retryCount;
    }
    if (config.retryDelayMs !== undefined) {
      this.config.retryDelayMs = config.retryDelayMs;
    }
    if (config.keepAlive !== undefined) {
      this.config.keepAlive = config.keepAlive;
    }
  }
}

/** 全局默认连接池实例，建议应用内复用 */
let defaultPool: HttpConnectionPool | null = null;

/**
 * 获取或创建默认连接池（单例）
 */
export function getDefaultHttpPool(config?: HttpPoolConfig): HttpConnectionPool {
  if (defaultPool === null) {
    defaultPool = new HttpConnectionPool(config);
  } else if (config !== undefined) {
    defaultPool.updateConfig(config);
  }
  return defaultPool;
}

/**
 * 使用默认连接池发起 JSON 请求（便捷方法）
 */
export function requestJson<T>(
  url: string,
  options: HttpPoolRequestOptions,
  overrides?: HttpRequestOverrides
): Promise<T> {
  return getDefaultHttpPool().requestJson<T>(url, options, overrides);
}
