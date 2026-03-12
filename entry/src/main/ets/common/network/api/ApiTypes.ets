/**
 * 2550505.com 接口请求/响应类型定义
 * 依据 2550505-api-doc.md 整理，响应结构为 { code, message, data }
 */

/** 通用 API 响应壳 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/** 版本接口 data */
export interface VersionData {
  version: string;
  commitTime: string;
}

/** 等级项 */
export interface LevelItemData {
  level: number;
  name: string;
  minScore: number;
  maxScore: number;
}

/** 等级详情 data */
export interface LevelInfoData {
  uid: number;
  level: number;
  score: number;
  nextLevelScore: number;
  percent: number;
}

/** 当前用户信息 data */
export interface UserInfoData {
  uid: number;
  nickname: string;
  avatar: string;
  level: number;
  score: number;
  signature: string;
  createdAt: string;
}

/** 用户积分 data */
export interface UserScoreData {
  uid: number;
  score: number;
  contribution: number;
  level: number;
  nextLevelScore: number;
}

/** 用户简要信息（列表项等） */
export interface UserBriefData {
  uid: number;
  nickname: string;
  avatar: string;
  level: number;
  fansCount?: number;
  followCount?: number;
  postCount?: number;
  isFollowed?: boolean;
}

/** 用户数据统计 data */
export interface UserDataCountData {
  postCount: number;
  favoriteCount: number;
  followCount: number;
  fansCount: number;
}

/** 分页列表通用 data */
export interface PagedListData<T> {
  list: Array<T>;
  page: number;
  pageSize: number;
  total: number;
}

/** 帖子简要项 */
export interface PostBriefItemData {
  id: number;
  title: string;
  summary: string;
  author: UserBriefData;
  likeCount: number;
  replyCount: number;
  favoriteCount: number;
  createdAt: string;
}

/** 帖子用户列表项 */
export interface PostUserItemData {
  id: number;
  title: string;
  summary: string;
  createdAt: string;
  likeCount: number;
  replyCount: number;
}

/** 通知计数 data */
export interface NoticeCountData {
  reply: number;
  at: number;
  like: number;
  system: number;
  site: number;
  service: number;
}

/** 回复通知项 */
export interface NoticeReplyItemData {
  id: number;
  postId: number;
  replyId: number;
  fromUser: UserBriefData;
  content: string;
  createdAt: string;
  read: boolean;
}

/** 签到状态 data */
export interface SignSignedData {
  signed: boolean;
  todayScore: number;
  continueDays: number;
}

/** 贡献榜项 */
export interface ContributionRankItemData {
  rank: number;
  uid: number;
  nickname: string;
  avatar: string;
  score: number;
}

/** 订单项商品 */
export interface OrderItemData {
  skuId: string;
  name: string;
  quantity: number;
  price: number;
}

/** 订单项 */
export interface OrderItem {
  orderId: string;
  status: number;
  statusText: string;
  amount: number;
  createdAt: string;
  items: Array<OrderItemData>;
}

/** 收货地址项 */
export interface AddressItemData {
  id: number;
  receiver: string;
  phone: string;
  province: string;
  city: string;
  district: string;
  detail: string;
  isDefault: boolean;
}

/** 验证码 data */
export interface AuthCodeData {
  key: string;
  expireSeconds: number;
}

/** 校验验证码 data */
export interface AuthValidateData {
  validated: boolean;
}

/** 登录/绑定返回 data */
export interface AuthLoginData {
  uid: number;
  token: string;
  nickname: string;
  avatar: string;
}

/** 搜索帖子项 */
export interface PostSearchItemData {
  id: number;
  title: string;
  summary: string;
  author: UserBriefData;
  createdAt: string;
}

/** 搜索帖子 data（游标分页） */
export interface PostSearchData {
  list: Array<PostSearchItemData>;
  nextId: number;
}
