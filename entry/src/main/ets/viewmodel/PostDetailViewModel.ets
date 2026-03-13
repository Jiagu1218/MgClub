import { getPostDetail, getPostCommentList } from '../common/network';
import type { PostDetailData, PostCommentItemData, PagedListData } from '../common/network';

@ObservedV2
export class PostDetailViewModel {
  @Trace postId: number = 0;
  @Trace loading: boolean = false;
  @Trace errorMessage: string = '';

  @Trace detail: PostDetailData | null = null;
  @Trace comments: Array<PostCommentItemData> = [];
  @Trace commentsPage: number = 1;
  @Trace commentsPageSize: number = 20;
  @Trace commentsHasMore: boolean = true;
  @Trace loadingComments: boolean = false;

  init(postId: number): void {
    this.postId = postId;
  }

  async loadDetail(): Promise<void> {
    if (this.postId <= 0) {
      this.errorMessage = '帖子不存在';
      return;
    }
    this.loading = true;
    this.errorMessage = '';
    try {
      let data: PostDetailData = await getPostDetail(this.postId);
      this.detail = data;
    } catch (e) {
      this.errorMessage = '加载帖子详情失败，请稍后重试';
    } finally {
      this.loading = false;
    }
  }

  async loadFirstCommentsPage(): Promise<void> {
    if (this.postId <= 0) {
      return;
    }
    this.commentsPage = 1;
    this.commentsHasMore = true;
    this.comments = [];
    await this.loadMoreComments();
  }

  async loadMoreComments(): Promise<void> {
    if (!this.commentsHasMore || this.loadingComments) {
      return;
    }
    this.loadingComments = true;
    try {
      let resp: PagedListData<PostCommentItemData> = await getPostCommentList(
        this.postId,
        this.commentsPage,
        this.commentsPageSize
      );
      let newList: Array<PostCommentItemData> = [];
      let i: number;
      for (i = 0; i < this.comments.length; i++) {
        newList.push(this.comments[i]);
      }
      for (i = 0; i < resp.list.length; i++) {
        newList.push(resp.list[i]);
      }
      this.comments = newList;
      this.commentsPage = resp.page + 1;
      this.commentsHasMore = resp.page * resp.pageSize < resp.total;
    } catch (e) {
      // 保持已有列表，必要时可在 UI 上增加错误提示
    } finally {
      this.loadingComments = false;
    }
  }
}

