import { getChatList } from '../common/network';
import type { ChatListItemData, ChatListResponse } from '../common/network';

@ObservedV2
export class MessageListViewModel {
  @Trace chatList: Array<ChatListItemData> = [];
  @Trace loading: boolean = false;
  @Trace errorMessage: string = '';

  async loadChatList(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    try {
      let resp: ChatListResponse = await getChatList();
      this.chatList = resp.list;
    } catch (e) {
      this.errorMessage = e instanceof Error ? e.message : String(e);
    } finally {
      this.loading = false;
    }
  }
}
