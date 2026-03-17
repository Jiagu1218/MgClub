import type {
  UserBriefData,
  UserDataCountData,
  PostUserItemData,
  UserBriefData as FollowUserBriefData,
  PostBriefItemData,
  PagedListData
} from '../common/network';
import {
  getUserUserInfo,
  getUserDataCount,
  getPostUserList,
  getFollowList,
  getFansList,
  getPostFavoriteList
} from '../common/network';
import { levelStore } from '../common/LevelStore';
import { GenericBasicDataSource } from '../viewmodel/GenericBasicDataSource';
import { HomePostItem } from '../components/HomePostItem';
import { FollowUserCard } from '../components/FollowUserCard';

@ObservedV2
class UserProfileViewModel {
  @Trace loading: boolean = false;
  @Trace errorMessage: string = '';
  @Trace userInfo?: UserBriefData;
  @Trace dataCount?: UserDataCountData;
  @Trace levelText: string = '';
  @Trace postsDataSource: GenericBasicDataSource<PostUserItemData> =
    new GenericBasicDataSource<PostUserItemData>();
  @Trace followDataSource: GenericBasicDataSource<FollowUserBriefData> =
    new GenericBasicDataSource<FollowUserBriefData>();
  @Trace fansDataSource: GenericBasicDataSource<FollowUserBriefData> =
    new GenericBasicDataSource<FollowUserBriefData>();
  @Trace favoriteDataSource: GenericBasicDataSource<PostBriefItemData> =
    new GenericBasicDataSource<PostBriefItemData>();
  @Trace listLoading: boolean = false;
  @Trace listError: string = '';

  async init(uid: number): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    try {
      let info: UserBriefData = await getUserUserInfo(uid);
      this.userInfo = info;

      if (info.level > 0) {
        let levels = levelStore.getLevels();
        let i: number;
        for (i = 0; i < levels.length; i++) {
          let lv = levels[i];
          if (lv.level === info.level) {
            this.levelText = 'Lv' + String(lv.level) + ' ' + lv.name;
            break;
          }
        }
      }

      let count: UserDataCountData = await getUserDataCount(uid);
      this.dataCount = count;

      this.listLoading = true;
      this.listError = '';
      try {
        let results: [
          PagedListData<PostUserItemData>,
          PagedListData<FollowUserBriefData>,
          PagedListData<FollowUserBriefData>,
          PagedListData<PostBriefItemData>
        ] = await Promise.all([
          getPostUserList(uid, 1, 10),
          getFollowList(uid, 1, 10),
          getFansList(uid, 1, 10),
          getPostFavoriteList(uid, 1, 10)
        ]);
        this.postsDataSource.setData(results[0].list);
        this.followDataSource.setData(results[1].list);
        this.fansDataSource.setData(results[2].list);
        this.favoriteDataSource.setData(results[3].list);
      } catch (e) {
        this.listError = e instanceof Error ? e.message : String(e);
      } finally {
        this.listLoading = false;
      }
    } catch (e) {
      this.errorMessage = e instanceof Error ? e.message : String(e);
    } finally {
      this.loading = false;
    }
  }
}

interface UserProfileRouteParams {
  uid?: number;
}

@ComponentV2
export struct UserProfilePage {
  @Local vm: UserProfileViewModel = new UserProfileViewModel();

  build() {
    NavDestination() {
      Column() {
        if (this.vm.loading) {
          Text('正在加载用户信息...')
            .fontSize(14)
            .margin({ top: 32 });
        } else if (this.vm.errorMessage !== '') {
          Text(this.vm.errorMessage)
            .fontSize(14)
            .fontColor(0xFFFF3B30)
            .margin({ top: 32 });
        } else if (this.vm.userInfo !== undefined) {
          Column() {
            // 顶部用户信息卡片
            Column() {
              if (this.vm.userInfo.avatar !== '') {
                Image(this.vm.userInfo.avatar)
                  .width(80)
                  .height(80)
                  .borderRadius(40)
                  .backgroundColor(0xFFE0E0E0);
              }

              Text(this.vm.userInfo.nickname)
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 12 });

              Text('UID: ' + String(this.vm.userInfo.uid))
                .fontSize(14)
                .fontColor(0xFF666666)
                .margin({ top: 2 });

              if (this.vm.levelText !== '') {
                Text('等级：' + this.vm.levelText)
                  .fontSize(14)
                  .fontColor(0xFF666666)
                  .margin({ top: 8 });
              }

              if (this.vm.dataCount !== undefined) {
                Row() {
                  Text('关注 ' + String(this.vm.dataCount.followCount))
                    .fontSize(13)
                    .fontColor(0xFF666666);

                  Text('  粉丝 ' + String(this.vm.dataCount.fansCount))
                    .fontSize(13)
                    .fontColor(0xFF666666)
                    .margin({ left: 8 });

                  Text('  动态 ' + String(this.vm.dataCount.postCount))
                    .fontSize(13)
                    .fontColor(0xFF666666)
                    .margin({ left: 8 });

                  Text('  收藏 ' + String(this.vm.dataCount.favoriteCount))
                    .fontSize(13)
                    .fontColor(0xFF666666)
                    .margin({ left: 8 });
                }
                .margin({ top: 10 });
              }
            }
            .width('86%')
            .padding({ top: 20, bottom: 20, left: 24, right: 24 })
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)

            // 下方 Tabs：动态 / 关注 / 粉丝 / 收藏
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
                                  author: {
                                    uid: this.vm.userInfo!.uid,
                                    nickname: this.vm.userInfo!.nickname,
                                    avatar: this.vm.userInfo!.avatar,
                                    level: this.vm.userInfo!.level
                                  },
                                  likeCount: item.likeCount,
                                  replyCount: item.replyCount,
                                  favoriteCount: 0,
                                  createdAt: item.createdAt,
                                  pictures: [],
                                  readings: item.readings !== undefined ? item.readings : 0
                                },
                                isTop: false
                              })
                            }
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
                          (item: FollowUserBriefData) => {
                            ListItem() {
                              FollowUserCard({ item: item });
                            }
                          },
                          (item: FollowUserBriefData) => {
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
                          (item: FollowUserBriefData) => {
                            ListItem() {
                              FollowUserCard({ item: item });
                            }
                          },
                          (item: FollowUserBriefData) => {
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
      .backgroundColor(0xFFF5F5F5);
    }
    .title('用户资料')
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
    .onReady((context: NavDestinationContext) => {
      let params: UserProfileRouteParams = context.pathInfo.param as UserProfileRouteParams;
      if (params === undefined || params.uid === undefined) {
        return;
      }
      this.vm.init(params.uid);
    });
  }
}

@Builder
export function UserProfilePageBuilder(): void {
  UserProfilePage();
}

