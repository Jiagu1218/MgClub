import { getPostListBrief } from '../common/network';
import type { PostBriefItemData, PagedListData } from '../common/network';
import { GenericBasicDataSource } from './GenericBasicDataSource';

@ObservedV2
export class PostListViewModel {
  @Trace page: number = 1;
  @Trace pageSize: number = 20;
  @Trace postList: Array<PostBriefItemData> = [];
  @Trace hasMore: boolean = true;
  @Trace isRefreshing: boolean = false;
  @Trace isLoadingMore: boolean = false;
  @Trace firstLoadError: string = '';

  @Trace dataSource: GenericBasicDataSource<PostBriefItemData> = new GenericBasicDataSource<PostBriefItemData>();

  async loadFirstPage(): Promise<void> {
    this.isRefreshing = true;
    this.firstLoadError = '';
    this.page = 1;
    try {
      let resp: PagedListData<PostBriefItemData> = await getPostListBrief(this.page, this.pageSize);
      this.postList = resp.list;
      this.dataSource.setData(resp.list);
      // 根据 total 与分页信息推导是否还有更多数据
      this.hasMore = this.page * this.pageSize < resp.total;
    } catch (e) {
      this.firstLoadError = '加载失败，请下拉重试';
    } finally {
      this.isRefreshing = false;
    }
  }

  async loadMore(): Promise<void> {
    if (!this.hasMore || this.isLoadingMore) {
      return;
    }
    this.isLoadingMore = true;
    try {
      let nextPage: number = this.page + 1;
      let resp: PagedListData<PostBriefItemData> = await getPostListBrief(nextPage, this.pageSize);
      let newList: Array<PostBriefItemData> = [];
      let i: number;
      for (i = 0; i < this.postList.length; i++) {
        newList.push(this.postList[i]);
      }
      for (i = 0; i < resp.list.length; i++) {
        newList.push(resp.list[i]);
      }
      this.postList = newList;
      this.dataSource.appendData(resp.list);
      this.page = nextPage;
      this.hasMore = this.page * this.pageSize < resp.total;
    } catch (e) {
      // 可按需添加日志
    } finally {
      this.isLoadingMore = false;
    }
  }
}

