import { rcp } from "@kit.RemoteCommunicationKit";
import hilog from "@ohos.hilog";
import { SessionPool, SessionPoolConfig } from "./SessionPool";

export interface RcpClientConfig {
  /**
   * 会话池配置
   */
  poolConfig?: SessionPoolConfig;
  /**
   * 获取 Session 的超时时间（毫秒）
   */
  acquireTimeout?: number;
}

export class RcpClient {
  private sessionPool: SessionPool;
  private acquireTimeout: number;
  private requestSessionMap: Map<rcp.Request, rcp.Session>;

  constructor(config?: RcpClientConfig) {
    this.sessionPool = new SessionPool(config !== undefined ? config.poolConfig : undefined);
    this.acquireTimeout = config !== undefined && config.acquireTimeout !== undefined ? config.acquireTimeout : 30000;
    this.requestSessionMap = new Map<rcp.Request, rcp.Session>();
  }

  /**
   * 发送请求并按 content-type 解析结果
   */
  public async request<T>(request: rcp.Request): Promise<T> {
    let session: rcp.Session;
    try {
      session = await this.sessionPool.acquire(this.acquireTimeout);
    } catch (error) {
      hilog.error(0x0000, "RcpClient", "获取 Session 失败: %{public}s", String(error));
      if (error instanceof Error) {
        throw error;
      }
      throw new Error(String(error));
    }

    this.requestSessionMap.set(request, session);
    try {
      let response: rcp.Response = await session.fetch(request);

      // 处理 content-type，兼容数组或单值
      // ArkTS 对索引访问有限制，这里统一转成字符串再解析
      let headerValue: string = "";
      // ArkTS 不允许动态索引，这里只做最简单的字符串转换，
      // 具体的 content-type 获取依赖于 rcp.Response 提供的能力。
      let headersAny: string = String(response.headers);
      headerValue = headersAny;

      let contentType: string = "";
      if (headerValue !== "") {
        let parts: Array<string> = headerValue.split(";");
        if (parts.length > 0) {
          contentType = parts[0].trim();
        }
      }

      if (contentType === "application/json") {
        return response.toJSON() as T;
      }
      if (contentType === "application/octet-stream") {
        return response.body as T;
      }
      if (contentType === "text/plain") {
        return response.toString() as T;
      }

      // 未知 content-type 时按 JSON → 字符串 → 二进制 顺序尝试
      let jsonValue: T = response.toJSON() as T;
      if (jsonValue !== undefined && jsonValue !== null) {
        return jsonValue;
      }
      let textValue: T = response.toString() as T;
      if (textValue !== undefined && textValue !== null) {
        return textValue;
      }
      return response.body as T;
    } catch (error) {
      this.handleRequestError(request, error);
      return Promise.reject(error);
    } finally {
      await this.sessionPool.release(session);
      this.requestSessionMap.delete(request);
    }
  }

  /**
   * 发送请求并返回原始 Response
   */
  public async requestRaw(request: rcp.Request): Promise<rcp.Response> {
    let session: rcp.Session;
    try {
      session = await this.sessionPool.acquire(this.acquireTimeout);
    } catch (error) {
      hilog.error(0x0000, "RcpClient", "获取 Session 失败: %{public}s", String(error));
      if (error instanceof Error) {
        throw error;
      }
      throw new Error(String(error));
    }

    this.requestSessionMap.set(request, session);
    try {
      let response: rcp.Response = await session.fetch(request);
      return response;
    } catch (error) {
      this.handleRequestError(request, error);
      return Promise.reject(error);
    } finally {
      await this.sessionPool.release(session);
      this.requestSessionMap.delete(request);
    }
  }

  /**
   * 取消指定请求
   */
  public cancel(request: rcp.Request): void {
    let session: rcp.Session | undefined = this.requestSessionMap.get(request);
    if (session !== undefined) {
      session.cancel(request);
    }
  }

  /**
   * 关闭并销毁内部 SessionPool
   */
  public destroy(): void {
    this.sessionPool.destroy();
    this.requestSessionMap.clear();
  }

  private handleRequestError(request: rcp.Request, error: Error | object): void {
    let message: string = "";
    if (error instanceof Error) {
      message = error.message;
    } else {
      message = String(error);
    }
    hilog.error(0x0000, "RcpClient", "请求失败，原因: %{public}s", message);
  }
}

