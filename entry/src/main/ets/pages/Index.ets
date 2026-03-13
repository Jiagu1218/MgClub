import { MainTabPage } from './MainTabPage';
import { CustomTransition, AnimateCallback } from '../common/CustomNavigationUtils';

@Entry
@ComponentV2
struct Index {
  private pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      MainTabPage()
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .customNavContentTransition(
      (from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation)
        : NavigationAnimatedTransition | undefined => {
        // 如果都是默认内容，不做自定义动画
        if (from.index === -1 && to.index === -1) {
          return undefined;
        }

        let animation: NavigationAnimatedTransition = {
          timeout: 1000,
          transition: (transitionProxy: NavigationTransitionProxy) => {
            let callbacks: AnimateCallback = CustomTransition.getInstance().getAnimateParam('PostDetailPage');

            if (operation === NavigationOperation.PUSH) {
              if (callbacks.start !== undefined) {
                callbacks.start(true, false);
              }
              this.getUIContext().animateTo({
                duration: 300,
                curve: Curve.Friction,
                onFinish: () => {
                  if (callbacks.finish !== undefined) {
                    callbacks.finish(true, false);
                  }
                  transitionProxy.finishTransition();
                }
              }, () => { });
            } else if (operation === NavigationOperation.POP) {
              if (callbacks.start !== undefined) {
                callbacks.start(false, true);
              }
              this.getUIContext().animateTo({
                duration: 300,
                curve: Curve.Friction,
                onFinish: () => {
                  if (callbacks.finish !== undefined) {
                    callbacks.finish(false, true);
                  }
                  transitionProxy.finishTransition();
                }
              }, () => { });
            } else {
              transitionProxy.finishTransition();
            }
          }
        };

        return animation;
      })
  }
}