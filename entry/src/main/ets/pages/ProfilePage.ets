import type { LoginPageRouteParams } from './LoginPage';
import type { PostUserItemData, UserBriefData, PostBriefItemData } from '../common/network';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';

@ComponentV2
export struct ProfilePage {
  private pathStack: NavPathStack = new NavPathStack();
  @Local vm: ProfileViewModel = new ProfileViewModel();

  aboutToAppear(): void {
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }
    this.vm.init();
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      if (!this.vm.hasLogin) {
        Button('登录')
          .fontSize(16)
          .margin({ top: 8 })
          .onClick(() => {
            let param: LoginPageRouteParams = {};
            this.pathStack.pushPathByName('LoginPage', param);
          })
      } else {
        if (this.vm.loading) {
          Text('正在加载用户信息...')
            .fontSize(14)
            .margin({ top: 16 })
        } else if (this.vm.errorMessage !== '') {
          Text(this.vm.errorMessage)
            .fontSize(14)
            .fontColor(0xFFFF3B30)
            .margin({ top: 16 })
        } else if (this.vm.userInfo !== undefined) {
          // 个人信息卡片（不滚动版本，保证编译通过和布局稳定）
          Column() {
            if (this.vm.userInfo.avatar !== '') {
              Image(this.vm.userInfo.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor(0xFFE0E0E0)
            }

            Text(this.vm.userInfo.nickname)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 12 })

            Text('UID: ' + String(this.vm.userInfo.uid))
              .fontSize(14)
              .fontColor(0xFF666666)
              .margin({ top: 2 })

            Column() {
              if (this.vm.currentLevelName !== '') {
                Text('等级：' + this.vm.currentLevelName)
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 10 })
              }

              if (this.vm.userInfo.exp !== undefined) {
                Text('经验：' + String(this.vm.userInfo.exp))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.vm.userInfo.contribution !== undefined) {
                Text('贡献：' + String(this.vm.userInfo.contribution))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.vm.userInfo.role !== undefined) {
                Text('角色：' + String(this.vm.userInfo.role))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.vm.userInfo.sex !== undefined) {
                Text('性别：' + (this.vm.userInfo.sex === 0 ? '女' : (this.vm.userInfo.sex === 1 ? '男' : '未知')))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.vm.userInfo.birthday !== undefined && this.vm.userInfo.birthday > 0) {
                Text('生日：' + String(this.vm.userInfo.birthday))
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 4 })
              }

              if (this.vm.userInfo.signature !== '') {
                Text(this.vm.userInfo.signature)
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

          // 信息卡片下方：我的动态 / 关注 / 粉丝 / 收藏 Tab
          if (this.vm.dataCount !== undefined) {
            if (this.vm.listLoading) {
              Text('列表加载中...')
                .fontSize(14)
                .margin({ top: 16 });
            } else if (this.vm.listError !== '') {
              Text(this.vm.listError)
                .fontSize(14)
                .fontColor(0xFFFF3B30)
                .margin({ top: 16 });
            } else {
              // Tabs 区域占据剩余高度，内部列表高度自适应
              Column() {
                Tabs() {
                  TabContent() {
                    List() {
                      ForEach(this.vm.posts, (item: PostUserItemData) => {
                        ListItem() {
                          buildProfilePostItem(item);
                        }
                      }, (item: PostUserItemData) => String(item.id));
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('动态 ' + String(this.vm.dataCount.postCount))

                  TabContent() {
                    List() {
                      ForEach(this.vm.followList, (item: UserBriefData) => {
                        ListItem() {
                          buildProfileUserBriefItem(item);
                        }
                      }, (item: UserBriefData) => String(item.uid));
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('关注 ' + String(this.vm.dataCount.followCount))

                  TabContent() {
                    List() {
                      ForEach(this.vm.fansList, (item: UserBriefData) => {
                        ListItem() {
                          buildProfileUserBriefItem(item);
                        }
                      }, (item: UserBriefData) => String(item.uid));
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('粉丝 ' + String(this.vm.dataCount.fansCount))

                  TabContent() {
                    List() {
                      ForEach(this.vm.favoriteList, (item: PostBriefItemData) => {
                        ListItem() {
                          buildProfileFavoriteItem(item);
                        }
                      }, (item: PostBriefItemData) => String(item.id));
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('收藏 ' + String(this.vm.dataCount.favoriteCount))
                }
                .width('100%')
              }
              .margin({ top: 16 })
              .layoutWeight(1)
            }
          }
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

@Builder
export function buildProfilePostItem(item: PostUserItemData) {
  Column() {
    Text(item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium);
    Text(item.summary)
      .fontSize(13)
      .fontColor(0xFF666666)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ top: 4 });
    Text(item.createdAt)
      .fontSize(11)
      .fontColor(0xFF999999)
      .margin({ top: 6 });
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

@Builder
export function buildProfileUserBriefItem(item: UserBriefData) {
  Row() {
    if (item.avatar !== '') {
      Image(item.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(0xFFE0E0E0);
    }
    Column() {
      Text(item.nickname)
        .fontSize(15)
        .fontWeight(FontWeight.Medium);
    }
    .margin({ left: 12 });
    Blank();
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

@Builder
export function buildProfileFavoriteItem(item: PostBriefItemData) {
  Row() {
    if (item.pictures.length > 0) {
      Image(item.pictures[0])
        .width(64)
        .height(64)
        .borderRadius(8)
        .backgroundColor(0xFFE0E0E0);
    }
    Column() {
      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium);
      Text(item.summary)
        .fontSize(12)
        .fontColor(0xFF666666)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 });
      Text(item.createdAt)
        .fontSize(11)
        .fontColor(0xFF999999)
        .margin({ top: 6 });
    }
    .margin({ left: 12 });
    Blank();
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

// ProfilePage 内部使用的 Tab 内容 Builder，实现为函数而不是组件方法，避免 ArkUI 结构限制。
