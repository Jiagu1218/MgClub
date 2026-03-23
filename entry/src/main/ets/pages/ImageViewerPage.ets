import { pageUiService } from '../common/PageUiService';
import { ImageViewerViewModel, ReboundTarget } from '../viewmodel/ImageViewerViewModel';

export interface ImageViewerRouteParams {
  images?: Array<string>;
  index?: number;
}

@ComponentV2
struct ImageViewerPage {
  @Local vm: ImageViewerViewModel = new ImageViewerViewModel();

  private popPage(): void {
    let navigationInfo: NavigationInfo = this.queryNavigationInfo() as NavigationInfo;
    if (navigationInfo === undefined || navigationInfo.pathStack === undefined) {
      return;
    }
    navigationInfo.pathStack.pop();
  }

  private getTopSafeHeight(): number {
    return this.vm.getTopSafeHeight();
  }

  private getBottomSafeHeight(): number {
    return this.vm.getBottomSafeHeight();
  }

  aboutToDisappear(): void {
    this.vm.dispose();
    void pageUiService.restoreDefaultSystemBar();
  }

  aboutToAppear(): void {
    void pageUiService.applyDarkOverlaySystemBar();
    this.vm.wakeToolbarAndSchedule();
  }

  private animateRebound(target: ReboundTarget | null): void {
    if (target === null) {
      return;
    }
    this.getUIContext().animateTo({
      duration: target.duration,
      curve: Curve.EaseOut
    }, () => {
      this.vm.applyReboundTarget(target);
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        if (this.vm.images.length > 0) {
          if (this.vm.zoomScale > 1) {
            Column() {
              Image(this.vm.images[this.vm.currentIndex])
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .draggable(false)
                .onComplete((event: ImageLoadResult) => {
                  this.vm.onImageLoaded(this.vm.images[this.vm.currentIndex], event.width, event.height);
                })
                .scale({ x: this.vm.zoomScale, y: this.vm.zoomScale })
                .translate({ x: this.vm.translateX, y: this.vm.translateY });
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onTouch((event: TouchEvent) => {
              this.animateRebound(this.vm.handleImageTouch(event));
            });
          } else {
            Swiper() {
              ForEach(this.vm.images, (url: string) => {
                Column() {
                  Image(url)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Contain)
                    .draggable(false)
                    .onComplete((event: ImageLoadResult) => {
                      this.vm.onImageLoaded(url, event.width, event.height);
                    })
                    .scale({ x: this.vm.zoomScale, y: this.vm.zoomScale })
                    .translate({ x: this.vm.translateX, y: this.vm.translateY });
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onTouch((event: TouchEvent) => {
                  this.animateRebound(this.vm.handleImageTouch(event));
                });
              })
            }
            .index(this.vm.currentIndex)
            .onChange((index: number) => {
              this.vm.onImageIndexChange(index);
            })
            .indicator(false)
            .width('100%')
            .height('100%');
          }
        } else {
          Column() {
            Text('暂无图片')
              .fontSize(14)
              .fontColor(0xFFFFFFFF)
              .opacity(0.8);
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        }

        Text((this.vm.currentIndex + 1) + ' / ' + this.vm.images.length)
          .fontSize(13)
          .fontColor(0xFFFFFFFF)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(0x66000000)
          .borderRadius(12)
          .margin({ top: 12 + this.getTopSafeHeight() })
          .visibility(this.vm.images.length > 0 && this.vm.toolbarVisible ? Visibility.Visible : Visibility.Hidden);

        Row() {
          Text('←')
            .fontSize(22)
            .fontColor(0xFFFFFFFF)
            .width(36)
            .textAlign(TextAlign.Center);
        }
        .height(36)
        .padding({ left: 6, right: 10 })
        .backgroundColor(0x66000000)
        .borderRadius(18)
        .position({ x: 12, y: 12 + this.getTopSafeHeight() })
        .visibility(this.vm.toolbarVisible ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.vm.wakeToolbarAndSchedule();
          this.popPage();
        });

        Column() {
          Row() {
            Button('-')
              .width(36)
              .height(36)
              .fontSize(20)
              .fontColor(0xFFFFFFFF)
              .backgroundColor(0x66000000)
              .onClick(() => {
                this.animateRebound(this.vm.zoomOutStep());
              });
            Text(this.vm.zoomScale.toFixed(2) + 'x')
              .fontSize(12)
              .fontColor(0xFFFFFFFF)
              .margin({ left: 8, right: 8 });
            Button('+')
              .width(36)
              .height(36)
              .fontSize(20)
              .fontColor(0xFFFFFFFF)
              .backgroundColor(0x66000000)
              .onClick(() => {
                this.animateRebound(this.vm.zoomInStep());
              });
          }
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(0x66000000)
          .borderRadius(12)
          .visibility(this.vm.images.length > 0 && this.vm.toolbarVisible ? Visibility.Visible : Visibility.Hidden);
        }
        .width('100%')
        .height(72 + this.getBottomSafeHeight())
        .margin({ top: this.vm.viewportHeight - (72 + this.getBottomSafeHeight()) })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: this.getBottomSafeHeight() + 8 });
      }
      .width('100%')
      .height('100%')
      .onAreaChange((_: Area, newArea: Area) => {
        this.vm.onViewportChange(newArea.width, newArea.height);
      })
      .backgroundColor(0xFF000000);
    }
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as ImageViewerRouteParams;
      let imageList: Array<string> = [];
      let startIndex: number = 0;
      if (params !== undefined && params.images !== undefined) {
        imageList = params.images;
      }
      if (params !== undefined && params.index !== undefined) {
        startIndex = params.index;
      }
      this.vm.init(imageList, startIndex);
    });
  }
}

@Builder
export function ImageViewerPageBuilder(): void {
  ImageViewerPage();
}
