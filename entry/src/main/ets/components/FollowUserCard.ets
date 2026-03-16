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
      Text(this.followStatusText)
        .fontSize(12)
        .fontColor(0xFFFFA14A)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .borderRadius(14)
        .backgroundColor(0x1AFFA14A);
    }
    .padding({ top: 10, bottom: 10, left: 16, right: 16 });
  }
}

