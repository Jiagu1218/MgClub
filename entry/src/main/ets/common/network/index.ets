/**
 * 网络层统一导出
 * - HttpConnectionPool：HTTP 请求连接池（高可用、高性能）
 * - HttpPoolTypes：连接池与请求相关类型
 * - api：2550505.com 接口封装与类型
 */

export {
  HttpConnectionPool,
  getDefaultHttpPool,
  requestJson
} from './HttpConnectionPool';

export {
  SessionPool
} from './SessionPool';

export {
  RcpClient
} from './RcpClient';

export type {
  RcpClientConfig
} from './RcpClient';

export type {
  HttpPoolConfig,
  HttpRequestOverrides,
  HttpPoolRequestOptions
} from './HttpPoolTypes';

export {
  getVersion,
  getLevelList,
  getLevelInfo,
  getUserInfo,
  getUserScore,
  getUserUserInfo,
  getUserDataCount,
  getFollowList,
  getFansList,
  searchUser,
  searchPost,
  getPostListBrief,
  getPostUserList,
  getNoticeCount,
  getNoticeReplyList,
  getSignSigned,
  getContributionRank,
  getOrderList,
  getAddressList,
  getAuthCode,
  postAuthValidate,
  postAuthValidateLogin
} from './api/ApiClient';

export type {
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
  NoticeCountData,
  NoticeReplyItemData,
  SignSignedData,
  ContributionRankItemData,
  OrderItem,
  OrderItemData,
  AddressItemData,
  AuthCodeData,
  AuthValidateData,
  AuthLoginData,
  QueryParam,
  AuthValidateBody,
  AuthValidateLoginBody
} from './api';
