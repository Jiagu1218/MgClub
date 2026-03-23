import type { PostBriefItemData, LevelItemData } from '../common/network';
import { levelStore } from '../common/LevelStore';

@ReusableV2
@ComponentV2
export struct HomePostItem {
  @Require @Param item: PostBriefItemData;
  @Param isTop: boolean = false;
  @Event onOpen: (id: number) => void = (_id: number): void => {};
  @Local isPressed: boolean = false;

  aboutToRecycle(): void {
    // 回收到复用池前清理临时交互态，避免复用后出现残留按压视觉
    this.isPressed = false;
  }

  aboutToReuse(): void {
    // 从复用池取出后兜底重置交互态
    this.isPressed = false;
  }

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

  @Computed
  get safePictures(): Array<string> {
    if (this.item.pictures === undefined) {
      return [];
    }
    return this.item.pictures;
  }

  @Computed
  get displayPictureCount(): number {
    let count: number = this.safePictures.length;
    if (count > 9) {
      return 9;
    }
    return count;
  }

  @Computed
  get pictureIndexes(): Array<number> {
    let indexes: Array<number> = [];
    let i: number;
    for (i = 0; i < this.displayPictureCount; i++) {
      indexes.push(i);
    }
    return indexes;
  }

  @Computed
  get pictureColumnsTemplate(): string {
    if (this.displayPictureCount === 4) {
      return '1fr 1fr';
    }
    return '1fr 1fr 1fr';
  }

  @Builder
  private buildPictureGrid(): void {
    if (this.displayPictureCount > 0) {
      Grid() {
        ForEach(this.pictureIndexes, (index: number) => {
          GridItem() {
            Image(this.safePictures[index])
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .backgroundColor(0xFFEFEFEF);
          }
        }, (index: number) => {
          return String(index);
        })
      }
      .width('100%')
      .columnsTemplate(this.pictureColumnsTemplate)
      .rowsGap(6)
      .columnsGap(6)
      .margin({ top: 8 });
    }
  }

  build() {
    // 外层视为一张“纸质卡片”，使用更立体的阴影和柔和底色
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

      // 标题（深色，略大行高，类似杂志标题）
      Text(this.item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(0xFF333333)
        .lineHeight(22)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 10, bottom: 2 });

      // 内容摘要（更大的行高，增强“纸面排版”感）
      if (this.item.summary !== '') {
        Text(this.item.summary)
          .fontSize(13)
          .fontColor(0xFF666666)
          .opacity(0.95)
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 });
      }

      this.buildPictureGrid();

      // 帖子数据（阅读 / 评论 / 点赞），置顶贴不展示
      if (!this.isTop) {
        Row() {
          Row() {
            Text('👁 ')
              .fontSize(11)
              .fontColor(0xFFB0B0B0);
            Text(String(this.item.readings))
              .fontSize(11)
              .fontColor(0xFF999999);
          }

          Row() {
            Text(' 💬 ')
              .fontSize(11)
              .fontColor(0xFFB0B0B0)
              .margin({ left: 16 });
            Text(String(this.item.replyCount))
              .fontSize(11)
              .fontColor(0xFF999999);
          }

          Row() {
            Text(' 👍 ')
              .fontSize(11)
              .fontColor(0xFFB0B0B0)
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
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    // 轻微暖色底，模拟纸质材质
    .backgroundColor(this.isPressed ? 0xFFF2EFE8 : 0xFFFCFAF5)
    .borderRadius(14)
    .border({ width: 0.5, color: 0x11AAAAAA })
    .alignItems(HorizontalAlign.Start) // 整卡片内容左对齐
    // 双层阴影，增强立体拟物感
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
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
        return;
      }
      this.isPressed = false;
    })
    .onClick(() => {
      this.onOpen(this.item.id);
    });
  }
}