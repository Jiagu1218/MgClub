import { getUserInfo, getUserDataCount, getPostUserList, getFollowList, getFansList, getPostFavoriteList } from '../common/network';
import type {
  UserInfoData,
  UserDataCountData,
  PagedListData,
  PostUserItemData,
  UserBriefData,
  PostBriefItemData,
  LevelItemData
} from '../common/network';
import { levelStore } from '../common/LevelStore';
import { authStore } from '../common/AuthStore';

@ObservedV2
export class ProfileViewModel {
  @Trace hasLogin: boolean = false;
  @Trace loading: boolean = false;
  @Trace userInfo?: UserInfoData;
  @Trace errorMessage: string = '';
  @Trace currentLevelName: string = '';

  @Trace dataCount?: UserDataCountData;
  @Trace posts: Array<PostUserItemData> = [];
  @Trace followList: Array<UserBriefData> = [];
  @Trace fansList: Array<UserBriefData> = [];
  @Trace favoriteList: Array<PostBriefItemData> = [];
  @Trace listLoading: boolean = false;
  @Trace listError: string = '';

  init(): void {
    this.hasLogin = authStore.isLoggedIn();
    if (this.hasLogin) {
      this.loadAll();
    }
  }

  private async loadAll(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    try {
      let u: UserInfoData = await getUserInfo();
      this.userInfo = u;

      if (u.exp !== undefined) {
        let lv: LevelItemData | undefined = levelStore.getLevelByScore(u.exp as number);
        this.currentLevelName = lv !== undefined ? 'Lv' + String(lv.level) + ' ' + lv.name : '';
      } else {
        this.currentLevelName = '';
      }

      let uidNum: number = u.uid;

      try {
        this.dataCount = await getUserDataCount(uidNum);
      } catch (_e) {
        this.dataCount = undefined;
      }

      this.listLoading = true;
      this.listError = '';
      try {
        let results: [
          PagedListData<PostUserItemData>,
          PagedListData<UserBriefData>,
          PagedListData<UserBriefData>,
          PagedListData<PostBriefItemData>
        ] = await Promise.all([
          getPostUserList(uidNum, 1, 10),
          getFollowList(uidNum, 1, 10),
          getFansList(uidNum, 1, 10),
          getPostFavoriteList(uidNum, 1, 10)
        ]);
        this.posts = results[0].list;
        this.followList = results[1].list;
        this.fansList = results[2].list;
        this.favoriteList = results[3].list;
      } catch (e) {
        this.listError = e instanceof Error ? e.message : String(e);
      } finally {
        this.listLoading = false;
      }
    } catch (e) {
      this.errorMessage = '获取用户信息失败：' + (e instanceof Error ? e.message : String(e));
    } finally {
      this.loading = false;
    }
  }
}

