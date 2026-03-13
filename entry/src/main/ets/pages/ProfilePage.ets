import type { LoginPageRouteParams } from './LoginPage';

@ComponentV2
export struct ProfilePage {
  private pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Button('登录')
        .fontSize(16)
        .margin({ top: 24 })
        .onClick(() => {
          let param: LoginPageRouteParams = {};
          this.pathStack.pushPathByName('LoginPage', param);
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

