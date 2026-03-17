import type { UserBriefData, LevelItemData } from '../common/network';
import { levelStore } from '../common/LevelStore';

@ComponentV2
export struct FollowUserCard {
  @Require @Param item: UserBriefData;

  @Computed
  get levelText(): string {
    let level: number = this.item.level;
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

  @Computed
  get followStatusText(): string {
    let he: boolean = this.item.focusHe === true;
    let me: boolean = this.item.focusMe === true;
    if (he && me) {
      return '互关';
    }
    if (he) {
      return '已关注';
    }
    return '关注';
  }

  build() {
    // 拟物风格：将整行视为一张人物信息卡片
    Row() {
      if (this.item.avatar !== '') {
        Image(this.item.avatar)
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor(0xFFE0E0E0);
      }

      Column() {
        Row() {
          Text(this.item.nickname)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(0xFF333333);

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

        Row() {
          Text('关注: ' + String(this.item.followCount !== undefined ? this.item.followCount : 0))
            .fontSize(12)
            .fontColor(0xFFFFA14A);

          Text('  粉丝: ' + String(this.item.fansCount !== undefined ? this.item.fansCount : 0))
            .fontSize(12)
            .fontColor(0xFFFFA14A)
            .margin({ left: 8 });

          Text('  动态: ' + String(this.item.postCount !== undefined ? this.item.postCount : 0))
            .fontSize(12)
            .fontColor(0xFFFFA14A)
            .margin({ left: 8 });
        }
        .margin({ top: 4 });
      }
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start);

      Blank();

      // 右侧关注状态：关注 / 已关注 / 互关
      // 右侧关注状态：做成小胶囊按钮，突出但不突兀
      Text(this.followStatusText)
        .fontSize(12)
        .fontColor(0xFFFF7E3E)
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .borderRadius(16)
        .backgroundColor(0x1AFFE0C0);
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    // 与帖子卡片统一的纸质背景和圆角
    .backgroundColor(0xFFFCFAF5)
    .borderRadius(14)
    .border({ width: 0.5, color: 0x11AAAAAA })
    // 双层阴影增强拟物立体感
    .shadow({
      radius: 12,
      color: 0x0F000000,
      offsetX: 0,
      offsetY: 6
    })
    .shadow({
      radius: 4,
      color: 0x22000000,
      offsetX: 0,
      offsetY: 2
    });
  }
}

