import type { LoginPageRouteParams } from './LoginPage';
import { authStore } from '../common/AuthStore';
import { getUserInfo } from '../common/network';
import type { UserInfoData, LevelItemData } from '../common/network';
import { levelStore } from '../common/LevelStore';

@ComponentV2
export struct ProfilePage {
  private pathStack: NavPathStack = new NavPathStack();
  @Local hasLogin: boolean = false;
  @Local loading: boolean = false;
  @Local userInfo?: UserInfoData;
  @Local errorMessage: string = '';
  @Local currentLevelName: string = '';

  aboutToAppear(): void {
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }

    // 根据当前登录态决定是否拉取用户信息
    this.hasLogin = authStore.isLoggedIn();
    if (this.hasLogin) {
      this.loadUserInfo();
    }
  }

  private loadUserInfo(): void {
    this.loading = true;
    this.errorMessage = '';
    getUserInfo()
      .then((data: UserInfoData) => {
        this.userInfo = data;
        // 计算等级显示：根据经验值在 levelStore 中查找
        if (data.exp !== undefined) {
          let lv: LevelItemData | undefined = levelStore.getLevelByScore(data.exp as number);
          if (lv !== undefined) {
            this.currentLevelName = lv.name;
          } else {
            this.currentLevelName = '';
          }
        } else {
          this.currentLevelName = '';
        }
        this.loading = false;
      })
      .catch((error: Error) => {
        this.errorMessage = '获取用户信息失败：' + error.message;
        this.loading = false;
      });
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      if (!this.hasLogin) {
        Button('登录')
          .fontSize(16)
          .margin({ top: 8 })
          .onClick(() => {
            let param: LoginPageRouteParams = {};
            this.pathStack.pushPathByName('LoginPage', param);
          })
      } else {
        if (this.loading) {
          Text('正在加载用户信息...')
            .fontSize(14)
            .margin({ top: 16 })
        } else if (this.errorMessage !== '') {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(0xFFFF3B30)
            .margin({ top: 16 })
        } else if (this.userInfo !== undefined) {
          // 个人信息卡片
          Column() {
            // 头像
            if (this.userInfo.avatar !== '') {
              Image(this.userInfo.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor(0xFFE0E0E0)
            }

            // 昵称 + UID
            Text(this.userInfo.nickname)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 12 })

            Text('UID: ' + String(this.userInfo.uid))
              .fontSize(14)
              .fontColor(0xFF666666)
              .margin({ top: 2 })

            // 资料区块
            Column() {
              if (this.currentLevelName !== '') {
                Text('等级：' + this.currentLevelName)
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 10 })
              }

              if (this.userInfo.exp !== undefined) {
                Text('经验：' + String(this.userInfo.exp))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.userInfo.contribution !== undefined) {
                Text('贡献：' + String(this.userInfo.contribution))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.userInfo.role !== undefined) {
                Text('角色：' + String(this.userInfo.role))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.userInfo.sex !== undefined) {
                Text('性别：' + (this.userInfo.sex === 0 ? '女' : (this.userInfo.sex === 1 ? '男' : '未知')))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.userInfo.birthday !== undefined && this.userInfo.birthday > 0) {
                Text('生日：' + String(this.userInfo.birthday))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.userInfo.signature !== '') {
                Text(this.userInfo.signature)
                  .fontSize(14)
                  .fontColor(0xFF999999)
                  .margin({ top: 8 })
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('86%')
          .padding({ top: 20, bottom: 20, left: 24, right: 24 })
          .backgroundColor(0xFFFFFFFF)
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 72 })
    .backgroundColor(0xFFF5F5F5)
  }
}

