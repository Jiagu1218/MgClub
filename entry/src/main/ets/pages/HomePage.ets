import type { PostBriefItemData } from '../common/network';
import { PostListViewModel } from '../viewmodel/PostListViewModel';
import { HomePostItem } from '../components/HomePostItem';
import type { PostDetailRouteParams } from './PostDetailPage';
import { levelStore } from '../common/LevelStore';


@ComponentV2
export struct HomePage {
  private pathStack: NavPathStack = new NavPathStack();
  @Local vm: PostListViewModel = new PostListViewModel();

  aboutToAppear(): void {
    // 通过 queryNavigationInfo 查询当前 Navigation 的 NavPathStack
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }

    // 首页首次出现时初始化等级列表，用于后续“我的”页面展示等级信息
    levelStore.init();

    this.vm.loadFirstPage();
  }

  @Builder
  private buildHeader(): void {
    Column() {
      Row() {
        Blank()
          .width(24)

        Text('MgClub')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)

        Blank()

        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
      }
      .height(44)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16 })
    }
    .backgroundColor(0xFFFFFFFF)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  private buildSkeletonItem(): void {
    Column() {
      // 标题占位
      Rect()
        .width('70%')
        .height(16)
        .backgroundColor(0xFFE5E5E5)
        .borderRadius(4)
        .margin({ bottom: 8 })

      // 摘要占位
      Rect()
        .width('90%')
        .height(12)
        .backgroundColor(0xFFEAEAEA)
        .borderRadius(4)
        .margin({ bottom: 4 })

      Rect()
        .width('60%')
        .height(12)
        .backgroundColor(0xFFEAEAEA)
        .borderRadius(4)
        .margin({ bottom: 12 })

      // 底部信息行占位
      Row() {
        Rect()
          .width(60)
          .height(10)
          .backgroundColor(0xFFEAEAEA)
          .borderRadius(4)

        Blank()

        Rect()
          .width(40)
          .height(10)
          .backgroundColor(0xFFEAEAEA)
          .borderRadius(4)
          .margin({ right: 8 })

        Rect()
          .width(40)
          .height(10)
          .backgroundColor(0xFFEAEAEA)
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(10)
    .height(96)
  }

  build() {
    Column() {
      this.buildHeader()

      Refresh({ refreshing: this.vm.isRefreshing }) {
        if (this.vm.firstLoadError !== '') {
          Column() {
            Text(this.vm.firstLoadError)
              .fontSize(14)
              .opacity(0.8)
              .margin({ bottom: 12 })
            Button('重新加载', { type: ButtonType.Capsule })
              .onClick(() => {
                this.vm.loadFirstPage();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.vm.postList.length === 0 && this.vm.isRefreshing) {
          // 首次加载骨架屏
          List({ space: 8 }) {
            ForEach([0, 1, 2, 3], (index: number) => {
              ListItem() {
                this.buildSkeletonItem()
              }
              .margin({ left: 12, right: 12, top: index === 0 ? 4 : 0, bottom: 4 })
            })
          }
          .width('100%')
          .height('100%')
          .cachedCount({ minCount: 4, maxCount: 8 }, false)
          .edgeEffect(EdgeEffect.None)
        } else {
          List({ space: 8 }) {
            Repeat(this.vm.postList)
              .key((item: PostBriefItemData): string => {
                return String(item.id);
              })
              .virtualScroll()
              .each((obj: RepeatItem<PostBriefItemData>) => {
                ListItem() {
                  HomePostItem({
                    item: obj.item,
                    onOpen: (id: number): void => {
                      let param: PostDetailRouteParams = { id: id };
                      this.pathStack.pushPathByName('PostDetailPage', param);
                    }
                  })
                    .reuse({
                      reuseId: (): string => {
                        return 'home_post_item';
                      }
                    })
                }
                .margin({ left: 12, right: 12, top: 4, bottom: 4 })
              })
          }
          .width('100%')
          .height('100%')
          .cachedCount({ minCount: 6, maxCount: 12 }, false)
          .onReachEnd(() => {
            if (this.vm.hasMore && !this.vm.isLoadingMore) {
              this.vm.loadMore();
            }
          })
          .edgeEffect(EdgeEffect.None)
        }
      }
      .onRefreshing(() => {
        this.vm.loadFirstPage();
      })
      .margin({ top: 8 })
      .layoutWeight(1)
    }
    .backgroundColor(0xF5F5F5)
    .width('100%')
    .height(LayoutPolicy.matchParent)
  }
}

