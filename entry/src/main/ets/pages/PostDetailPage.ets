import type { PostDetailData, PostCommentItemData } from '../common/network';
import { PostDetailViewModel, PostContentBlock } from '../viewmodel/PostDetailViewModel';
import { CustomTransition } from '../common/CustomNavigationUtils';
import { windowUtil } from '../common/WindowUtil';

export interface PostDetailRouteParams {
  id?: number | string;
}

@Entry
@ComponentV2
struct PostDetailPage {
  @Local vm: PostDetailViewModel = new PostDetailViewModel();
  // 用于翻页风格动画的位移与缩放
  @Local translateX: string = '0';
  @Local contentScale: number = 1.0;

  aboutToAppear(): void {
    // 注册当前详情页的全局转场动画回调，供 Navigation.customNavContentTransition 调用
    CustomTransition.getInstance().registerNavParam(
      'PostDetailPage',
      (isPush: boolean, isExit: boolean) => {
        // 设置动画起点：横向滑动 + 轻微缩放
        if (isPush) {
          // 详情页作为入场页：从右侧滑入，略缩小
          if (!isExit) {
            this.translateX = '100%';
            this.contentScale = 0.95;
          }
        } else {
          // POP 时，详情页作为离场页：起点为当前正常位置
          if (isExit) {
            this.translateX = '0';
            this.contentScale = 1.0;
          }
        }
      },
      (isPush: boolean, isExit: boolean) => {
        // 设置动画终点
        if (isPush) {
          if (!isExit) {
            // 入场结束：归位并恢复 1.0 缩放
            this.translateX = '0';
            this.contentScale = 1.0;
          }
        } else {
          if (isExit) {
            // 离场结束：滑到右侧并略缩小，营造被翻走的感觉
            this.translateX = '100%';
            this.contentScale = 0.95;
          }
        }
      }
    );
  }

  aboutToDisappear(): void {
    CustomTransition.getInstance().unRegisterNavParam('PostDetailPage');
  }

  @Builder
  private buildImageGrid(pictures: Array<string>): void {
    Column() {
      ForEach(pictures, (url: string) => {
        Image(url)
          .width('100%')
          .aspectRatio(1.2)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .backgroundColor(0xFFE5E5E5)
          .margin({ bottom: 8 });
      })
    }
    .margin({ top: 8, bottom: 8 });
  }

  @Builder
  private buildCommentItem(item: PostCommentItemData): void {
    Column() {
      Row() {
        Image(item.user.avatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor(0xFFD8D8D8);

        Column() {
          Text(item.user.nickname)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(item.createdAt)
            .fontSize(11)
            .opacity(0.6)
            .margin({ top: 2 });
        }
        .margin({ left: 10 });
      }

      Column() {
        ForEach(this.vm.parseContentToBlocks(item.content), (block: PostContentBlock) => {
          if (block.type === 'text') {
            Text(block.text)
              .fontSize(14)
              .lineHeight(20)
              .opacity(0.95)
              .margin({ top: 6 });
          } else if (block.type === 'image') {
            if (block.width !== undefined && block.height !== undefined) {
              Image(block.src)
                .width(block.width)
                .height(block.height)
                .borderRadius(8)
                .backgroundColor(0xFFF3F3F3)
                .margin({ top: 8 });
            } else if (block.width !== undefined) {
              Image(block.src)
                .width(block.width)
                .borderRadius(8)
                .backgroundColor(0xFFF3F3F3)
                .margin({ top: 8 });
            } else if (block.height !== undefined) {
              Image(block.src)
                .height(block.height)
                .borderRadius(8)
                .backgroundColor(0xFFF3F3F3)
                .margin({ top: 8 });
            } else {
              Image(block.src)
                .width('100%')
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
                .backgroundColor(0xFFF3F3F3)
                .margin({ top: 8 });
            }
          }
        })
      }
      .margin({ top: 8 });
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(10);
  }

  @Builder
  private buildDetailSection(detail: PostDetailData): void {
    Scroll() {
      Column() {
        Text(detail.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12, bottom: 8 });

        Row() {
          Text(detail.author.nickname)
            .fontSize(13)
            .opacity(0.9);

          Text(' · ')
            .fontSize(13)
            .opacity(0.6);

          Text(detail.createdAt)
            .fontSize(13)
            .opacity(0.6);

          Blank();
        }
        .margin({ bottom: 10 });

        ForEach(this.vm.contentBlocks, (block: PostContentBlock) => {
          if (block.type === 'text') {
            Text(block.text)
              .fontSize(15)
              .lineHeight(22)
              .opacity(0.95)
              .margin({ bottom: 8 });
          } else if (block.type === 'image') {
            if (block.width !== undefined && block.height !== undefined) {
              Image(block.src)
                .width(block.width)
                .height(block.height)
                .borderRadius(8)
                .backgroundColor(0xFFE5E5E5)
                .margin({ top: 4, bottom: 8 });
            } else if (block.width !== undefined) {
              Image(block.src)
                .width(block.width)
                .borderRadius(8)
                .backgroundColor(0xFFE5E5E5)
                .margin({ top: 4, bottom: 8 });
            } else if (block.height !== undefined) {
              Image(block.src)
                .height(block.height)
                .borderRadius(8)
                .backgroundColor(0xFFE5E5E5)
                .margin({ top: 4, bottom: 8 });
            } else {
              Image(block.src)
                .width('100%')
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
                .backgroundColor(0xFFE5E5E5)
                .margin({ top: 4, bottom: 8 });
            }
          }
        })

        this.buildImageGrid(detail.pictures);

        Row() {
          Text('👍 ' + detail.likeCount)
            .fontSize(13)
            .opacity(0.9)
            .margin({ right: 16 });

          Text('💬 ' + detail.replyCount)
            .fontSize(13)
            .opacity(0.9)
            .margin({ right: 16 });

          Text('👁 ' + detail.readings)
            .fontSize(13)
            .opacity(0.9);
        }
        .margin({ bottom: 16 });

        // 评论标题
        Row() {
          Text('评论')
            .fontSize(16)
            .fontWeight(FontWeight.Medium);
          Blank();
        }
        .margin({ bottom: 8 });

        if (this.vm.comments.length === 0 && this.vm.loadingComments) {
          Text('评论加载中...')
            .fontSize(13)
            .opacity(0.7)
            .margin({ bottom: 12 });
        } else if (this.vm.comments.length === 0) {
          Text('还没有评论，快来抢沙发吧～')
            .fontSize(13)
            .opacity(0.7)
            .margin({ bottom: 12 });
        } else {
          ForEach(this.vm.comments, (comment: PostCommentItemData) => {
            this.buildCommentItem(comment);
          })

          if (this.vm.commentsHasMore) {
            Button(this.vm.loadingComments ? '加载中...' : '加载更多评论', { type: ButtonType.Capsule })
              .margin({ top: 12, bottom: 24 })
              .onClick(() => {
                this.vm.loadMoreComments();
              })
              .enabled(!this.vm.loadingComments);
          }
        }
      }
      .padding({ left: 16, right: 16, bottom: 24 });
    }
    .layoutWeight(1);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.loading && this.vm.detail === null) {
          Column() {
            Text('加载中...')
              .fontSize(14)
              .opacity(0.8);
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else if (this.vm.errorMessage !== '' && this.vm.detail === null) {
          Column() {
            Text(this.vm.errorMessage)
              .fontSize(14)
              .opacity(0.8)
              .margin({ bottom: 12 });
            Button('重试', { type: ButtonType.Capsule })
              .onClick(() => {
                this.vm.loadDetail();
                this.vm.loadFirstCommentsPage();
              });
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else if (this.vm.detail !== null) {
          this.buildDetailSection(this.vm.detail as PostDetailData);
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0xFFF7F7F7);
    }
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
    .padding({
      top: windowUtil.mainWindowInfo.avoidSystem !== undefined ?
        windowUtil.mainWindowInfo.avoidSystem.topRect.height + 'px' : '0px',
      bottom: windowUtil.mainWindowInfo.avoidNavigationIndicator !== undefined ?
        windowUtil.mainWindowInfo.avoidNavigationIndicator.bottomRect.height + 'px' : '0px'
    })
    .onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as PostDetailRouteParams;
      if (params === undefined || params.id === undefined) {
        return;
      }
      let idValue: number = Number(params.id);
      this.vm.init(idValue);
      this.vm.loadDetail();
      this.vm.loadFirstCommentsPage();
    })
    .translate({ x: this.translateX })
    .scale({ x: this.contentScale, y: this.contentScale })
    .title('帖子详情');
  }
}

@Builder
export function PostDetailPageBuilder(): void {
  PostDetailPage();
}

