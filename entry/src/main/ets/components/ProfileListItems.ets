import type { PostUserItemData, UserBriefData, PostBriefItemData } from '../common/network';

@Builder
export function ProfilePostItem(item: PostUserItemData) {
  Column() {
    Text(item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium);
    Text(item.summary)
      .fontSize(13)
      .fontColor(0xFF666666)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ top: 4 });
    Text(item.createdAt)
      .fontSize(11)
      .fontColor(0xFF999999)
      .margin({ top: 6 });
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

@Builder
export function ProfileUserBriefItem(item: UserBriefData) {
  Row() {
    if (item.avatar !== '') {
      Image(item.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(0xFFE0E0E0);
    }
    Column() {
      Text(item.nickname)
        .fontSize(15)
        .fontWeight(FontWeight.Medium);
    }
    .margin({ left: 12 });
    Blank();
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

@Builder
export function ProfileFavoritePostItem(item: PostBriefItemData) {
  Row() {
    if (item.pictures.length > 0) {
      Image(item.pictures[0])
        .width(64)
        .height(64)
        .borderRadius(8)
        .backgroundColor(0xFFE0E0E0);
    }
    Column() {
      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium);
      Text(item.summary)
        .fontSize(12)
        .fontColor(0xFF666666)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 });
      Text(item.createdAt)
        .fontSize(11)
        .fontColor(0xFF999999)
        .margin({ top: 6 });
    }
    .margin({ left: 12 });
    Blank();
  }
  .padding({ top: 10, bottom: 10, left: 16, right: 16 });
}

