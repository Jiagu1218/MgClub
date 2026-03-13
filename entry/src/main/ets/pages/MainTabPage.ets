import { HomePage } from './HomePage';
import { DiscoverPage } from './DiscoverPage';
import { MessagePage } from './MessagePage';
import { ProfilePage } from './ProfilePage';
import { windowUtil } from '../common/WindowUtil';

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
    .height(LayoutPolicy.matchParent)
    // 组件层面做沉浸 + 避让：扩展到避让区，并按系统状态栏 / 导航条高度做 padding
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
    .padding({
      top: windowUtil.mainWindowInfo.avoidSystem !== undefined ?
        windowUtil.mainWindowInfo.avoidSystem.topRect.height + 'px' : '0px',
      bottom: windowUtil.mainWindowInfo.avoidNavigationIndicator !== undefined ?
        windowUtil.mainWindowInfo.avoidNavigationIndicator.bottomRect.height + 'px' : '0px'
    })
  }
}

