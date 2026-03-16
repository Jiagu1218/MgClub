import type {
  UserBriefData,
  PostSearchItemData,
  ContributionRankItemData
} from '../common/network';
import { DiscoverViewModel } from '../viewmodel/DiscoverViewModel';
import type { PostDetailRouteParams } from './PostDetailPage';
import { HomePostItem } from '../components/HomePostItem';

@ComponentV2
export struct DiscoverPage {
  private pathStack: NavPathStack = new NavPathStack();
  @Local vm: DiscoverViewModel = new DiscoverViewModel();

  aboutToAppear(): void {
    // 默认加载周榜
    this.vm.loadRank('week');

    // 通过 NavigationInfo 获取 NavPathStack，用于帖子搜索结果跳转详情页
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }
  }

  @Builder
  private buildSearchBar(): void {
    Row() {
      TextInput({ text: this.vm.keyword, placeholder: '搜索用户 / 帖子' })
        .width('80%')
        .height(36)
        .fontSize(14)
        .backgroundColor(Color.White)
        .borderRadius(18)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.vm.keyword = value;
        })

      Button('搜索')
        .height(36)
        .margin({ left: 8, right: 12 })
        .onClick(() => {
          if (this.vm.currentTab === 0) {
            this.vm.searchUserList();
          } else {
            this.vm.searchPostList();
          }
        })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 12, right: 12 })
    .backgroundColor(0xF5F5F5)
  }

  @Builder
  private buildTabBar(): void {
    Row() {
      this.buildTabItem('用户', 0);
      this.buildTabItem('帖子', 1);
      this.buildTabItem('贡献榜', 2);
    }
    .width('100%')
    .height(40)
    .backgroundColor(Color.White)
  }

  @Builder
  private buildTabItem(title: string, index: number): void {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(this.vm.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
        .opacity(this.vm.currentTab === index ? 1 : 0.6)

      if (this.vm.currentTab === index) {
        Rect()
          .width(24)
          .height(2)
          .backgroundColor(0xFF007AFF)
          .borderRadius(1)
          .margin({ top: 4 })
      } else {
        Blank()
          .height(6)
      }
    }
    .width('33%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.vm.currentTab = index;
      if (index === 2 && !this.vm.isLoadingRank) {
        this.vm.loadRank('week');
      }
    })
  }

  @Builder
  private buildUserItem(user: UserBriefData): void {
    Row() {
      Image(user.avatar)
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(0xFFD8D8D8)

      Column() {
        Text(user.nickname)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('UID: ' + user.uid)
          .fontSize(12)
          .opacity(0.7)
      }
      .margin({ left: 12 })

      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  private buildPostItem(item: PostSearchItemData): void {
    HomePostItem({
      item: {
        id: item.id,
        title: item.title,
        summary: item.summary,
        author: item.author,
        likeCount: 0,
        replyCount: 0,
        favoriteCount: 0,
        createdAt: item.createdAt,
        pictures: [],
        readings: 0
      }
    })
      .onClick(() => {
        let param: PostDetailRouteParams = { id: item.id };
        this.pathStack.pushPathByName('PostDetailPage', param);
      })
  }

  @Builder
  private buildRankItem(item: ContributionRankItemData, index: number): void {
    Row() {
      Text(String(index + 1))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width(32)
        .textAlign(TextAlign.Center)

      Image(item.avatar)
        .width(32)
        .height(32)
        .borderRadius(16)
        .backgroundColor(0xFFD8D8D8)

      Column() {
        Text(item.nickname)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('贡献值 ' + String(item.score))
          .fontSize(12)
          .opacity(0.7)
      }
      .margin({ left: 12 })

      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  private buildContent(): void {
    // 用户 Tab
    if (this.vm.currentTab === 0) {
      if (this.vm.firstUserError !== '') {
        Column() {
          Text(this.vm.firstUserError)
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 12 })
          Button('重试', { type: ButtonType.Capsule })
            .onClick(() => {
              this.vm.searchUserList();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 6 }) {
          LazyForEach(this.vm.userDataSource,
            (item: UserBriefData, index: number) => {
              ListItem() {
                this.buildUserItem(item);
              }
              .margin({ left: 12, right: 12, top: index === 0 ? 4 : 0, bottom: 4 })
            },
            (item: UserBriefData) => {
              return '' + item.uid;
            }
          )
        }
        .width('100%')
        .height('100%')
        .cachedCount({ minCount: 10, maxCount: 20 }, false)
      }
    } else if (this.vm.currentTab === 1) {
      // 帖子 Tab
      if (this.vm.firstPostError !== '') {
        Column() {
          Text(this.vm.firstPostError)
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 12 })
          Button('重试', { type: ButtonType.Capsule })
            .onClick(() => {
              this.vm.searchPostList();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 6 }) {
          LazyForEach(this.vm.postDataSource,
            (item: PostSearchItemData, index: number) => {
              ListItem() {
                this.buildPostItem(item);
              }
              .margin({ left: 12, right: 12, top: index === 0 ? 4 : 0, bottom: 4 })
            },
            (item: PostSearchItemData) => {
              return '' + item.id;
            }
          )
        }
        .width('100%')
        .height('100%')
        .cachedCount({ minCount: 10, maxCount: 20 }, false)
      }
    } else {
      // 贡献榜 Tab
      if (this.vm.rankError !== '') {
        Column() {
          Text(this.vm.rankError)
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 12 })
          Button('重试', { type: ButtonType.Capsule })
            .onClick(() => {
              this.vm.loadRank('week');
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 6 }) {
          LazyForEach(this.vm.rankDataSource,
            (item: ContributionRankItemData, index: number) => {
              ListItem() {
                this.buildRankItem(item, index);
              }
              .margin({ left: 12, right: 12, top: index === 0 ? 4 : 0, bottom: 4 })
            },
            (item: ContributionRankItemData) => {
              return '' + item.uid;
            }
          )
        }
        .width('100%')
        .height('100%')
        .cachedCount({ minCount: 20, maxCount: 40 }, false)
      }
    }
  }

  build() {
    Column() {
      this.buildSearchBar()
      this.buildTabBar()

      Column() {
        this.buildContent()
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xF5F5F5)
  }
}

