import { ArkTSUtils, LinkedList } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";

export interface SessionPoolConfig {
  maxSessions: number;
  coreSessions: number;
  lookPrefix: string;
  sessionConfiguration?: rcp.SessionConfiguration;
}

export class SessionPool {
  private lock: ArkTSUtils.locks.AsyncLock;
  private sessionPool: LinkedList<rcp.Session>;
  private waitingQueue: LinkedList<(session: rcp.Session) => void>;
  private maxSessions: number;
  private coreSessions: number;
  private activeSessions: number;
  private sessionConfiguration?: rcp.SessionConfiguration;

  constructor(config?: SessionPoolConfig) {
    this.sessionPool = new LinkedList<rcp.Session>();
    this.waitingQueue = new LinkedList<(session: rcp.Session) => void>();
    this.maxSessions = 16;
    this.coreSessions = 4;
    this.activeSessions = 0;
    let lockName: string = "rcp_session_pool_lock";
    if (config !== undefined && config.lookPrefix !== undefined) {
      lockName = config.lookPrefix + "_activeSessions_lock";
    }
    this.lock = ArkTSUtils.locks.AsyncLock.request(lockName);
    if (config !== undefined && config.sessionConfiguration !== undefined) {
      this.sessionConfiguration = config.sessionConfiguration;
    }
    this.init(config);
  }

  private init(config?: SessionPoolConfig): void {
    if (config !== undefined) {
      if (config.maxSessions !== undefined) {
        let max: number = config.maxSessions;
        if (max > 16) {
          max = 16;
        }
        this.maxSessions = max;
      }
      if (config.coreSessions !== undefined) {
        let core: number = config.coreSessions;
        if (core > this.maxSessions) {
          core = this.maxSessions;
        }
        this.coreSessions = core;
      }
    }
    let i: number;
    for (i = 0; i < this.coreSessions; i++) {
      let session: rcp.Session = this.createSession();
      this.sessionPool.add(session);
      this.activeSessions++;
    }
  }

  public acquire(timeout: number = 30000): Promise<rcp.Session> {
    return new Promise<rcp.Session>((resolve: (s: rcp.Session) => void, reject: (e: Error) => void) => {
      let timer: number = -1;
      if (timeout > 0) {
        timer = setTimeout(() => {
          this.waitingQueue.remove(resolve);
          reject(new Error("获取请求超时"));
        }, timeout);
      }
      if (this.sessionPool.length === 0 && this.activeSessions < this.maxSessions) {
        try {
          let session: rcp.Session = this.createSession();
          this.lock.lockAsync(() => {
            this.activeSessions++;
          });
          if (timer > -1) {
            clearTimeout(timer);
          }
          resolve(session);
        } catch (e) {
           //超出session个数限制16个
          if (1007900994 == e?.['code']) {
            this.waitingQueue.add(resolve)
          }else {
            timer > -1 && clearTimeout(timer)
            reject(e)
          }
        }
      } else if (this.sessionPool.length === 0) {
        this.waitingQueue.add(resolve);
      } else {
        if (timer > -1) {
          clearTimeout(timer);
        }
        let s: rcp.Session = this.sessionPool.removeFirst();
        resolve(s);
      }
    });
  }

  public async release(session: rcp.Session): Promise<void> {
    if (this.waitingQueue.length === 0) {
      if (this.sessionPool.length < this.coreSessions) {
        this.sessionPool.add(session);
      } else {
        session.close();
        await this.lock.lockAsync(() => {
          this.activeSessions--;
        });
      }
    } else {
      let nextRequest = this.waitingQueue.removeFirst();
      nextRequest(session);
    }
  }

  private createSession(): rcp.Session {
    if (this.sessionConfiguration !== undefined) {
      return rcp.createSession(this.sessionConfiguration);
    }
    return rcp.createSession();
  }

  public destroy(): void {
    this.sessionPool.forEach((session: rcp.Session) => {
      session.close();
    });
    this.sessionPool.clear();
    this.waitingQueue.clear();
    this.activeSessions = 0;
  }
}