import type { LoginPageRouteParams } from './LoginPage';
import type { PostDetailRouteParams } from './PostDetailPage';
import type { PostUserItemData, UserBriefData, PostBriefItemData } from '../common/network';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';
import { HomePostItem } from '../components/HomePostItem';
import { FollowUserCard } from '../components/FollowUserCard';

interface UserProfileRouteParams {
  uid: number;
}

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
              // Tabs 区域占据剩余高度，内部列表高度自适应（使用公共列表 item 组件）
              Column() {
                Tabs() {
                  TabContent() {
                    List() {
                      LazyForEach(this.vm.postsDataSource,
                        (item: PostUserItemData) => {
                          ListItem() {
                            HomePostItem({
                              item: {
                                id: item.id,
                                title: item.title,
                                summary: item.summary,
                                author: item.author !== undefined ? item.author : {
                                  uid: this.vm.userInfo !== undefined ? this.vm.userInfo.uid : 0,
                                  nickname: this.vm.userInfo !== undefined ? this.vm.userInfo.nickname : '',
                                  avatar: this.vm.userInfo !== undefined ? this.vm.userInfo.avatar : '',
                                  level: this.vm.userInfo !== undefined ? this.vm.userInfo.level : 0
                                },
                                likeCount: item.likeCount,
                                replyCount: item.replyCount,
                                favoriteCount: 0,
                                createdAt: item.createdAt,
                                pictures: item.pictures !== undefined ? item.pictures : [],
                                readings: item.readings !== undefined ? item.readings : 0
                              },
                              isTop: false
                            });
                          }
                          .onClick(() => {
                            let param: PostDetailRouteParams = { id: item.id };
                            this.pathStack.pushPathByName('PostDetailPage', param);
                          })
                        },
                        (item: PostUserItemData) => {
                          return String(item.id);
                        }
                      )
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('动态 ' + String(this.vm.dataCount.postCount))

                  TabContent() {
                    List() {
                      LazyForEach(this.vm.followDataSource,
                        (item: UserBriefData) => {
                          ListItem() {
                            FollowUserCard({ item: item });
                          }
                          .onClick(() => {
                            let param: UserProfileRouteParams = { uid: item.uid };
                            this.pathStack.pushPathByName('UserProfilePage', param);
                          })
                        },
                        (item: UserBriefData) => {
                          return String(item.uid);
                        }
                      )
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('关注 ' + String(this.vm.dataCount.followCount))

                  TabContent() {
                    List() {
                      LazyForEach(this.vm.fansDataSource,
                        (item: UserBriefData) => {
                          ListItem() {
                            FollowUserCard({ item: item });
                          }
                          .onClick(() => {
                            let param: UserProfileRouteParams = { uid: item.uid };
                            this.pathStack.pushPathByName('UserProfilePage', param);
                          })
                        },
                        (item: UserBriefData) => {
                          return String(item.uid);
                        }
                      )
                    }
                    .width('100%')
                    .height(LayoutPolicy.matchParent)
                  }
                  .tabBar('粉丝 ' + String(this.vm.dataCount.fansCount))

                  TabContent() {
                    List() {
                      LazyForEach(this.vm.favoriteDataSource,
                        (item: PostBriefItemData) => {
                          ListItem() {
                            HomePostItem({ item: item, isTop: false });
                          }
                          .onClick(() => {
                            let param: PostDetailRouteParams = { id: item.id };
                            this.pathStack.pushPathByName('PostDetailPage', param);
                          })
                        },
                        (item: PostBriefItemData) => {
                          return String(item.id);
                        }
                      )
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

// ProfilePage 内部使用的 Tab 内容已通过 PostSimpleList 和 UserSimpleList 抽成通用组件。
