/**
 * 2550505.com API 模块
 * - ApiTypes：请求/响应类型
 * - ApiClient：接口请求方法
 */

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
  PostPictureData,
  PostUserItemData,
  PostSearchData,
  PostSearchItemData,
  PostDetailData,
  PostCommentItemData,
  ReplyListData,
  ReplySubItemData,
  ReplyMentionData,
  ReplyMentionFloor,
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
  OrderItemData,
  AddressItemData,
  AuthCodeData,
  AuthValidateData,
  AuthLoginData
} from './ApiTypes';

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
  getPostFavoriteList,
  getPostDetail,
  getPostCommentList,
  getNoticeCount,
  getNoticeReplyList,
  getChatList,
  getChatHistory,
  getChatNewest,
  getSignSigned,
  getContributionRank,
  getOrderList,
  getAddressList,
  getAuthCode,
  postAuthValidate,
  postAuthValidateLogin
} from './ApiClient';

export type { QueryParam, AuthValidateBody, AuthValidateLoginBody } from './ApiClient';
