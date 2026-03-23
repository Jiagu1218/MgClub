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

        // 仅处理“主页默认内容 <-> 帖子详情”这条转场链路。
        // 否则会把详情页内部再跳转（如图片查看页）的 POP 也当成详情离场，导致返回空白。
        let isHomeToSubPush: boolean = operation === NavigationOperation.PUSH && from.index === -1 && to.index !== -1;
        let isSubToHomePop: boolean = operation === NavigationOperation.POP && from.index !== -1 && to.index === -1;
        if (!isHomeToSubPush && !isSubToHomePop) {
          return undefined;
        }

        let callbacks: AnimateCallback = CustomTransition.getInstance().getAnimateParam('PostDetailPage');
        // 仅对帖子详情页使用自定义翻页动画，其他二级页（如登录页）使用系统默认
        if (callbacks.start === undefined && callbacks.finish === undefined) {
          return undefined;
        }

        let animation: NavigationAnimatedTransition = {
          timeout: 1000,
          transition: (transitionProxy: NavigationTransitionProxy) => {
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