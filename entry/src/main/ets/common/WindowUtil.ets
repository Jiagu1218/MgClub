import { window } from '@kit.ArkUI';

export interface MainWindowInfo {
  avoidSystem?: window.AvoidArea;
  avoidCutout?: window.AvoidArea;
  avoidSystemGesture?: window.AvoidArea;
  avoidKeyboard?: window.AvoidArea;
  avoidNavigationIndicator?: window.AvoidArea;
}

export class WindowUtil {
  private static instance: WindowUtil = new WindowUtil();

  mainWindow?: window.Window;
  mainWindowInfo: MainWindowInfo = {};

  static getInstance(): WindowUtil {
    return WindowUtil.instance;
  }

  setMainWindow(win: window.Window): void {
    this.mainWindow = win;
  }

  async initAvoidArea(): Promise<void> {
    if (this.mainWindow === undefined) {
      return;
    }

    // 获取系统状态栏区域
    let systemArea: window.AvoidArea = await this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    this.mainWindowInfo.avoidSystem = systemArea;

    // 获取底部导航指示条区域
    let navArea: window.AvoidArea =
      await this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    this.mainWindowInfo.avoidNavigationIndicator = navArea;
  }

  // 监听避让区域变化时的回调
  public onAvoidAreaChange: (avoidOptions: window.AvoidAreaOptions) => void =
    (avoidOptions: window.AvoidAreaOptions) => {
      if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        this.mainWindowInfo.avoidSystem = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_CUTOUT) {
        this.mainWindowInfo.avoidCutout = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
        this.mainWindowInfo.avoidSystemGesture = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_KEYBOARD) {
        this.mainWindowInfo.avoidKeyboard = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        this.mainWindowInfo.avoidNavigationIndicator = avoidOptions.area;
      }
    };
}

export const windowUtil: WindowUtil = WindowUtil.getInstance();
