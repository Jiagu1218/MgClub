/**
 * 2550505.com API 请求封装
 * 基于 RcpClient（SessionPool 底层），对接 2550505-api-doc.md 中接口
 */

import { http } from '@kit.NetworkKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { RcpClient } from '../RcpClient';
import type { HttpPoolRequestOptions } from '../HttpPoolTypes';
import { authStore } from '../../AuthStore';
import type {
  ApiResponse,
  VersionData,
  LevelItemData,
  LevelInfoData,
  UserInfoData,
  UserScoreData,
  UserBriefData,
  UserDataCountData,
  PagedListData,
  PostBriefItemData,
  PostUserItemData,
  PostSearchData,
  PostSearchItemData,
  PostDetailData,
  PostCommentItemData,
  ReplyListData,
  ReplySubItemData,
  ReplyMentionData,
  NoticeCountData,
  NoticeReplyItemData,
  ChatListResponse,
  ChatListItemData,
  ChatListUserData,
  ChatHistoryResponse,
  ChatHistoryItemData,
  ChatNewestResponse,
  SignSignedData,
  ContributionRankItemData,
  OrderItem,
  AddressItemData,
  AuthCodeData,
  AuthValidateData,
  AuthLoginData
} from './ApiTypes';

// ---------- 原始响应类型（紧贴后端返回结构） ----------

interface VersionRawResponse {
  code: number;
  version: string;
  description?: string;
  android?: string;
  ios?: string;
}

interface LevelListRawItem {
  id: number;
  level: number;
  name: string;
  exp: number;
  color: string;
  label_color: string;
}

interface LevelListRawResponse {
  code: number;
  list: Array<LevelListRawItem>;
}

interface LevelInfoRawItem {
  level: number;
  name: string;
  color: string;
  labelColor: string;
  exp: number;
  currentExp: number;
}

interface LevelInfoRawResponse {
  code: number;
  levelInfo: LevelInfoRawItem;
  nextLevel: LevelInfoRawItem;
}

interface UserInfoRaw {
  uid: number;
  nickname: string;
  avatar: string;
  role: number;
  status: number;
  exp: number;
  contribution: number;
  sign: string;
  auth: number;
  authentication: string;
  location: string;
  isp: string;
  sex: number;
  birthday: number;
}

interface UserInfoRawResponse {
  code: number;
  info: UserInfoRaw;
}

interface UserScoreRawResponse {
  code: number;
  bilibili: Array<object>;
  douyu: Array<object>;
}

interface UserDetailBindRawItem {
  nickname: string;
  uid: string;
  point: number | null;
  level: number;
}

interface UserDetailBindRaw {
  douyu: Array<UserDetailBindRawItem>;
  bilibili: Array<UserDetailBindRawItem>;
}

interface UserDetailRaw {
  uid: number;
  nickname: string;
  avatar: string;
  role: number;
  status: number;
  exp: number;
  contribution: number;
  sign: string;
  sex: number;
  birthday: number;
  lunar: number;
  showLocation: boolean;
  location: string;
  isp: string;
  auth: number;
  authentication: string;
  bind: UserDetailBindRaw;
}

interface UserDetailRawResponse {
  code: number;
  info: UserDetailRaw;
}

interface UserDataCountRaw {
  follow: number;
  fans: number;
  favorite: number;
  post: number;
  bilibiliScore: number;
  douyuScore: number;
}

interface UserDataCountRawResponse {
  code: number;
  data: UserDataCountRaw;
}

interface UserListRawItem {
  uid: number;
  nickname: string;
  avatar: string;
  auth: number;
  authentication: string;
  fans: number;
  follow: number;
  posts: number;
  focusHe?: boolean;
  focusMe?: boolean;
  sign?: string;
}

interface UserListRawResponse {
  code: number;
  list: Array<UserListRawItem>;
}

interface SearchUserRawItem {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  auth: number;
  authentication: string;
}

interface SearchUserRawResponse {
  code: number;
  list: Array<SearchUserRawItem>;
}

interface SearchPostRawAuthor {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  auth: number;
  authentication: string;
}

interface SearchPostRawItem {
  id: number;
  title: string;
  postTime: string;
  author: SearchPostRawAuthor;
}

interface SearchPostRawResponse {
  code: number;
  list: Array<SearchPostRawItem>;
  searchId: number;
  finish: boolean;
}

interface PostLabelRaw {
  color: string;
  labelId: number;
  labelName: string;
}

interface PostListBriefRawAuthor {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  role: number;
  status: number;
}

interface PostListBriefRawItem {
  id: number;
  title: string;
  content: string;
  STATUS: number;
  author?: PostListBriefRawAuthor;
  exp: number;
  hanserLike: boolean;
  hanserReply: boolean;
  labels: Array<PostLabelRaw>;
  liked: boolean;
  likes?: number;
  pictures: Array<string>;
  post_time: string;
  readings: number;
  replies?: number;
  role: number;
  tags: Array<object>;
}

interface PostListBriefRawResponse {
  code: number;
  result: Array<PostListBriefRawItem>;
  total: number;
}

interface PostUserListRawAuthor {
  uid: number;
  nickname: string;
  avatar: string;
  role: number;
  status: number;
  exp: number;
  auth: number;
  authentication: string;
}

interface PostUserListRawItem {
  id: number;
  title: string;
  content: string;
  post_time: string;
  type: number;
  role: number;
  status: number;
  likes: number;
  replies: number;
  readings: number;
  primaryPictures?: Array<string>;
  pictures?: Array<string>;
  liked: boolean;
  tags: Array<object>;
  labels: Array<object>;
  author: PostUserListRawAuthor;
}

interface PostUserListRawResponse {
  code: number;
  list: Array<PostUserListRawItem>;
}

interface PostCommentRawAuthor {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  focusHe: boolean;
  auth: number;
  authentication: string;
  isPostMaster: boolean;
}

interface PostCommentRawMentionFloor {
  id: number;
  content: string;
  time: string;
}

interface PostCommentRawMention {
  author: PostCommentRawAuthor;
  floor: PostCommentRawMentionFloor;
}

interface PostCommentRawSubReply {
  id: number;
  content: string;
  time: string;
  location: string | null;
  isp: string;
  author: PostCommentRawAuthor;
  mention: PostCommentRawMention | null;
}

interface PostCommentRawItem {
  floorId: number;
  floor: number;
  isTop: boolean;
  day: string | null;
  content: string;
  hanserReply: boolean;
  hanserLike: boolean;
  location: string | null;
  isp: string;
  time: string;
  liked: boolean;
  likes: number;
  author: PostCommentRawAuthor;
  replies: Array<PostCommentRawSubReply>;
}

interface PostCommentRawResponse {
  code: number;
  postId: number;
  total: number;
  topList: Array<PostCommentRawItem>;
  list: Array<PostCommentRawItem>;
}

interface PostDetailRawAuthor {
  uid: number;
  nickname: string;
  avatar: string;
  role: number;
  status: number;
  exp: number;
  auth: number;
  authentication: string;
  focusHe: boolean;
}

interface PostDetailRaw {
  id: number;
  title: string;
  content: string;
  type: number;
  auth: number;
  authentication: string;
  post_time: string;
  likes: number;
  replies: number;
  readings: number;
  location: string | null;
  isp: string;
  voteId: number | null;
  limitation: number | null;
  showLocation: number | null;
  status: number;
  primaryPictures: Array<string>;
  pictures: Array<string>;
  tags: Array<object>;
  videos: Array<object>;
  valued: boolean;
  top: boolean;
  labels: Array<object>;
  author: PostDetailRawAuthor;
  liked: boolean;
  favorite: boolean;
}

interface PostDetailRawResponse {
  code: number;
  info: PostDetailRaw;
}

interface NoticeCountRawInner {
  likes: number;
  replies: number;
  at: number;
  notice: number;
  message: number;
  chats: number;
}

interface NoticeCountRawResponse {
  code: number;
  cache: boolean;
  count: NoticeCountRawInner;
}

interface NoticeReplyRawUser {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  auth: number;
  authentication: string;
}

interface NoticeReplyRawPostInfo {
  postId: number;
  title: string;
}

interface NoticeReplyRawItem {
  post: NoticeReplyRawPostInfo;
  postId: number;
  type: number;
  user: NoticeReplyRawUser;
  content: string;
  time: string;
}

interface NoticeReplyRawResponse {
  code: number;
  list: Array<NoticeReplyRawItem>;
}

interface SignSignedRawResponse {
  code: number;
  cahce: boolean;
  signed: boolean;
}

interface ContributionRankRawItem {
  uid: number;
  contribution: number;
  avatar: string;
  nickname: string;
}

interface ContributionRankRawResponse {
  code: number;
  list: Array<ContributionRankRawItem>;
  total: number;
}

interface AuthCodeRawResponse {
  code: number;
  publicKey: string;
  privateKey: string;
}

interface AuthValidateRawError {
  code: number;
  msg: string;
}

interface AuthValidateRawSuccess {
  code: number;
  bind: boolean;
  platformUid: number;
  site: string;
  uid: string;
  auth: string;
  msg: string;
}

interface AuthLoginRawResponse {
  code: number;
  token: string;
  uid: number;
}

/** 基础域名 */
const BASE_URL: string = 'https://2550505.com';

/** 全局 RCP 客户端（内部使用） */
const rcpClient: RcpClient = new RcpClient();
/** Query 参数项，用于 GET 拼接 */
export interface QueryParam {
  key: string;
  value: string | number;
}

function buildUrl(path: string, params?: Array<QueryParam>): string {
  let url: string = BASE_URL + path;
  if (params !== undefined && params.length > 0) {
    let parts: Array<string> = [];
    for (let i = 0; i < params.length; i++) {
      let p = params[i];
      parts.push(encodeURIComponent(p.key) + '=' + encodeURIComponent(String(p.value)));
    }
    url = url + '?' + parts.join('&');
  }
  return url;
}

function getOptions(): HttpPoolRequestOptions {
  return { method: http.RequestMethod.GET };
}

function postOptions(body: object): HttpPoolRequestOptions {
  return {
    method: http.RequestMethod.POST,
    extraData: body
  };
}

function buildRcpRequest(url: string, options: HttpPoolRequestOptions): rcp.Request {
  let methodStr: string = 'GET';
  if (options.method === http.RequestMethod.POST) {
    methodStr = 'POST';
  }
  let request: rcp.Request = new rcp.Request(url, methodStr);
  if (methodStr == 'POST') {
    request.content = options.extraData
  }
  return request;
}

async function fetchJson<T>(url: string, options: HttpPoolRequestOptions): Promise<T> {
  let request: rcp.Request = buildRcpRequest(url, options);
  // 如果已登录，则添加 cookie
  if (authStore.isLoggedIn()) {
    request.headers = {
      'cookie': 'token=' + authStore.getToken()
    }
  }
  let res: T = await rcpClient.request<T>(request);
  return res;
}

async function requestAndUnwrap<T>(url: string, options: HttpPoolRequestOptions): Promise<T> {
  let res: ApiResponse<T> = await fetchJson<ApiResponse<T>>(url, options);
  if (res.code !== 0) {
    throw new Error(res.message);
  }
  return res.data;
}

// ---------- 二、版本 / 主题 ----------

/** 获取站点版本 */
export function getVersion(): Promise<VersionData> {
  return fetchJson<VersionRawResponse>(buildUrl('/version'), getOptions()).then((resp: VersionRawResponse) => {
    if (resp.code !== 0) {
      throw new Error('getVersion failed, code=' + String(resp.code));
    }
    let data: VersionData = {
      version: resp.version,
      commitTime: resp.description !== undefined ? resp.description : ''
    };
    return data;
  });
}

// ---------- 三、等级 / 积分等级 ----------

/** 获取等级列表 */
export function getLevelList(): Promise<Array<LevelItemData>> {
  return fetchJson<LevelListRawResponse>(buildUrl('/level/list'), getOptions()).then(
    (resp: LevelListRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getLevelList failed, code=' + String(resp.code));
      }
      let list: Array<LevelItemData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: LevelListRawItem = resp.list[i];
        let item: LevelItemData = {
          level: raw.level,
          name: raw.name,
          minScore: 0,
          maxScore: raw.exp
        };
        list.push(item);
      }
      return list;
    }
  );
}

/** 获取等级详情 */
export function getLevelInfo(): Promise<LevelInfoData> {
  return fetchJson<LevelInfoRawResponse>(buildUrl('/level/info'), getOptions()).then(
    (resp: LevelInfoRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getLevelInfo failed, code=' + String(resp.code));
      }
      let current: LevelInfoRawItem = resp.levelInfo;
      let next: LevelInfoRawItem = resp.nextLevel;
      let percent: number = 0;
      if (next.exp > 0) {
        percent = (current.currentExp * 100) / next.exp;
      }
      let data: LevelInfoData = {
        uid: 0,
        level: current.level,
        score: current.currentExp,
        nextLevelScore: next.exp,
        percent: percent
      };
      return data;
    }
  );
}

// ---------- 四、用户基础信息 / 统计 ----------

/** 获取当前登录用户信息 */
export function getUserInfo(): Promise<UserInfoData> {
  return fetchJson<UserInfoRawResponse>(buildUrl('/user/info'), getOptions()).then(
    (resp: UserInfoRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getUserInfo failed, code=' + String(resp.code));
      }
      let raw: UserInfoRaw = resp.info;
      let data: UserInfoData = {
        uid: raw.uid,
        nickname: raw.nickname,
        avatar: raw.avatar,
        level: 0,
        score: raw.exp,
        signature: raw.sign,
        createdAt: '',
        role: raw.role,
        exp: raw.exp,
        contribution: raw.contribution,
        sex: raw.sex,
        birthday: raw.birthday
      };
      return data;
    }
  );
}

/** 获取当前用户积分 */
export function getUserScore(): Promise<UserScoreData> {
  return fetchJson<UserScoreRawResponse>(buildUrl('/user/score'), getOptions()).then(
    (resp: UserScoreRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getUserScore failed, code=' + String(resp.code));
      }
      // 文档结构无法直接映射积分明细，使用占位值
      let data: UserScoreData = {
        uid: 0,
        score: 0,
        contribution: 0,
        level: 0,
        nextLevelScore: 0
      };
      return data;
    }
  );
}

/** 获取指定用户信息 */
export function getUserUserInfo(uid: number): Promise<UserBriefData> {
  return fetchJson<UserDetailRawResponse>(
    buildUrl('/user/user-info', [{ key: 'uid', value: uid }]),
    getOptions()
  ).then((resp: UserDetailRawResponse) => {
    if (resp.code !== 0) {
      throw new Error('getUserUserInfo failed, code=' + String(resp.code));
    }
    let raw: UserDetailRaw = resp.info;
    let data: UserBriefData = {
      uid: raw.uid,
      nickname: raw.nickname,
      avatar: raw.avatar,
      level: 0
    };
    return data;
  });
}

/** 获取用户数据统计，不传 uid 为当前用户 */
export function getUserDataCount(uid?: number): Promise<UserDataCountData> {
  let params: Array<QueryParam> | undefined = undefined;
  if (uid !== undefined) {
    params = [{ key: 'uid', value: uid }];
  }
  return fetchJson<UserDataCountRawResponse>(buildUrl('/user/data/count', params), getOptions()).then(
    (resp: UserDataCountRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getUserDataCount failed, code=' + String(resp.code));
      }
      let raw: UserDataCountRaw = resp.data;
      let data: UserDataCountData = {
        postCount: raw.post,
        favoriteCount: raw.favorite,
        followCount: raw.follow,
        fansCount: raw.fans
      };
      return data;
    }
  );
}

// ---------- 五、用户关系 ----------

/** 关注列表 */
export function getFollowList(uid: number, page: number, pageSize: number): Promise<PagedListData<UserBriefData>> {
  let params: Array<QueryParam> = [
    { key: 'uid', value: uid },
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  return fetchJson<UserListRawResponse>(buildUrl('/user/follow/list', params), getOptions()).then(
    (resp: UserListRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getFollowList failed, code=' + String(resp.code));
      }
      let list: Array<UserBriefData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: UserListRawItem = resp.list[i];
        let item: UserBriefData = {
          uid: raw.uid,
          nickname: raw.nickname,
          avatar: raw.avatar,
          level: 0,
          fansCount: raw.fans,
          followCount: raw.follow,
          postCount: raw.posts,
          isFollowed: raw.focusHe
        };
        list.push(item);
      }
      let result: PagedListData<UserBriefData> = {
        list: list,
        page: page,
        pageSize: pageSize,
        total: list.length
      };
      return result;
    }
  );
}

/** 粉丝列表 */
export function getFansList(uid: number, page: number, pageSize: number): Promise<PagedListData<UserBriefData>> {
  let params: Array<QueryParam> = [
    { key: 'uid', value: uid },
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  return fetchJson<UserListRawResponse>(buildUrl('/user/fans/list', params), getOptions()).then(
    (resp: UserListRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getFansList failed, code=' + String(resp.code));
      }
      let list: Array<UserBriefData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: UserListRawItem = resp.list[i];
        let item: UserBriefData = {
          uid: raw.uid,
          nickname: raw.nickname,
          avatar: raw.avatar,
          level: 0,
          fansCount: raw.fans,
          followCount: raw.follow,
          postCount: raw.posts,
          isFollowed: raw.focusMe
        };
        list.push(item);
      }
      let result: PagedListData<UserBriefData> = {
        list: list,
        page: page,
        pageSize: pageSize,
        total: list.length
      };
      return result;
    }
  );
}

// ---------- 六、搜索 ----------

/** 搜索用户 */
export function searchUser(keyword: string): Promise<PagedListData<UserBriefData>> {
  return fetchJson<SearchUserRawResponse>(
    buildUrl('/user/search', [{ key: 'keyword', value: keyword }]),
    getOptions()
  ).then((resp: SearchUserRawResponse) => {
    if (resp.code !== 0) {
      throw new Error('searchUser failed, code=' + String(resp.code));
    }
    let list: Array<UserBriefData> = [];
    let i: number;
    for (i = 0; i < resp.list.length; i++) {
      let raw: SearchUserRawItem = resp.list[i];
      let item: UserBriefData = {
        uid: raw.uid,
        nickname: raw.nickname,
        avatar: raw.avatar,
        level: 0
      };
      list.push(item);
    }
    let result: PagedListData<UserBriefData> = {
      list: list,
      page: 1,
      pageSize: list.length,
      total: list.length
    };
    return result;
  });
}

/** 搜索帖子 */
export function searchPost(keyword: string, id: number): Promise<PostSearchData> {
  let params: Array<QueryParam> = [
    { key: 'keyword', value: keyword },
    { key: 'id', value: id }
  ];
  return fetchJson<SearchPostRawResponse>(buildUrl('/post/search', params), getOptions()).then(
    (resp: SearchPostRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('searchPost failed, code=' + String(resp.code));
      }
      let list: Array<PostSearchItemData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: SearchPostRawItem = resp.list[i];
        let authorBrief: UserBriefData = {
          uid: raw.author.uid,
          nickname: raw.author.nickname,
          avatar: raw.author.avatar,
          level: 0
        };
        let item: PostSearchItemData = {
          id: raw.id,
          title: raw.title,
          summary: '',
          author: authorBrief,
          createdAt: raw.postTime
        };
        list.push(item);
      }
      let data: PostSearchData = {
        list: list,
        nextId: resp.searchId
      };
      return data;
    }
  );
}

// ---------- 七、帖子列表 / 个人内容 ----------

/** 首页帖子简要列表 */
export async function getPostListBrief(
  page: number,
  pageSize: number,
  order?: number,
  filter?: number
): Promise<PagedListData<PostBriefItemData>> {
  let params: Array<QueryParam> = [
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  if (order !== undefined) {
    params.push({ key: 'order', value: order });
  }
  if (filter !== undefined) {
    params.push({ key: 'filter', value: filter });
  }
  let resp: PostListBriefRawResponse = await fetchJson<PostListBriefRawResponse>(
    buildUrl('/post/list/brief', params),
    getOptions()
  );
  if (resp.code !== 0) {
    throw new Error('getPostListBrief failed, code=' + String(resp.code));
  }
  let items: Array<PostBriefItemData> = [];
  let i: number;
  for (i = 0; i < resp.result.length; i++) {
    let raw: PostListBriefRawItem = resp.result[i];
    let authorBrief: UserBriefData;
    if (raw.author !== undefined) {
      authorBrief = {
        uid: raw.author.uid,
        nickname: raw.author.nickname,
        avatar: raw.author.avatar,
        level: 0
      };
    } else {
      authorBrief = {
        uid: 0,
        nickname: '',
        avatar: '',
        level: 0
      };
    }
    let item: PostBriefItemData = {
      id: raw.id,
      title: raw.title,
      summary: raw.content,
      author: authorBrief,
      likeCount: raw.likes !== undefined ? raw.likes : 0,
      replyCount: raw.replies !== undefined ? raw.replies : 0,
      favoriteCount: 0,
      createdAt: raw.post_time,
      pictures: raw.pictures,
      readings: raw.readings
    };
    items.push(item);
  }
  let result: PagedListData<PostBriefItemData> = {
    list: items,
    page: page,
    pageSize: pageSize,
    total: resp.total
  };
  return result;
}

/** 用户发帖列表 */
export function getPostUserList(uid: number, page: number, pageSize: number): Promise<PagedListData<PostUserItemData>> {
  let params: Array<QueryParam> = [
    { key: 'uid', value: uid },
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  return fetchJson<PostUserListRawResponse>(buildUrl('/post/user/list', params), getOptions()).then(
    (resp: PostUserListRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getPostUserList failed, code=' + String(resp.code));
      }
      let list: Array<PostUserItemData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: PostUserListRawItem = resp.list[i];
        let item: PostUserItemData = {
          id: raw.id,
          title: raw.title,
          summary: raw.content,
          createdAt: raw.post_time,
          likeCount: raw.likes,
          replyCount: raw.replies
        };
        list.push(item);
      }
      let result: PagedListData<PostUserItemData> = {
        list: list,
        page: page,
        pageSize: pageSize,
        total: list.length
      };
      return result;
    }
  );
}

/** 帖子详情 */
export async function getPostDetail(id: number): Promise<PostDetailData> {
  let url: string = buildUrl('/post/detail/' + String(id));
  let resp: PostDetailRawResponse = await fetchJson<PostDetailRawResponse>(url, getOptions());
  if (resp.code !== 0) {
    throw new Error('getPostDetail failed, code=' + String(resp.code));
  }
  let raw: PostDetailRaw = resp.info;
  let authorBrief: UserBriefData = {
    uid: raw.author.uid,
    nickname: raw.author.nickname,
    avatar: raw.author.avatar,
    level: 0
  };
  let pictures: Array<string> = raw.primaryPictures.length > 0 ? raw.primaryPictures : raw.pictures;
  let data: PostDetailData = {
    id: raw.id,
    title: raw.title,
    content: raw.content,
    author: authorBrief,
    pictures: pictures,
    createdAt: raw.post_time,
    likeCount: raw.likes,
    replyCount: raw.replies,
    readings: raw.readings
  };
  return data;
}

function mapReplySubItem(raw: PostCommentRawSubReply): ReplySubItemData {
  let author: UserBriefData = {
    uid: raw.author.uid,
    nickname: raw.author.nickname,
    avatar: raw.author.avatar,
    level: 0
  };
  let mention: ReplyMentionData | undefined = undefined;
  if (raw.mention !== null && raw.mention !== undefined) {
    let m: PostCommentRawMention = raw.mention;
    let floorAuthor: UserBriefData = {
      uid: m.author.uid,
      nickname: m.author.nickname,
      avatar: m.author.avatar,
      level: 0
    };
    mention = {
      author: floorAuthor,
      floor: { id: m.floor.id, content: m.floor.content, time: m.floor.time }
    };
  }
  return {
    id: raw.id,
    content: raw.content,
    time: raw.time,
    author: author,
    mention: mention
  };
}

function mapCommentRawToItem(raw: PostCommentRawItem): PostCommentItemData {
  let userBrief: UserBriefData = {
    uid: raw.author.uid,
    nickname: raw.author.nickname,
    avatar: raw.author.avatar,
    level: 0
  };
  let replies: Array<ReplySubItemData> = [];
  let j: number;
  for (j = 0; j < raw.replies.length; j++) {
    replies.push(mapReplySubItem(raw.replies[j]));
  }
  let item: PostCommentItemData = {
    id: raw.floorId,
    user: userBrief,
    content: raw.content,
    createdAt: raw.time,
    floor: raw.floor,
    isTop: raw.isTop,
    likes: raw.likes,
    liked: raw.liked,
    replies: replies.length > 0 ? replies : undefined
  };
  return item;
}

/** 帖子评论/楼层回复列表（topList 置顶 + list 普通楼层） */
export async function getPostCommentList(
  id: number,
  page: number,
  pageSize: number
): Promise<ReplyListData> {
  let params: Array<QueryParam> = [
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize },
    { key: 'order', value: 0 }
  ];
  let url: string = buildUrl('/reply/list/' + String(id), params);
  let resp: PostCommentRawResponse = await fetchJson<PostCommentRawResponse>(url, getOptions());
  if (resp.code !== 0) {
    throw new Error('getPostCommentList failed, code=' + String(resp.code));
  }
  let topList: Array<PostCommentItemData> = [];
  let i: number;
  for (i = 0; i < resp.topList.length; i++) {
    topList.push(mapCommentRawToItem(resp.topList[i]));
  }
  let list: Array<PostCommentItemData> = [];
  for (i = 0; i < resp.list.length; i++) {
    list.push(mapCommentRawToItem(resp.list[i]));
  }
  let result: ReplyListData = {
    topList: topList,
    list: list,
    total: resp.total,
    page: page,
    pageSize: pageSize
  };
  return result;
}

// ---------- 八、通知 / 消息 ----------

/** 获取通知计数 */
export function getNoticeCount(): Promise<NoticeCountData> {
  return fetchJson<NoticeCountRawResponse>(buildUrl('/notice/count'), getOptions()).then(
    (resp: NoticeCountRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getNoticeCount failed, code=' + String(resp.code));
      }
      let inner: NoticeCountRawInner = resp.count;
      let data: NoticeCountData = {
        reply: inner.replies,
        at: inner.at,
        like: inner.likes,
        system: inner.notice,
        site: inner.message,
        service: inner.chats
      };
      return data;
    }
  );
}

/** 回复通知列表 */
export function getNoticeReplyList(page: number, pageSize: number): Promise<PagedListData<NoticeReplyItemData>> {
  let params: Array<QueryParam> = [
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  return fetchJson<NoticeReplyRawResponse>(buildUrl('/notice/reply/list', params), getOptions()).then(
    (resp: NoticeReplyRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getNoticeReplyList failed, code=' + String(resp.code));
      }
      let list: Array<NoticeReplyItemData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: NoticeReplyRawItem = resp.list[i];
        let fromUser: UserBriefData = {
          uid: raw.user.uid,
          nickname: raw.user.nickname,
          avatar: raw.user.avatar,
          level: 0
        };
        let item: NoticeReplyItemData = {
          id: i,
          postId: raw.postId,
          replyId: 0,
          fromUser: fromUser,
          content: raw.content,
          createdAt: raw.time,
          read: false
        };
        list.push(item);
      }
      let result: PagedListData<NoticeReplyItemData> = {
        list: list,
        page: page,
        pageSize: pageSize,
        total: list.length
      };
      return result;
    }
  );
}

// ---------- 八（续）、私信 / 聊天 ----------

/** 私信列表原始项中的用户 */
interface ChatListRawUser {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  auth: number;
  authentication: string;
}

/** 私信列表原始项 */
interface ChatListRawItem {
  isTop: boolean;
  unread: number;
  time: string;
  lastMessage: string;
  user: ChatListRawUser;
}

/** 私信列表原始响应 */
interface ChatListRawResponse {
  code: number;
  list: Array<ChatListRawItem>;
  token?: string;
}

/** 私信历史原始项 */
interface ChatHistoryRawItem {
  id: number;
  from: number;
  to: number;
  content: string;
  time: string;
  type: number;
  status: number;
}

/** 私信历史原始响应 */
interface ChatHistoryRawResponse {
  code: number;
  list: Array<ChatHistoryRawItem>;
}

/** 私信会话列表 */
export function getChatList(): Promise<ChatListResponse> {
  return fetchJson<ChatListRawResponse>(buildUrl('/chat/list'), getOptions()).then(
    (resp: ChatListRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getChatList failed, code=' + String(resp.code));
      }
      let list: Array<ChatListItemData> = [];
      for (let i = 0; i < resp.list.length; i++) {
        let raw: ChatListRawItem = resp.list[i];
        let user: ChatListUserData = {
          uid: raw.user.uid,
          nickname: raw.user.nickname,
          avatar: raw.user.avatar,
          exp: raw.user.exp,
          auth: raw.user.auth,
          authentication: raw.user.authentication
        };
        let item: ChatListItemData = {
          isTop: raw.isTop,
          unread: raw.unread,
          time: raw.time,
          lastMessage: raw.lastMessage,
          user: user
        };
        list.push(item);
      }
      let result: ChatListResponse = {
        code: resp.code,
        list: list,
        token: resp.token
      };
      return result;
    }
  );
}

/** 私信历史（与某用户的聊天记录） */
export function getChatHistory(uid: number, id: number = 0): Promise<ChatHistoryResponse> {
  let params: Array<QueryParam> = [
    { key: 'id', value: String(id) },
    { key: 'uid', value: String(uid) }
  ];
  return fetchJson<ChatHistoryRawResponse>(buildUrl('/chat/history', params), getOptions()).then(
    (resp: ChatHistoryRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getChatHistory failed, code=' + String(resp.code));
      }
      let list: Array<ChatHistoryItemData> = [];
      for (let i = 0; i < resp.list.length; i++) {
        let raw: ChatHistoryRawItem = resp.list[i];
        let item: ChatHistoryItemData = {
          id: raw.id,
          from: raw.from,
          to: raw.to,
          content: raw.content,
          time: raw.time,
          type: raw.type,
          status: raw.status
        };
        list.push(item);
      }
      let result: ChatHistoryResponse = { code: resp.code, list: list };
      return result;
    }
  );
}

/** 私信最新消息（某条消息之后的新消息） */
export function getChatNewest(uid: number, id: number): Promise<ChatNewestResponse> {
  let params: Array<QueryParam> = [
    { key: 'uid', value: String(uid) },
    { key: 'id', value: String(id) }
  ];
  return fetchJson<ChatHistoryRawResponse>(buildUrl('/chat/chat-newest', params), getOptions()).then(
    (resp: ChatHistoryRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getChatNewest failed, code=' + String(resp.code));
      }
      let list: Array<ChatHistoryItemData> = [];
      for (let i = 0; i < resp.list.length; i++) {
        let raw: ChatHistoryRawItem = resp.list[i];
        let item: ChatHistoryItemData = {
          id: raw.id,
          from: raw.from,
          to: raw.to,
          content: raw.content,
          time: raw.time,
          type: raw.type,
          status: raw.status
        };
        list.push(item);
      }
      let result: ChatNewestResponse = { code: resp.code, list: list };
      return result;
    }
  );
}

// ---------- 九、签到 / 贡献 ----------

/** 是否已签到 */
export function getSignSigned(): Promise<SignSignedData> {
  return fetchJson<SignSignedRawResponse>(buildUrl('/sign/signed'), getOptions()).then(
    (resp: SignSignedRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getSignSigned failed, code=' + String(resp.code));
      }
      let data: SignSignedData = {
        signed: resp.signed,
        todayScore: 0,
        continueDays: 0
      };
      return data;
    }
  );
}

/** 贡献排行榜 */
export function getContributionRank(page: number, pageSize: number, sort?: string): Promise<PagedListData<ContributionRankItemData>> {
  let params: Array<QueryParam> = [
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize }
  ];
  if (sort !== undefined) {
    params.push({ key: 'sort', value: sort });
  }
  return fetchJson<ContributionRankRawResponse>(buildUrl('/contribution/rank', params), getOptions()).then(
    (resp: ContributionRankRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getContributionRank failed, code=' + String(resp.code));
      }
      let list: Array<ContributionRankItemData> = [];
      let i: number;
      for (i = 0; i < resp.list.length; i++) {
        let raw: ContributionRankRawItem = resp.list[i];
        let item: ContributionRankItemData = {
          rank: i + 1,
          uid: raw.uid,
          nickname: raw.nickname,
          avatar: raw.avatar,
          score: raw.contribution
        };
        list.push(item);
      }
      let result: PagedListData<ContributionRankItemData> = {
        list: list,
        page: page,
        pageSize: pageSize,
        total: resp.total
      };
      return result;
    }
  );
}

// ---------- 十、订单 / 地址 ----------

/** 订单列表，status -1 为全部 */
export function getOrderList(page: number, pageSize: number, status: number): Promise<PagedListData<OrderItem>> {
  let params: Array<QueryParam> = [
    { key: 'page', value: page },
    { key: 'pageSize', value: pageSize },
    { key: 'status', value: status }
  ];
  return requestAndUnwrap<PagedListData<OrderItem>>(buildUrl('/order/list', params), getOptions());
}

/** 收货地址列表 */
export function getAddressList(): Promise<Array<AddressItemData>> {
  return requestAndUnwrap<Array<AddressItemData>>(buildUrl('/address/list'), getOptions());
}

// ---------- 十一、登录 / 认证 ----------

/** 获取验证码 */
export function getAuthCode(): Promise<AuthCodeData> {
  return fetchJson<AuthCodeRawResponse>(buildUrl('/auth/code'), getOptions()).then(
    (resp: AuthCodeRawResponse) => {
      if (resp.code !== 0) {
        throw new Error('getAuthCode failed, code=' + String(resp.code));
      }
      let data: AuthCodeData = {
        // 注意：验证码区分大小写，这里保留服务端原始大小写
        publicKey: resp.publicKey,
        privateKey: resp.privateKey,
        // 接口文档约定有效期为 300s
        expireSeconds: 300
      };
      return data;
    }
  );
}

/** 校验验证码请求体 */
export interface AuthValidateBody {
  code: string;
  key: string;
}

/** 校验验证码（需在请求头携带 Hash，由调用方或拦截器处理） */
export function postAuthValidate(body: AuthValidateBody): Promise<AuthValidateData> {
  return fetchJson<AuthValidateRawError | AuthValidateRawSuccess>(
    buildUrl('/auth/validate'),
    postOptions(body)
  ).then((resp: AuthValidateRawError | AuthValidateRawSuccess) => {
    // code === 0 视为通过，此时 resp 结构为 AuthValidateRawSuccess
    if ((resp as AuthValidateRawError).code !== 0) {
      let data: AuthValidateData = {
        validated: false
      };
      return data;
    }
    let success: AuthValidateRawSuccess = resp as AuthValidateRawSuccess;
    let data: AuthValidateData = {
      validated: true,
      bind: success.bind,
      platformUid: success.platformUid,
      site: success.site,
      uid: success.uid,
      auth: success.auth
    };
    return data;
  });
}

/** 三方登录校验 / 绑定请求体 */
export interface AuthValidateLoginBody {
  code: string;
  key: string;
  site: string;
  uid: string;
  platformUid: number;
  auth: string;
}

/** 三方登录校验 / 绑定（需在请求头携带 Hash） */
export function postAuthValidateLogin(body: AuthValidateLoginBody): Promise<AuthLoginData> {
  return fetchJson<AuthLoginRawResponse>(
    buildUrl('/auth/validate-login'),
    postOptions(body)
  ).then((resp: AuthLoginRawResponse) => {
    if (resp.code !== 0) {
      throw new Error('postAuthValidateLogin failed, code=' + String(resp.code));
    }
    let data: AuthLoginData = {
      uid: resp.uid,
      token: resp.token,
      nickname: '',
      avatar: ''
    };
    return data;
  });
}
