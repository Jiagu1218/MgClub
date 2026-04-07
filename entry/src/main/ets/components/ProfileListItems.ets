import type { PostUserItemData, PostBriefItemData } from '../common/network';

// 首页用帖子 item：头像 + 昵称/时间 + 标题 + 摘要 + 底部阅读/评论/点赞
@Builder
export function ProfilePostItem(item: PostBriefItemData) {
  Column() {
    // 顶部：作者信息行
    Row() {
      if (item.author.avatar !== '') {
        Image(item.author.avatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor(0xFFE0E0E0);
      }
      Column() {
        Row() {
          Text(item.author.nickname)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(0xFF333333);
          // 等级徽章（如果后续补充 level，可在这里展示）
        }
        Text(item.createdAt)
          .fontSize(11)
          .fontColor(0xFF999999)
          .margin({ top: 2 });
      }
      .margin({ left: 8 });
      Blank();
    }
    .alignItems(VerticalAlign.Center)

    // 标题
    Text(item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(0xFF222222)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ top: 8 });

    // 摘要
    if (item.summary !== '') {
      Text(item.summary)
        .fontSize(13)
        .fontColor(0xFF666666)
        .opacity(0.95)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 });
    }

    // 底部：阅读 / 评论 / 点赞 统计
    Row() {
      Row() {
        Text('阅')
          .fontSize(11)
          .fontColor(0xFFBBBBBB);
        Text(' ' + item.readings)
          .fontSize(11)
          .fontColor(0xFF999999);
      }

      Row() {
        Text(' 评')
          .fontSize(11)
          .fontColor(0xFFBBBBBB)
          .margin({ left: 12 });
        Text(' ' + item.replyCount)
          .fontSize(11)
          .fontColor(0xFF999999);
      }

      Row() {
        Text(' 赞')
          .fontSize(11)
          .fontColor(0xFFBBBBBB)
          .margin({ left: 12 });
        Text(' ' + item.likeCount)
          .fontSize(11)
          .fontColor(0xFF999999);
      }

      Blank();
    }
    .margin({ top: 8 });
  }
  .width('100%')
  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
  .backgroundColor(0xFFFFFFFF)
  .borderRadius(10)
  .shadow({
    radius: 6,
    color: 0x14000000,
    offsetX: 0,
    offsetY: 2
  });
}

// “我的-动态”用：用户自己发帖列表，结构与首页相同但暂不含阅读数
@Builder
export function ProfileUserPostItem(item: PostUserItemData) {
  Column() {
    Text(item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ bottom: 6 });

    Text(item.summary)
      .fontSize(13)
      .opacity(0.85)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ bottom: 10 });

    Row() {
      Text(item.createdAt)
        .fontSize(11)
        .opacity(0.6);

      Blank();

      Text('👍 ' + item.likeCount)
        .fontSize(11)
        .opacity(0.8)
        .margin({ right: 8 });

      Text('💬 ' + item.replyCount)
        .fontSize(11)
        .opacity(0.8);
    }
  }
  .width('100%')
  .padding({ left: 14, right: 14, top: 12, bottom: 12 })
  .backgroundColor(Color.White)
  .borderRadius(10)
  .height(96)
  .shadow({
    radius: 8,
    color: 0x1A000000,
    offsetX: 0,
    offsetY: 2
  });
}

@Builder
export function ProfileFavoritePostItem(item: PostBriefItemData) {
  Row() {
    if (item.pictures.length > 0) {
      Image(item.pictures[0].thumbnail)
        .width(64)
        .height(64)
        .borderRadius(8)
        .backgroundColor(0xFFE0E0E0);
    }
    Column() {
      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
      Text(item.summary)
        .fontSize(12)
        .fontColor(0xFF666666)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 });
      Row() {
        Text('阅读 ' + item.readings)
          .fontSize(11)
          .fontColor(0xFF999999);
        Text(' · ')
          .fontSize(11)
          .fontColor(0xFFCCCCCC)
          .margin({ left: 2, right: 2 });
        Text(item.createdAt)
          .fontSize(11)
          .fontColor(0xFF999999);
      }
      .margin({ top: 6 });
    }
    .margin({ left: 12 });
    Blank();
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

