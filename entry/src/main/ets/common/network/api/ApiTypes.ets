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
  // 以下字段用于“我的”页面展示
  role?: number;
  exp?: number;
  contribution?: number;
  sex?: number;
  birthday?: number;
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
  pictures: Array<string>;
  readings: number;
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

/** 私信会话列表中的用户信息 */
export interface ChatListUserData {
  uid: number;
  nickname: string;
  avatar: string;
  exp: number;
  auth: number;
  authentication: string;
}

/** 私信会话列表项 */
export interface ChatListItemData {
  isTop: boolean;
  unread: number;
  time: string;
  lastMessage: string;
  user: ChatListUserData;
}

/** 私信会话列表响应 */
export interface ChatListResponse {
  code: number;
  list: Array<ChatListItemData>;
  token?: string;
}

/** 私信历史单条消息 */
export interface ChatHistoryItemData {
  id: number;
  from: number;
  to: number;
  content: string;
  time: string;
  type: number;
  status: number;
}

/** 私信历史响应 */
export interface ChatHistoryResponse {
  code: number;
  list: Array<ChatHistoryItemData>;
}

/** 私信最新消息响应（与历史结构一致） */
export interface ChatNewestResponse {
  code: number;
  list: Array<ChatHistoryItemData>;
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

/** 验证码 data（来自 /auth/code） */
export interface AuthCodeData {
  // 注意：后端字段名为 publicKey / privateKey，验证码区分大小写，前端不要改动大小写
  publicKey: string;
  privateKey: string;
  expireSeconds: number;
}

/** 校验验证码 data（/auth/validate 返回结果的抽象） */
export interface AuthValidateData {
  // 是否校验通过（code === 0）
  validated: boolean;
  // 以下字段仅在 code === 0 时有效，用于后续 /auth/validate-login
  bind?: boolean;
  platformUid?: number;
  site?: string;
  uid?: string;
  auth?: string;
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

/** 帖子详情 data（包含正文、图片等） */
export interface PostDetailData {
  id: number;
  title: string;
  content: string;
  author: UserBriefData;
  pictures: Array<string>;
  createdAt: string;
  likeCount: number;
  replyCount: number;
  readings: number;
}

/** 楼层回复中的 @ 引用（被引用楼层摘要） */
export interface ReplyMentionFloor {
  id: number;
  content: string;
  time: string;
}

/** 楼层回复中的 @ 引用 */
export interface ReplyMentionData {
  author: UserBriefData;
  floor: ReplyMentionFloor;
}

/** 楼层下的子回复项（楼中楼） */
export interface ReplySubItemData {
  id: number;
  content: string;
  time: string;
  author: UserBriefData;
  mention?: ReplyMentionData;
}

/** 帖子评论/楼层项（与 /reply/list 一致：topList 置顶 + list 普通楼层） */
export interface PostCommentItemData {
  id: number;
  user: UserBriefData;
  content: string;
  createdAt: string;
  /** 楼层号 */
  floor?: number;
  /** 是否置顶 */
  isTop?: boolean;
  /** 点赞数 */
  likes?: number;
  /** 当前用户是否已点赞 */
  liked?: boolean;
  /** 该楼层下的子回复 */
  replies?: Array<ReplySubItemData>;
}

/** 楼层回复列表接口返回（topList 置顶，list 普通列表） */
export interface ReplyListData {
  topList: Array<PostCommentItemData>;
  list: Array<PostCommentItemData>;
  total: number;
  page: number;
  pageSize: number;
}
