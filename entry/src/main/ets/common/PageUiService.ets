import { windowUtil } from './WindowUtil';

export class PageUiService {
  async applyDarkOverlaySystemBar(): Promise<void> {
    let mainWindow = windowUtil.mainWindow;
    if (mainWindow === undefined) {
      return;
    }
    try {
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: '#FFFFFFFF',
        navigationBarColor: '#00000000',
        navigationBarContentColor: '#FFFFFFFF'
      });
    } catch (_err) {
    }
  }

  async restoreDefaultSystemBar(): Promise<void> {
    let mainWindow = windowUtil.mainWindow;
    if (mainWindow === undefined) {
      return;
    }
    try {
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: '#FF000000',
        navigationBarColor: '#00000000',
        navigationBarContentColor: '#FF000000'
      });
    } catch (_err) {
    }
  }
}

export const pageUiService: PageUiService = new PageUiService();
