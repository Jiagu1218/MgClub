import type { ChatHistoryItemData } from '../common/network';
import { authStore } from '../common/AuthStore';
import { windowUtil } from '../common/WindowUtil';
import { ChatDetailViewModel } from '../viewmodel/ChatDetailViewModel';

export interface ChatDetailRouteParams {
  uid: number;
  targetName?: string;
  targetAvatar?: string;
}

/** 简单去除 HTML 标签，仅做纯文本展示 */
function stripHtml(html: string): string {
  if (html.length === 0) {
    return '';
  }
  return html.replace(/<[^>]+>/g, '');
}

@ComponentV2
struct ChatDetailPage {
  @Local vm: ChatDetailViewModel = new ChatDetailViewModel();

  @Builder
  private buildMessageItem(msg: ChatHistoryItemData): void {
    Column() {
      Row() {
        if (authStore.getUid() !== msg.from) {
          if (this.vm.targetAvatar.length > 0) {
            Image(this.vm.targetAvatar)
              .width(32)
              .height(32)
              .borderRadius(16)
              .backgroundColor(0xFFE8E8E8)
              .margin({ right: 8 });
          }
          Column() {
            Text(this.vm.targetName)
              .fontSize(12)
              .fontColor(0xFF666666)
              .margin({ bottom: 4 });
            Column() {
              Text(stripHtml(msg.content))
                .fontSize(15)
                .fontColor(0xFF333333)
                .maxLines(20)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(msg.time)
                .fontSize(11)
                .fontColor(0xFF999999)
                .margin({ top: 4 });
            }
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor(0xFFE8E8E8)
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
            .constraintSize({ maxWidth: '80%' });
          }
          .alignItems(HorizontalAlign.Start);
          Blank();
        } else {
          Blank();
          Row() {
            Column() {
              Text(this.vm.myNickname)
                .fontSize(12)
                .fontColor(0xFF666666)
                .margin({ bottom: 4 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Column() {
                Text(stripHtml(msg.content))
                  .fontSize(15)
                  .fontColor(0xFFFFFFFF)
                  .maxLines(20)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(msg.time)
                  .fontSize(11)
                  .fontColor(0xFFE8F5E9)
                  .margin({ top: 4 });
              }
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(0xFF34C759)
              .borderRadius(12)
              .alignItems(HorizontalAlign.Start)
              .constraintSize({ maxWidth: '80%' });
            }
            .alignItems(HorizontalAlign.End)
            .constraintSize({ maxWidth: '85%' });
            if (this.vm.myAvatar.length > 0) {
              Image(this.vm.myAvatar)
                .width(32)
                .height(32)
                .borderRadius(16)
                .backgroundColor(0xFFE8E8E8)
                .margin({ left: 8 });
            }
          }
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.End);
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .alignItems(VerticalAlign.Top)
      .justifyContent(authStore.getUid() === msg.from ? FlexAlign.End : FlexAlign.Start);
    }
    .width('100%');
  }

  @Builder
  private buildTargetUserBar(): void {
    Row() {
      if (this.vm.targetAvatar.length > 0) {
        Image(this.vm.targetAvatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor(0xFFE8E8E8);
      }
      Text(this.vm.targetName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ left: this.vm.targetAvatar.length > 0 ? 12 : 0 });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildTargetUserBar();

        if (this.vm.loading && this.vm.messages.length === 0) {
          Column() {
            Text('加载中...')
              .fontSize(14)
              .opacity(0.8);
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else if (this.vm.errorMessage !== '' && this.vm.messages.length === 0) {
          Column() {
            Text(this.vm.errorMessage)
              .fontSize(14)
              .opacity(0.8)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 12 });
            Button('重试', { type: ButtonType.Capsule })
              .onClick(() => {
                this.vm.loadHistory();
              });
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else if (this.vm.messages.length === 0) {
          Column() {
            Text('暂无消息')
              .fontSize(14)
              .opacity(0.7);
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else {
          List() {
            ForEach(this.vm.messages, (msg: ChatHistoryItemData) => {
              ListItem() {
                this.buildMessageItem(msg);
              }
            });
          }
          .layoutWeight(1)
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({ bottom: 16 });
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0xFFF5F5F5);
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
      let params = context.pathInfo.param as ChatDetailRouteParams;
      if (params === undefined || params.uid === undefined) {
        return;
      }
      this.vm.init(params.uid, params.targetName, params.targetAvatar);
      this.vm.loadMyInfo();
      this.vm.loadHistory();
    })
    .title(this.vm.targetName);
  }
}

@Builder
export function ChatDetailPageBuilder(): void {
  ChatDetailPage();
}
