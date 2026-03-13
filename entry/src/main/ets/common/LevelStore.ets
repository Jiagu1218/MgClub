import { getLevelList } from '../common/network';
import type { LevelItemData } from '../common/network';

export class LevelStore {
  private static instance: LevelStore = new LevelStore();

  private levels: Array<LevelItemData> = [];
  private initialized: boolean = false;

  static getInstance(): LevelStore {
    return LevelStore.instance;
  }

  async init(): Promise<void> {
    if (this.initialized) {
      return;
    }
    let list: Array<LevelItemData> = await getLevelList();
    this.levels = list;
    this.initialized = true;
  }

  getLevels(): Array<LevelItemData> {
    return this.levels;
  }

  /**
   * 根据经验值查找对应等级；如果未命中，返回最低等级
   */
  getLevelByScore(score: number): LevelItemData | undefined {
    if (this.levels.length === 0) {
      return undefined;
    }
    let result: LevelItemData | undefined = undefined;
    let i: number;
    for (i = 0; i < this.levels.length; i++) {
      let lv: LevelItemData = this.levels[i];
      if (score >= lv.maxScore) {
        result = lv;
        continue;
      } else{
        break;
      }
    }
    if (result === undefined) {
      result = this.levels[this.levels.length - 1];
    }
    return result;
  }
}

export const levelStore: LevelStore = LevelStore.getInstance();

