import { windowUtil } from '../common/WindowUtil';
import { getAuthCode, postAuthValidate, postAuthValidateLogin } from '../common/network';
import { authStore } from '../common/AuthStore';
import type {
  AuthCodeData,
  AuthValidateData,
  AuthValidateBody,
  AuthValidateLoginBody,
  AuthLoginData
} from '../common/network';

/** 登录页路由参数，当前无必传字段 */
export interface LoginPageRouteParams {
}

@ComponentV2
struct LoginPage {
  private pathStack: NavPathStack = new NavPathStack();
  // 0: 账号密码登录  1: 验证码登录
  @Local loginMode: number = 0;
  @Local account: string = '';
  @Local password: string = '';
  @Local countdown: number = 0;
  @Local tipMessage: string = '';
  // 最新一次获取到的验证码 publicKey（显示给用户，注意大小写不能被改变）
  @Local authCodePublicKey: string = '';
  // 最新一次获取到的 privateKey（仅用于校验接口 body.key，不展示）
  @Local authCodePrivateKey: string = '';
  // 剩余有效时间（秒）
  @Local authExpireSeconds: number = 0;
  private countdownTimer: number = -1;

  aboutToDisappear(): void {
    if (this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
    }
  }

  aboutToAppear(): void {
    // 进入页面时，从 Navigation 查询 NavPathStack，用于登录成功后返回上一页
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }
  }

  @Builder
  private buildModeSwitch(): void {
    Row() {
      Text('账号密码登录')
        .fontSize(15)
        .fontWeight(this.loginMode === 0 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.loginMode === 0 ? 0xFF007AFF : 0xFF666666)
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .onClick(() => {
          this.loginMode = 0;
          this.tipMessage = '';
        })

      Text('验证码登录')
        .fontSize(15)
        .fontWeight(this.loginMode === 1 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.loginMode === 1 ? 0xFF007AFF : 0xFF666666)
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .onClick(() => {
          this.loginMode = 1;
          this.tipMessage = '';
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 24 });
  }

  @Builder
  private buildAccountForm(): void {
    Column() {
      TextInput({ text: this.account, placeholder: '请输入账号/手机号/邮箱' })
        .width('100%')
        .height(44)
        .fontSize(15)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.account = value;
        })

      TextInput({ text: this.password, placeholder: '请输入密码' })
        .width('100%')
        .height(44)
        .fontSize(15)
        .type(InputType.Password)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.password = value;
        })

      Button('登录')
        .width('100%')
        .height(44)
        .fontSize(16)
        .margin({ top: 24 })
        .onClick(() => {
          if (this.account.trim().length === 0) {
            this.tipMessage = '请输入账号';
            return;
          }
          if (this.password.trim().length === 0) {
            this.tipMessage = '请输入密码';
            return;
          }
          this.tipMessage = '账号密码登录功能需对接后端接口';
        })
    }
    .width('100%')
    .padding({ left: 24, right: 24 });
  }

  @Builder
  private buildVerifyForm(): void {
    Column() {
      // 验证码展示卡片，可一键复制
      Column() {
        Text('请复制下方验证码，在指定位置发送后再回来点击“验证并登录”')
          .fontSize(13)
          .fontColor(0xFF666666)
          .margin({ bottom: 12 })

        Text(this.authCodePublicKey.length > 0 ? this.authCodePublicKey : '点击下方按钮获取验证码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(0xFF111111)
          .textAlign(TextAlign.Center)
          .margin({ top: 4, bottom: 4 })
          .copyOption(CopyOptions.LocalDevice)
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 16, right: 16 })
      .backgroundColor(Color.White)
      .borderRadius(12)

      Button(this.countdown > 0 ? this.countdown + 's' : '获取验证码')
        .width('100%')
        .height(44)
        .fontSize(16)
        .margin({ top: 16 })
        .enabled(this.countdown === 0)
        .onClick(() => {
          this.tipMessage = '正在获取验证码...';
          getAuthCode()
            .then((data: AuthCodeData) => {
              // 直接使用后端返回的 publicKey/privateKey，不做大小写转换
              this.authCodePublicKey = data.publicKey;
              this.authCodePrivateKey = data.privateKey;
              // 接口约定有效期 300s，这里也用该值做倒计时
              this.authExpireSeconds = data.expireSeconds;
              this.countdown = this.authExpireSeconds;

              if (this.countdownTimer >= 0) {
                clearInterval(this.countdownTimer);
              }
              this.countdownTimer = setInterval(() => {
                this.countdown = this.countdown - 1;
                if (this.countdown <= 0 && this.countdownTimer >= 0) {
                  clearInterval(this.countdownTimer);
                  this.countdownTimer = -1;
                }
              }, 1000);

              this.tipMessage = '请在 300 秒内在指定位置发送此验证码，然后返回应用点击“验证并登录”。';
            })
            .catch((error: Error) => {
              this.tipMessage = '获取验证码失败：' + error.message;
            });
        })

      Button('验证并登录')
        .width('100%')
        .height(44)
        .fontSize(16)
        .margin({ top: 24 })
        .onClick(() => {
          if (this.authCodePublicKey.length === 0 || this.authCodePrivateKey.length === 0) {
            this.tipMessage = '请先点击“获取验证码”，并在对应位置发送验证码后再验证。';
            return;
          }
          this.tipMessage = '正在校验验证码...';

          // 按文档要求：code 使用获取验证码得到的 publicKey，key 使用 privateKey，均保持原始大小写
          let body: AuthValidateBody = {
            code: this.authCodePublicKey,
            key: this.authCodePrivateKey
          };

          postAuthValidate(body)
            .then((data: AuthValidateData) => {
              if (!data.validated) {
                this.getUIContext().showAlertDialog({
                  title: '验证失败',
                  message: '验证码校验失败，请确认已在指定位置正确发送验证码后重试。'
                });
                this.tipMessage = '验证码校验失败，请重试。';
                return;
              }

              // 验证通过后，按文档要求调用 /auth/validate-login 获取 token
              if (
                data.site === undefined ||
                data.uid === undefined ||
                data.platformUid === undefined ||
                data.auth === undefined
              ) {
                this.getUIContext().showAlertDialog({
                  title: '数据异常',
                  message: '验证码校验返回数据不完整，无法继续登录流程。'
                });
                this.tipMessage = '验证码校验返回数据不完整，无法继续登录。';
                return;
              }

              let loginBody: AuthValidateLoginBody = {
                // code、key 与校验请求保持一致
                code: this.authCodePublicKey,
                key: this.authCodePrivateKey,
                site: data.site,
                uid: data.uid,
                platformUid: data.platformUid,
                auth: data.auth
              };

              postAuthValidateLogin(loginBody)
                .then((loginData: AuthLoginData) => {
                  // 登录成功：写入全局登录态与 Preferences（EntryAbility 中已初始化 Context）
                  let uidNum: number = loginData.uid;
                  authStore.saveLogin(loginData.token, uidNum);
                  // 返回上一页（我的 Tab），触发 ProfilePage.aboutToAppear 重新加载用户信息
                  this.pathStack.pop();
                  this.tipMessage = '登录成功，uid=' + String(uidNum);
                })
                .catch((error: Error) => {
                  this.getUIContext().showAlertDialog({
                    title: '登录失败',
                    message: '获取登录 token 失败：' + error.message
                  });
                  this.tipMessage = '获取登录 token 失败：' + error.message;
                });
            })
            .catch((error: Error) => {
              this.getUIContext().showAlertDialog({
                title: '请求出错',
                message: '验证码校验接口调用失败：' + error.message
              });
              this.tipMessage = '验证码校验接口调用失败：' + error.message;
            });
        })
    }
    .width('100%')
    .padding({ left: 24, right: 24 });
  }

  build() {
    NavDestination() {
      Column() {
        this.buildModeSwitch()

        if (this.loginMode === 0) {
          this.buildAccountForm()
        } else {
          this.buildVerifyForm()
        }

        if (this.tipMessage.length > 0) {
          Text(this.tipMessage)
            .fontSize(13)
            .fontColor(0xFFFF3B30)
            .margin({ top: 16 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 32 })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(0xFFF5F5F5)
    }
    .title('登录')
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
    .padding({
      top: windowUtil.mainWindowInfo.avoidSystem !== undefined ?
        windowUtil.mainWindowInfo.avoidSystem.topRect.height + 'px' : '0px',
      bottom: windowUtil.mainWindowInfo.avoidNavigationIndicator !== undefined ?
        windowUtil.mainWindowInfo.avoidNavigationIndicator.bottomRect.height + 'px' : '0px'
    })
  }
}

@Builder
export function LoginPageBuilder(): void {
  LoginPage();
}
