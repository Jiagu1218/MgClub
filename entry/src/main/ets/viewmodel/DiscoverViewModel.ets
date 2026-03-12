import { searchUser, searchPost, getContributionRank } from '../common/network';
import type {
  UserBriefData,
  PostSearchData,
  PostSearchItemData,
  ContributionRankItemData,
  PagedListData
} from '../common/network';
import { GenericBasicDataSource } from './GenericBasicDataSource';

@ObservedV2
export class DiscoverViewModel {
  @Trace keyword: string = '';
  @Trace currentTab: number = 0; // 0=用户,1=帖子,2=贡献榜

  @Trace isSearchingUser: boolean = false;
  @Trace isSearchingPost: boolean = false;
  @Trace isLoadingRank: boolean = false;

  @Trace firstUserError: string = '';
  @Trace firstPostError: string = '';
  @Trace rankError: string = '';

  @Trace userDataSource: GenericBasicDataSource<UserBriefData> =
    new GenericBasicDataSource<UserBriefData>();
  @Trace postDataSource: GenericBasicDataSource<PostSearchItemData> =
    new GenericBasicDataSource<PostSearchItemData>();
  @Trace rankDataSource: GenericBasicDataSource<ContributionRankItemData> =
    new GenericBasicDataSource<ContributionRankItemData>();

  async searchUserList(): Promise<void> {
    if (this.keyword === '') {
      this.userDataSource.setData([]);
      this.firstUserError = '';
      return;
    }
    this.isSearchingUser = true;
    this.firstUserError = '';
    try {
      let paged: PagedListData<UserBriefData> = await searchUser(this.keyword);
      this.userDataSource.setData(paged.list);
    } catch (e) {
      this.firstUserError = '搜索用户失败，请稍后重试';
    } finally {
      this.isSearchingUser = false;
    }
  }

  async searchPostList(): Promise<void> {
    if (this.keyword === '') {
      this.postDataSource.setData([]);
      this.firstPostError = '';
      return;
    }
    this.isSearchingPost = true;
    this.firstPostError = '';
    try {
      let data: PostSearchData = await searchPost(this.keyword, 0);
      this.postDataSource.setData(data.list);
    } catch (e) {
      this.firstPostError = '搜索帖子失败，请稍后重试';
    } finally {
      this.isSearchingPost = false;
    }
  }

  async loadRank(sort: string): Promise<void> {
    this.isLoadingRank = true;
    this.rankError = '';
    try {
      let paged: PagedListData<ContributionRankItemData> = await getContributionRank(1, 50, sort);
      this.rankDataSource.setData(paged.list);
    } catch (e) {
      this.rankError = '加载贡献榜失败';
    } finally {
      this.isLoadingRank = false;
    }
  }
}

