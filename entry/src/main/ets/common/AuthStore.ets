import preferences from '@ohos.data.preferences';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { Context } from '@kit.AbilityKit';

const DOMAIN_AUTH = 0x1001;
const PREFERENCES_NAME: string = 'mgclub_auth';
const KEY_TOKEN: string = 'token';
const KEY_UID: string = 'uid';

export class AuthStore {
  private static instance: AuthStore = new AuthStore();

  private token: string = '';
  private uid: number = 0;
  private initialized: boolean = false;
  private context?: Context;

  static getInstance(): AuthStore {
    return AuthStore.instance;
  }

  getToken(): string {
    return this.token;
  }

  getUid(): number {
    return this.uid;
  }

  isLoggedIn(): boolean {
    return this.token !== '' && this.uid > 0;
  }

  async init(context: Context): Promise<void> {
    if (this.initialized) {
      return;
    }
    try {
      this.context = context;
      let pref: preferences.Preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      let storedToken: string = pref.getSync(KEY_TOKEN, '') as string;
      let storedUid: number = pref.getSync(KEY_UID, 0) as number;
      this.token = storedToken;
      this.uid = storedUid;
      this.initialized = true;
    } catch (err) {
      hilog.error(DOMAIN_AUTH, 'AuthStore', 'init failed: %{public}s', JSON.stringify(err));
    }
  }

  async saveLogin(token: string, uid: number): Promise<void> {
    this.token = token;
    this.uid = uid;
    if (this.context === undefined) {
      return;
    }
    try {
      let pref: preferences.Preferences = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      await pref.put(KEY_TOKEN, token);
      await pref.put(KEY_UID, uid);
      await pref.flush();
    } catch (err) {
      hilog.error(DOMAIN_AUTH, 'AuthStore', 'saveLogin failed: %{public}s', JSON.stringify(err));
    }
  }

  async saveToken(token: string): Promise<void> {
    this.token = token;
    if (this.context === undefined) {
      return;
    }
    try {
      let pref: preferences.Preferences = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      await pref.put(KEY_TOKEN, token);
      await pref.flush();
    } catch (err) {
      hilog.error(DOMAIN_AUTH, 'AuthStore', 'saveToken failed: %{public}s', JSON.stringify(err));
    }
  }
}

export const authStore: AuthStore = AuthStore.getInstance();

