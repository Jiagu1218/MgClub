import type { PostBriefItemData, LevelItemData } from '../common/network';
import { levelStore } from '../common/LevelStore';

@ComponentV2
export struct HomePostItem {
  @Require @Param item: PostBriefItemData;
  @Param isTop: boolean = false;

  @Computed
  get levelText(): string {
    let level: number = this.item.author.level;
    if (level <= 0) {
      return '';
    }
    let levels: Array<LevelItemData> = levelStore.getLevels();
    let i: number;
    for (i = 0; i < levels.length; i++) {
      let lvItem: LevelItemData = levels[i];
      if (lvItem.level === level) {
        return 'Lv' + String(lvItem.level) + ' ' + lvItem.name;
      }
    }
    return 'Lv' + String(level);
  }

  build() {
    Column() {
      // 顶部：发帖人信息（头像 + 昵称/时间/等级），置顶贴不展示
      if (!this.isTop) {
        Row() {
          if (this.item.author.avatar !== '') {
            Image(this.item.author.avatar)
              .width(36)
              .height(36)
              .borderRadius(18)
              .backgroundColor(0xFFE0E0E0);
          }

          Column() {
            Row() {
              // 昵称（橙色）
              Text(this.item.author.nickname)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFFFF7E3E);

              if (this.levelText !== '') {
                Text(this.levelText)
                  .fontSize(11)
                  .fontColor(0xFFFFFFFF)
                  .backgroundColor(0xFF7B68EE)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(10)
                  .margin({ left: 6 });
              }
            }

            Text(this.item.createdAt)
              .fontSize(11)
              .fontColor(0xFF999999)
              .margin({ top: 2 });
          }
          .margin({ left: 8 })
          .alignItems(HorizontalAlign.Start);
        }
        .alignItems(VerticalAlign.Center)
      }

      // 标题（深色）
      Text(this.item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(0xFF333333)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 });

      // 内容摘要
      if (this.item.summary !== '') {
        Text(this.item.summary)
          .fontSize(13)
          .fontColor(0xFF666666)
          .opacity(0.95)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 });
      }

      // 帖子数据（阅读 / 评论 / 点赞），置顶贴不展示
      if (!this.isTop) {
        Row() {
          Row() {
            Text('阅 ')
              .fontSize(11)
              .fontColor(0xFFBBBBBB);
            Text(String(this.item.readings))
              .fontSize(11)
              .fontColor(0xFF999999);
          }

          Row() {
            Text(' 评 ')
              .fontSize(11)
              .fontColor(0xFFBBBBBB)
              .margin({ left: 16 });
            Text(String(this.item.replyCount))
              .fontSize(11)
              .fontColor(0xFF999999);
          }

          Row() {
            Text(' 赞 ')
              .fontSize(11)
              .fontColor(0xFFBBBBBB)
              .margin({ left: 16 });
            Text(String(this.item.likeCount))
              .fontSize(11)
              .fontColor(0xFF999999);
          }
        }
        .margin({ top: 10 });
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(0xFFFFFFFF)
    .borderRadius(10)
    .alignItems(HorizontalAlign.Start) // 整卡片内容左对齐
    .shadow({
      radius: 6,
      color: 0x14000000,
      offsetX: 0,
      offsetY: 2
    });
  }
}