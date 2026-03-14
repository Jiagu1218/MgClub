import type { ChatListItemData } from '../common/network';
import type { ChatDetailRouteParams } from './ChatDetailPage';
import { MessageListViewModel } from '../viewmodel/MessageListViewModel';
import { windowUtil } from '../common/WindowUtil';

@ComponentV2
export struct MessagePage {
  private pathStack: NavPathStack = new NavPathStack();
  @Local vm: MessageListViewModel = new MessageListViewModel();

  aboutToAppear(): void {
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo !== undefined) {
      this.pathStack = navigationInfo.pathStack;
    }
    this.vm.loadChatList();
  }

  @Builder
  private buildChatItem(item: ChatListItemData): void {
    Row() {
      Image(item.user.avatar)
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor(0xFFE8E8E8);

      Column() {
        Row() {
          Text(item.user.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          if (item.unread > 0) {
            Text(String(item.unread))
              .fontSize(11)
              .fontColor(Color.White)
              .backgroundColor(0xFFFF3B30)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(10)
              .margin({ left: 6 });
          }
          Blank();
          Text(item.time)
            .fontSize(12)
            .opacity(0.6);
        }
        .width('100%');

        Text(item.lastMessage)
          .fontSize(14)
          .opacity(0.85)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 });
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .onClick(() => {
      let param: ChatDetailRouteParams = {
        uid: item.user.uid,
        targetName: item.user.nickname,
        targetAvatar: item.user.avatar
      };
      this.pathStack.pushPathByName('ChatDetailPage', param);
    });
  }

  build() {
    Column() {
      Row() {
        Text('消息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 });

      if (this.vm.loading && this.vm.chatList.length === 0) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .opacity(0.8);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (this.vm.errorMessage !== '' && this.vm.chatList.length === 0) {
        Column() {
          Text(this.vm.errorMessage)
            .fontSize(14)
            .opacity(0.8)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 12 });
          Button('重试', { type: ButtonType.Capsule })
            .onClick(() => {
              this.vm.loadChatList();
            });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (this.vm.chatList.length === 0) {
        Column() {
          Text('暂无会话')
            .fontSize(14)
            .opacity(0.7);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        List() {
          ForEach(this.vm.chatList, (item: ChatListItemData) => {
            ListItem() {
              this.buildChatItem(item);
            }
            .margin({ bottom: 1 });
          }, (item: ChatListItemData) => String(item.user.uid));
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: 0xFFF0F0F0 })
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height(LayoutPolicy.matchParent)
    .backgroundColor(0xFFF5F5F5)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .ignoreLayoutSafeArea()
    .padding({
      top: windowUtil.mainWindowInfo.avoidSystem !== undefined ?
        windowUtil.mainWindowInfo.avoidSystem.topRect.height + 'px' : '0px',
      bottom: windowUtil.mainWindowInfo.avoidNavigationIndicator !== undefined ?
        windowUtil.mainWindowInfo.avoidNavigationIndicator.bottomRect.height + 'px' : '0px'
    });
  }
}
