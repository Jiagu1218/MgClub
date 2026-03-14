import { getChatHistory, getUserInfo } from '../common/network';
import type { ChatHistoryItemData, ChatHistoryResponse } from '../common/network';

@ObservedV2
export class ChatDetailViewModel {
  @Trace targetUid: number = 0;
  @Trace targetName: string = '聊天';
  @Trace targetAvatar: string = '';
  @Trace myNickname: string = '我';
  @Trace myAvatar: string = '';
  @Trace messages: Array<ChatHistoryItemData> = [];
  @Trace loading: boolean = false;
  @Trace errorMessage: string = '';

  init(uid: number, name?: string, avatar?: string): void {
    this.targetUid = uid;
    this.targetName = (name !== undefined && name.length > 0) ? name : '聊天';
    this.targetAvatar = (avatar !== undefined) ? avatar : '';
  }

  async loadMyInfo(): Promise<void> {
    try {
      let user = await getUserInfo();
      this.myNickname = user.nickname;
      this.myAvatar = user.avatar !== undefined ? user.avatar : '';
    } catch (_e) {
      this.myNickname = '我';
      this.myAvatar = '';
    }
  }

  async loadHistory(): Promise<void> {
    if (this.targetUid <= 0) {
      return;
    }
    this.loading = true;
    this.errorMessage = '';
    try {
      let resp: ChatHistoryResponse = await getChatHistory(this.targetUid, 0);
      this.messages = resp.list;
    } catch (e) {
      this.errorMessage = e instanceof Error ? e.message : String(e);
    } finally {
      this.loading = false;
    }
  }
}
