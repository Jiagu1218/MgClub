import type { PostDetailData, PostCommentItemData } from '../common/network';
import { PostDetailViewModel } from '../viewmodel/PostDetailViewModel';

@ComponentV2
export struct PostDetailPage {
  @Local vm: PostDetailViewModel = new PostDetailViewModel();

  aboutToAppear(): void {
    // 从路由参数获取帖子 ID
    let uiContext = this.getUIContext();
    let router = uiContext.getRouter();
    let params = router.getParams();
    if (params !== undefined && params['id'] !== undefined) {
      let idValue: number = Number(params['id']);
      this.vm.init(idValue);
      this.vm.loadDetail();
      this.vm.loadFirstCommentsPage();
    }
  }

  @Builder
  private buildImageGrid(pictures: Array<string>): void {
    if (pictures.length === 0) {
      return;
    }
    let i: number;
    Column() {
      for (i = 0; i < pictures.length; i++) {
        Image(pictures[i])
          .width('100%')
          .aspectRatio(1.2)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .backgroundColor(0xFFE5E5E5)
          .margin({ bottom: 8 });
      }
    }
    .margin({ top: 8, bottom: 8 });
  }

  @Builder
  private buildCommentItem(item: PostCommentItemData): void {
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
          .margin({ top: 2, bottom: 4 });

        Text(item.content)
          .fontSize(14)
          .lineHeight(20)
          .opacity(0.95);
      }
      .margin({ left: 12 });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(Color.White);
  }

  build() {
    let detail: PostDetailData | null = this.vm.detail;
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回', { type: ButtonType.Capsule })
          .onClick(() => {
            let router = this.getUIContext().getRouter();
            router.back();
          })
          .height(32)
          .margin({ left: 12 });

        Text('帖子详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 });

        Blank();
      }
      .height(52)
      .alignItems(VerticalAlign.Center);

      if (this.vm.loading && detail === null) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .opacity(0.8);
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (this.vm.errorMessage !== '' && detail === null) {
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
      } else if (detail !== null) {
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

            Text(detail.content)
              .fontSize(15)
              .lineHeight(22)
              .opacity(0.95)
              .margin({ bottom: 10 });

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
              let i: number;
              for (i = 0; i < this.vm.comments.length; i++) {
                this.buildCommentItem(this.vm.comments[i]);
              }

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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xFFF7F7F7);
  }
}

