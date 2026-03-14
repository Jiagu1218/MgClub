import { getPostDetail, getPostCommentList } from '../common/network';
import type { PostDetailData, PostCommentItemData, ReplyListData } from '../common/network';

export interface PostContentBlock {
  type: string; // 'text' | 'image'
  text: string;
  src: string;
  width?: number;
  height?: number;
}

@ObservedV2
export class PostDetailViewModel {
  @Trace postId: number = 0;
  @Trace detail: PostDetailData | null = null;
  @Trace loading: boolean = false;
  @Trace errorMessage: string = '';
  /** 置顶楼层（仅首页返回） */
  @Trace commentsTopList: Array<PostCommentItemData> = [];
  /** 普通楼层列表 */
  @Trace commentsList: Array<PostCommentItemData> = [];
  @Trace commentsTotal: number = 0;
  @Trace commentsPage: number = 1;
  @Trace commentsPageSize: number = 20;
  @Trace commentsHasMore: boolean = true;
  @Trace loadingComments: boolean = false;
  @Trace contentBlocks: Array<PostContentBlock> = [];

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
      this.contentBlocks = this.parseContentToBlocks(data.content);
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
    this.commentsTopList = [];
    this.commentsList = [];
    await this.loadMoreComments();
  }

  async loadMoreComments(): Promise<void> {
    if (!this.commentsHasMore || this.loadingComments) {
      return;
    }
    this.loadingComments = true;
    try {
      let resp: ReplyListData = await getPostCommentList(
        this.postId,
        this.commentsPage,
        this.commentsPageSize
      );
      if (this.commentsPage === 1) {
        this.commentsTopList = resp.topList;
        this.commentsList = resp.list;
      } else {
        let i: number;
        for (i = 0; i < resp.list.length; i++) {
          this.commentsList.push(resp.list[i]);
        }
      }
      this.commentsTotal = resp.total;
      this.commentsPage = resp.page + 1;
      this.commentsHasMore = resp.page * resp.pageSize < resp.total;
    } catch (e) {
      // 保持已有列表，必要时可在 UI 上增加错误提示
    } finally {
      this.loadingComments = false;
    }
  }

  public parseContentToBlocks(html: string): Array<PostContentBlock> {
    let blocks: Array<PostContentBlock> = [];
    let segments: Array<string> = html.split('<img');
    // 处理第一个纯文本段
    if (segments.length > 0) {
      let firstText: string = this.stripHtmlTags(segments[0]);
      if (firstText.trim().length > 0) {
        blocks.push({
          type: 'text',
          text: firstText,
          src: ''
        });
      }
    }
    // 后续段中包含图片和后续文本
    let i: number;
    for (i = 1; i < segments.length; i++) {
      let segmentFull: string = '<img' + segments[i];
      let srcIndex: number = segmentFull.indexOf('src="');
      let width: number = 0;
      let height: number = 0;
      let styleIndex: number = segmentFull.indexOf('style="');
      if (styleIndex >= 0) {
        let styleStart: number = styleIndex + 7;
        let styleEnd: number = segmentFull.indexOf('"', styleStart);
        if (styleEnd > styleStart) {
          let styleStr: string = segmentFull.substring(styleStart, styleEnd);
          width = this.parseSizeFromStyle(styleStr, 'width');
          height = this.parseSizeFromStyle(styleStr, 'height');
        }
      }

      if (srcIndex >= 0) {
        let start: number = srcIndex + 5;
        let end: number = segmentFull.indexOf('"', start);
        if (end > start) {
          let src: string = segmentFull.substring(start, end);
          let block: PostContentBlock = {
            type: 'image',
            text: '',
            src: src
          };
          if (width > 0) {
            block.width = width;
          }
          if (height > 0) {
            block.height = height;
          }
          blocks.push(block);
        }
      }
      let gtIndex: number = segmentFull.indexOf('>');
      let afterTag: string = '';
      if (gtIndex >= 0 && gtIndex + 1 < segmentFull.length) {
        afterTag = segmentFull.substring(gtIndex + 1);
      }
      let textPart: string = this.stripHtmlTags(afterTag);
      if (textPart.trim().length > 0) {
        blocks.push({
          type: 'text',
          text: textPart,
          src: ''
        });
      }
    }
    return blocks;
  }

  private stripHtmlTags(input: string): string {
    let result: string = '';
    let inTag: boolean = false;
    let i: number;
    for (i = 0; i < input.length; i++) {
      let ch: string = input.charAt(i);
      if (ch === '<') {
        inTag = true;
        continue;
      }
      if (ch === '>') {
        inTag = false;
        continue;
      }
      if (!inTag) {
        result = result + ch;
      }
    }
    return result.replace('&nbsp;', ' ');
  }

  private parseSizeFromStyle(style: string, key: string): number {
    let idx: number = style.indexOf(key + ':');
    if (idx < 0) {
      return 0;
    }
    let start: number = idx + key.length + 1;
    // 跳过空格
    while (start < style.length && style.charAt(start) === ' ') {
      start++;
    }
    let pxIndex: number = style.indexOf('px', start);
    if (pxIndex < 0) {
      return 0;
    }
    let numStr: string = style.substring(start, pxIndex);
    let trimmed: string = numStr.trim();
    if (trimmed.length === 0) {
      return 0;
    }
    let value: number = Number(trimmed);
    if (isNaN(value) || value <= 0) {
      return 0;
    }
    return value;
  }
}

