import { HomePage } from './HomePage';
import { DiscoverPage } from './DiscoverPage';
import { MessagePage } from './MessagePage';
import { ProfilePage } from './ProfilePage';

@ComponentV2
export struct MainTabPage {
  @Local currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar('首页')

        TabContent() {
          DiscoverPage()
        }
        .tabBar('发现')

        TabContent() {
          MessagePage()
        }
        .tabBar('消息')

        TabContent() {
          ProfilePage()
        }
        .tabBar('我的')
      }
      .vertical(false)
      .barPosition(BarPosition.End)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
  }
}

