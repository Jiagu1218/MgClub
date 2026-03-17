import type { PostDetailData, PostCommentItemData, ReplySubItemData } from '../common/network';
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

  /** 帖子详情主体：标题、正文、评论 */
  @Builder
  buildDetailSection(): void {
    Scroll() {
      Column() {
        Text(this.vm.detail!.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12, bottom: 8 });

        Row() {
          Text(this.vm.detail!.author.nickname)
            .fontSize(13)
            .opacity(0.9);

          Text(' · ')
            .fontSize(13)
            .opacity(0.6);

          Text(this.vm.detail!.createdAt)
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

        this.buildImageGrid(this.vm.detail!.pictures);

        Row() {
          Text('👍 ' + this.vm.detail!.likeCount)
            .fontSize(13)
            .opacity(0.9)
            .margin({ right: 16 });

          Text('💬 ' + this.vm.detail!.replyCount)
            .fontSize(13)
            .opacity(0.9)
            .margin({ right: 16 });

          Text('👁 ' + this.vm.detail!.readings)
            .fontSize(13)
            .opacity(0.9);
        }
        .margin({ bottom: 16 });

        Row() {
          Text('评论')
            .fontSize(16)
            .fontWeight(FontWeight.Medium);
          Blank();
        }
        .margin({ bottom: 8 });

        if (this.vm.commentsTopList.length === 0 && this.vm.commentsList.length === 0 && this.vm.loadingComments) {
          Text('评论加载中...')
            .fontSize(13)
            .opacity(0.7)
            .margin({ bottom: 12 });
        } else if (this.vm.commentsTopList.length === 0 && this.vm.commentsList.length === 0) {
          Text('还没有评论，快来抢沙发吧～')
            .fontSize(13)
            .opacity(0.7)
            .margin({ bottom: 12 });
        } else {
          Column() {
            if (this.vm.commentsTopList.length > 0) {
              Text('置顶')
                .fontSize(12)
                .fontColor(0xFF999999)
                .margin({ top: 8, bottom: 6 });
              ForEach(this.vm.commentsTopList, (comment: PostCommentItemData) => {
                this.buildCommentItem(comment);
              });
              Text('全部评论')
                .fontSize(12)
                .fontColor(0xFF999999)
                .margin({ top: 16, bottom: 8 });
            }
            ForEach(this.vm.commentsList, (comment: PostCommentItemData) => {
              this.buildCommentItem(comment);
            });

            if (this.vm.commentsHasMore) {
              Button(this.vm.loadingComments ? '加载中...' : '加载更多评论', { type: ButtonType.Capsule })
                .margin({ top: 12, bottom: 16 })
                .onClick(() => {
                  this.vm.loadMoreComments();
                })
                .enabled(!this.vm.loadingComments);
            }
          }
          .width('100%')
          .padding({ left: 4, right: 4, top: 4, bottom: 4 })
          .backgroundColor(0xFFF2F2F2)
          .borderRadius(12);
        }
      }
      .padding({ left: 16, right: 16, bottom: 48 });
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
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
  private buildSubReply(sub: ReplySubItemData): void {
    // 子回复视为嵌套的小纸条，使用柔和底色和圆角
    Column() {
      Row() {
        Image(sub.author.avatar)
          .width(28)
          .height(28)
          .borderRadius(14)
          .backgroundColor(0xFFE0E0E0);

        Column() {
          if (sub.mention !== undefined) {
            Row() {
              Text(sub.author.nickname)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF007AFF)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(' 回复 ')
                .fontSize(12)
                .fontColor(0xFF8E8E93);
              Text(sub.mention.author.nickname)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF007AFF)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .width('100%');
          } else {
            Text(sub.author.nickname)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xFF007AFF)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }

          Text(sub.time)
            .fontSize(11)
            .opacity(0.6)
            .margin({ top: 2 });
        }
        .layoutWeight(1)
        .width('100%')
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')

      ForEach(this.vm.parseContentToBlocks(sub.content), (block: PostContentBlock) => {
        if (block.type === 'text') {
          Text(block.text)
            .fontSize(13)
            .lineHeight(20)
            .opacity(0.9)
            .margin({ top: 8 });
        }
      });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, top: 10, bottom: 10, right: 12 })
    .backgroundColor(0xFFFCFAF5)
    .borderRadius(10)
    .border({ width: 0.5, color: 0x11AAAAAA })
    .shadow({
      radius: 6,
      color: 0x08000000,
      offsetX: 0,
      offsetY: 3
    })
    .margin({ top: 6 });
  }

  @Builder
  private buildCommentItem(item: PostCommentItemData): void {
    // 顶层评论卡片：拟物纸质效果
    Column() {
      Row() {
        Image(item.user.avatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor(0xFFD8D8D8);

        Column() {
          Row() {
            Text(item.user.nickname)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            if (item.isTop === true) {
              Text(' 置顶')
                .fontSize(11)
                .fontColor(0xFFFF3B30)
                .margin({ left: 4 });
            }
            if (item.floor !== undefined) {
              Text(' #' + String(item.floor))
                .fontSize(11)
                .opacity(0.6)
                .margin({ left: 2 });
            }
          }

          Row() {
            Text(item.createdAt)
              .fontSize(11)
              .opacity(0.6);
            if (item.likes !== undefined && item.likes > 0) {
              Text(' · 👍 ' + String(item.likes))
                .fontSize(11)
                .opacity(0.6)
                .margin({ left: 4 });
            }
          }
          .margin({ top: 2 });
        }
        .layoutWeight(1)
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')

      Column() {
        ForEach(this.vm.parseContentToBlocks(item.content), (block: PostContentBlock) => {
          if (block.type === 'text') {
            Text(block.text)
              .fontSize(14)
              .lineHeight(20)
              .opacity(0.95)
              .margin({ top: 6 })
              .width('100%');
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
      .width('100%')
      .margin({ top: 8 })
      .alignItems(HorizontalAlign.Start);

      if (item.replies !== undefined && item.replies.length > 0) {
        Column() {
          ForEach(item.replies, (sub: ReplySubItemData) => {
            this.buildSubReply(sub);
          });
        }
        .width('100%')
        .margin({ top: 8 });
      }
    }
    .width('100%')
    .padding({
      left: 14,
      right: 14,
      top: 12,
      bottom: 14
    })
    .backgroundColor(0xFFFCFAF5)
    .borderRadius(14)
    .border({ width: 0.5, color: 0x11AAAAAA })
    .alignItems(HorizontalAlign.Start)
    .shadow({
      radius: 10,
      color: 0x10000000,
      offsetX: 0,
      offsetY: 5
    })
    .margin({ bottom: 14 });
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
          this.buildDetailSection();
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
