import { windowUtil } from '../common/WindowUtil';

export interface ImageViewerRouteParams {
  images?: Array<string>;
  index?: number;
}

@ComponentV2
struct ImageViewerPage {
  @Local images: Array<string> = [];
  @Local currentIndex: number = 0;
  @Local zoomScale: number = 1;
  @Local translateX: number = 0;
  @Local translateY: number = 0;
  @Local toolbarVisible: boolean = true;
  @Local lastTapTimeMs: number = 0;
  @Local lastTapX: number = 0;
  @Local lastTapY: number = 0;
  @Local viewportWidth: number = 1080;
  @Local viewportHeight: number = 1920;
  @Local naturalWidthMap: Map<string, number> = new Map<string, number>();
  @Local naturalHeightMap: Map<string, number> = new Map<string, number>();

  private singleTapTimer: number = -1;
  private pinchStartDistance: number = 0;
  private pinchStartScale: number = 1;
  private dragStartX: number = 0;
  private dragStartY: number = 0;
  private dragBaseX: number = 0;
  private dragBaseY: number = 0;
  private lastMoveTimeMs: number = 0;
  private lastMoveX: number = 0;
  private lastMoveY: number = 0;
  private velocityX: number = 0;
  private velocityY: number = 0;
  private gestureMoved: boolean = false;
  // 手感参数：可根据机型继续微调
  private readonly maxZoomScale: number = 4;
  private readonly dragResistanceRatio: number = 0.28;
  private readonly velocityCapPerMs: number = 2.2;
  private readonly inertiaDurationMs: number = 260;
  private readonly inertiaDistanceFactor: number = 140;

  private getTopSafeHeight(): number {
    if (windowUtil.mainWindowInfo.avoidSystem !== undefined) {
      return windowUtil.mainWindowInfo.avoidSystem.topRect.height;
    }
    return 0;
  }

  aboutToDisappear(): void {
    if (this.singleTapTimer >= 0) {
      clearTimeout(this.singleTapTimer);
      this.singleTapTimer = -1;
    }
  }

  private normalizeIndex(index: number): number {
    if (this.images.length === 0) {
      return 0;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= this.images.length) {
      return this.images.length - 1;
    }
    return index;
  }

  private clampZoom(scale: number): number {
    if (scale < 1) {
      return 1;
    }
    if (scale > this.maxZoomScale) {
      return this.maxZoomScale;
    }
    return scale;
  }

  private parseSize(value: Length): number {
    if (typeof value === 'number') {
      return value;
    }
    if (typeof value === 'string') {
      let parsed: number = parseFloat(value);
      if (!isNaN(parsed)) {
        return parsed;
      }
    }
    return 0;
  }

  private resetTransform(): void {
    this.zoomScale = 1;
    this.translateX = 0;
    this.translateY = 0;
  }

  private clampTranslateX(x: number): number {
    let maxOffset: number = this.getMaxOffsetX();
    if (x > maxOffset) {
      return maxOffset;
    }
    if (x < -maxOffset) {
      return -maxOffset;
    }
    return x;
  }

  private clampTranslateY(y: number): number {
    let maxOffset: number = this.getMaxOffsetY();
    if (y > maxOffset) {
      return maxOffset;
    }
    if (y < -maxOffset) {
      return -maxOffset;
    }
    return y;
  }

  private readTouchX(touch: TouchObject): number {
    return touch.x;
  }

  private readTouchY(touch: TouchObject): number {
    return touch.y;
  }

  private getTouchDistance(event: TouchEvent): number {
    if (event.touches.length < 2) {
      return 0;
    }
    let x1: number = this.readTouchX(event.touches[0]);
    let y1: number = this.readTouchY(event.touches[0]);
    let x2: number = this.readTouchX(event.touches[1]);
    let y2: number = this.readTouchY(event.touches[1]);
    let dx: number = x1 - x2;
    let dy: number = y1 - y2;
    return Math.sqrt(dx * dx + dy * dy);
  }

  private getMaxOffsetX(): number {
    let maxOffset: number = this.viewportWidth * (this.zoomScale - 1) * 0.5;
    if (maxOffset < 0) {
      return 0;
    }
    return maxOffset;
  }

  private getMaxOffsetY(): number {
    let maxOffset: number = this.viewportHeight * (this.zoomScale - 1) * 0.5;
    if (maxOffset < 0) {
      return 0;
    }
    return maxOffset;
  }

  private applyDragResistance(value: number, maxOffset: number): number {
    if (value > maxOffset) {
      return maxOffset + (value - maxOffset) * this.dragResistanceRatio;
    }
    if (value < -maxOffset) {
      return -maxOffset + (value + maxOffset) * this.dragResistanceRatio;
    }
    return value;
  }

  private clampVelocity(v: number): number {
    if (v > this.velocityCapPerMs) {
      return this.velocityCapPerMs;
    }
    if (v < -this.velocityCapPerMs) {
      return -this.velocityCapPerMs;
    }
    return v;
  }

  private getCurrentUrl(): string {
    if (this.images.length === 0 || this.currentIndex < 0 || this.currentIndex >= this.images.length) {
      return '';
    }
    return this.images[this.currentIndex];
  }

  private getAdaptiveDoubleTapScale(): number {
    let url: string = this.getCurrentUrl();
    if (url.length === 0) {
      return 2;
    }
    let width: number = this.naturalWidthMap.get(url) ?? 0;
    let height: number = this.naturalHeightMap.get(url) ?? 0;
    if (width <= 0 || height <= 0) {
      return 2;
    }
    if (width > height * 1.2) {
      return 2.6;
    }
    if (height > width * 1.2) {
      return 1.9;
    }
    return 2.2;
  }

  private reboundToBounds(withInertia: boolean): void {
    if (this.zoomScale <= 1) {
      this.resetTransform();
      return;
    }
    let maxX: number = this.getMaxOffsetX();
    let maxY: number = this.getMaxOffsetY();
    let targetX: number = this.translateX;
    let targetY: number = this.translateY;
    if (withInertia) {
      targetX = targetX + this.velocityX * this.inertiaDistanceFactor;
      targetY = targetY + this.velocityY * this.inertiaDistanceFactor;
    }
    targetX = Math.max(-maxX, Math.min(maxX, targetX));
    targetY = Math.max(-maxY, Math.min(maxY, targetY));
    this.getUIContext().animateTo({
      duration: this.inertiaDurationMs,
      curve: Curve.EaseOut
    }, () => {
      this.translateX = targetX;
      this.translateY = targetY;
    });
  }

  private toggleZoomByDoubleTap(focusX: number, focusY: number): void {
    if (this.zoomScale > 1) {
      this.resetTransform();
      return;
    }
    this.zoomScale = this.getAdaptiveDoubleTapScale();
    let centerX: number = this.viewportWidth / 2;
    let centerY: number = this.viewportHeight / 2;
    this.translateX = this.clampTranslateX(-(focusX - centerX) * (this.zoomScale - 1));
    this.translateY = this.clampTranslateY(-(focusY - centerY) * (this.zoomScale - 1));
  }

  private handleImageTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      if (event.touches.length === 1) {
        this.dragStartX = this.readTouchX(event.touches[0]);
        this.dragStartY = this.readTouchY(event.touches[0]);
        this.dragBaseX = this.translateX;
        this.dragBaseY = this.translateY;
        this.lastMoveX = this.dragStartX;
        this.lastMoveY = this.dragStartY;
        this.lastMoveTimeMs = Date.now();
        this.velocityX = 0;
        this.velocityY = 0;
        this.gestureMoved = false;
      } else if (event.touches.length >= 2) {
        this.pinchStartDistance = this.getTouchDistance(event);
        this.pinchStartScale = this.zoomScale;
        this.gestureMoved = false;
      }
      return;
    }

    if (event.type === TouchType.Move) {
      if (event.touches.length >= 2) {
        let distance: number = this.getTouchDistance(event);
        if (this.pinchStartDistance > 0) {
          let oldScale: number = this.zoomScale;
          this.zoomScale = this.clampZoom(this.pinchStartScale * distance / this.pinchStartDistance);
          if (Math.abs(this.zoomScale - oldScale) > 0.01) {
            this.gestureMoved = true;
          }
          if (this.zoomScale <= 1) {
            this.translateX = 0;
            this.translateY = 0;
          }
          this.translateX = this.clampTranslateX(this.translateX);
          this.translateY = this.clampTranslateY(this.translateY);
        }
        return;
      }
      if (event.touches.length === 1 && this.zoomScale > 1) {
        let nowMs: number = Date.now();
        let currentX: number = this.readTouchX(event.touches[0]);
        let currentY: number = this.readTouchY(event.touches[0]);
        let dx: number = currentX - this.dragStartX;
        let dy: number = currentY - this.dragStartY;
        if (Math.abs(dx) > 2 || Math.abs(dy) > 2) {
          this.gestureMoved = true;
        }
        let rawX: number = this.dragBaseX + dx;
        let rawY: number = this.dragBaseY + dy;
        this.translateX = this.applyDragResistance(rawX, this.getMaxOffsetX());
        this.translateY = this.applyDragResistance(rawY, this.getMaxOffsetY());
        let dt: number = nowMs - this.lastMoveTimeMs;
        if (dt > 0) {
          this.velocityX = this.clampVelocity((currentX - this.lastMoveX) / dt);
          this.velocityY = this.clampVelocity((currentY - this.lastMoveY) / dt);
          this.lastMoveTimeMs = nowMs;
          this.lastMoveX = currentX;
          this.lastMoveY = currentY;
        }
      }
      return;
    }

    if (event.type !== TouchType.Up) {
      return;
    }

    if (event.touches.length > 1) {
      return;
    }

    if (this.gestureMoved && this.zoomScale > 1) {
      this.reboundToBounds(true);
      this.gestureMoved = false;
      return;
    }

    if (event.changedTouches.length === 0) {
      return;
    }
    let upX: number = this.readTouchX(event.changedTouches[0]);
    let upY: number = this.readTouchY(event.changedTouches[0]);
    let nowMs: number = Date.now();
    let tapDeltaTime: number = nowMs - this.lastTapTimeMs;
    let tapDeltaX: number = Math.abs(upX - this.lastTapX);
    let tapDeltaY: number = Math.abs(upY - this.lastTapY);
    let isDoubleTap: boolean = tapDeltaTime < 280 && tapDeltaX < 24 && tapDeltaY < 24;
    if (isDoubleTap) {
      if (this.singleTapTimer >= 0) {
        clearTimeout(this.singleTapTimer);
        this.singleTapTimer = -1;
      }
      this.toggleZoomByDoubleTap(upX, upY);
      this.lastTapTimeMs = 0;
      return;
    }

    if (this.singleTapTimer >= 0) {
      clearTimeout(this.singleTapTimer);
    }
    this.singleTapTimer = setTimeout(() => {
      this.toolbarVisible = !this.toolbarVisible;
      this.singleTapTimer = -1;
    }, 300);

    this.lastTapTimeMs = nowMs;
    this.lastTapX = upX;
    this.lastTapY = upY;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        if (this.images.length > 0) {
          if (this.zoomScale > 1) {
            Column() {
              Image(this.images[this.currentIndex])
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .draggable(false)
                .onComplete((event: ImageLoadResult) => {
                  this.naturalWidthMap.set(this.images[this.currentIndex], event.width);
                  this.naturalHeightMap.set(this.images[this.currentIndex], event.height);
                })
                .scale({ x: this.zoomScale, y: this.zoomScale })
                .translate({ x: this.translateX, y: this.translateY });
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onTouch((event: TouchEvent) => {
              this.handleImageTouch(event);
            });
          } else {
            Swiper() {
              ForEach(this.images, (url: string) => {
                Column() {
                  Image(url)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Contain)
                    .draggable(false)
                    .onComplete((event: ImageLoadResult) => {
                      this.naturalWidthMap.set(url, event.width);
                      this.naturalHeightMap.set(url, event.height);
                    })
                    .scale({ x: this.zoomScale, y: this.zoomScale })
                    .translate({ x: this.translateX, y: this.translateY });
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onTouch((event: TouchEvent) => {
                  this.handleImageTouch(event);
                });
              })
            }
            .index(this.currentIndex)
            .onChange((index: number) => {
              this.currentIndex = index;
              this.resetTransform();
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

        Text((this.currentIndex + 1) + ' / ' + this.images.length)
          .fontSize(13)
          .fontColor(0xFFFFFFFF)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(0x66000000)
          .borderRadius(12)
          .margin({ top: 12 + this.getTopSafeHeight() })
          .visibility(this.images.length > 0 && this.toolbarVisible ? Visibility.Visible : Visibility.Hidden);

        Row() {
          Button('-')
            .width(36)
            .height(36)
            .fontSize(20)
            .fontColor(0xFFFFFFFF)
            .backgroundColor(0x66000000)
            .onClick(() => {
              this.zoomScale = this.clampZoom(this.zoomScale - 0.25);
              if (this.zoomScale <= 1) {
                this.resetTransform();
                return;
              }
              this.reboundToBounds(false);
            });
          Text(this.zoomScale.toFixed(2) + 'x')
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
              this.zoomScale = this.clampZoom(this.zoomScale + 0.25);
              this.reboundToBounds(false);
            });
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(0x66000000)
        .borderRadius(12)
        .margin({ bottom: 20 })
        .alignSelf(ItemAlign.Center)
        .visibility(this.images.length > 0 && this.toolbarVisible ? Visibility.Visible : Visibility.Hidden);
      }
      .width('100%')
      .height('100%')
      .onAreaChange((_: Area, newArea: Area) => {
        this.viewportWidth = this.parseSize(newArea.width);
        this.viewportHeight = this.parseSize(newArea.height);
      })
      .backgroundColor(0xFF000000);
    }
    .ignoreLayoutSafeArea()
    .height(LayoutPolicy.matchParent)
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
      this.images = imageList;
      this.currentIndex = this.normalizeIndex(startIndex);
    })
    .title('查看原图');
  }
}

@Builder
export function ImageViewerPageBuilder(): void {
  ImageViewerPage();
}
