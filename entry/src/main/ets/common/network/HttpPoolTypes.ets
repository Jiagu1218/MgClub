/**
 * HTTP 连接池相关类型定义
 * 基于 @ohos.net.http，用于高可用、高性能请求封装
 */

import { http } from '@kit.NetworkKit';

/**
 * 连接池配置
 */
export interface HttpPoolConfig {
  /** 最大并发请求数，默认 6 */
  maxConcurrent?: number;
  /** 连接超时（毫秒），默认 15000 */
  connectTimeout?: number;
  /** 读取超时（毫秒），默认 15000 */
  readTimeout?: number;
  /** 失败重试次数，默认 2 */
  retryCount?: number;
  /** 重试基础延迟（毫秒），默认 500，指数退避 */
  retryDelayMs?: number;
  /** 是否启用 Keep-Alive 请求头以复用底层连接，默认 true */
  keepAlive?: boolean;
}

/**
 * 单次请求可选覆盖项（覆盖池默认配置）
 */
export interface HttpRequestOverrides {
  connectTimeout?: number;
  readTimeout?: number;
  retryCount?: number;
}

/**
 * 排队任务项（内部使用）
 */
export interface PendingTask<T> {
  url: string;
  options: HttpPoolRequestOptions;
  resolve: (value: T) => void;
  reject: (reason: Error) => void;
  overrides: HttpRequestOverrides | undefined;
}

/**
 * 池内请求选项：与 @ohos.net.http 的 HttpRequestOptions 对齐，便于透传
 */
export interface HttpPoolRequestOptions {
  method?: http.RequestMethod;
  extraData?: string | Object;
  expectDataType?: http.HttpDataType;
  usingCache?: boolean;
  priority?: number;
  readTimeout?: number;
  connectTimeout?: number;
  caPath?: string;
}
