import { windowUtil } from '../common/WindowUtil';

export interface ReboundTarget {
  x: number;
  y: number;
  duration: number;
}

export interface TouchHandleResult {
  reboundTarget: ReboundTarget | null;
  shouldPop: boolean;
}

@ObservedV2
export class ImageViewerViewModel {
  @Trace images: Array<string> = [];
  @Trace currentIndex: number = 0;
  @Trace zoomScale: number = 1;
  @Trace translateX: number = 0;
  @Trace translateY: number = 0;
  @Trace toolbarVisible: boolean = true;
  @Trace lastTapTimeMs: number = 0;
  @Trace lastTapX: number = 0;
  @Trace lastTapY: number = 0;
  @Trace viewportWidth: number = 1080;
  @Trace viewportHeight: number = 1920;
  @Trace naturalWidthMap: Map<string, number> = new Map<string, number>();
  @Trace naturalHeightMap: Map<string, number> = new Map<string, number>();

  private singleTapTimer: number = -1;
  private autoHideTimer: number = -1;
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

  readonly maxZoomScale: number = 4;
  readonly autoHideDelayMs: number = 2500;
  readonly dragResistanceRatio: number = 0.28;
  readonly velocityCapPerMs: number = 2.2;
  readonly inertiaDurationMs: number = 260;
  readonly inertiaDistanceFactor: number = 140;

  init(images: Array<string>, startIndex: number): void {
    this.images = images;
    this.currentIndex = this.normalizeIndex(startIndex);
    this.wakeToolbarAndSchedule();
  }

  dispose(): void {
    if (this.singleTapTimer >= 0) {
      clearTimeout(this.singleTapTimer);
      this.singleTapTimer = -1;
    }
    this.clearAutoHideTimer();
  }

  getTopSafeHeight(): number {
    let topSafe: number = 0;
    if (windowUtil.mainWindowInfo.avoidSystem !== undefined) {
      topSafe = windowUtil.mainWindowInfo.avoidSystem.topRect.height;
    } else if (windowUtil.mainWindowInfo.avoidCutout !== undefined) {
      topSafe = windowUtil.mainWindowInfo.avoidCutout.topRect.height;
    }
    if (topSafe < 0) {
      return 0;
    }
    if (topSafe > 80) {
      return 80;
    }
    return topSafe;
  }

  getBottomSafeHeight(): number {
    if (windowUtil.mainWindowInfo.avoidNavigationIndicator !== undefined) {
      return windowUtil.mainWindowInfo.avoidNavigationIndicator.bottomRect.height;
    }
    if (windowUtil.mainWindowInfo.avoidSystemGesture !== undefined) {
      return windowUtil.mainWindowInfo.avoidSystemGesture.bottomRect.height;
    }
    if (windowUtil.mainWindowInfo.avoidCutout !== undefined) {
      return windowUtil.mainWindowInfo.avoidCutout.bottomRect.height;
    }
    return 0;
  }

  normalizeIndex(index: number): number {
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

  clampZoom(scale: number): number {
    if (scale < 1) {
      return 1;
    }
    if (scale > this.maxZoomScale) {
      return this.maxZoomScale;
    }
    return scale;
  }

  clampTranslateX(x: number): number {
    let maxOffset: number = this.getMaxOffsetX();
    if (x > maxOffset) {
      return maxOffset;
    }
    if (x < -maxOffset) {
      return -maxOffset;
    }
    return x;
  }

  clampTranslateY(y: number): number {
    let maxOffset: number = this.getMaxOffsetY();
    if (y > maxOffset) {
      return maxOffset;
    }
    if (y < -maxOffset) {
      return -maxOffset;
    }
    return y;
  }

  parseSize(value: Length): number {
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

  resetTransform(): void {
    this.zoomScale = 1;
    this.translateX = 0;
    this.translateY = 0;
  }

  onViewportChange(width: Length, height: Length): void {
    this.viewportWidth = this.parseSize(width);
    this.viewportHeight = this.parseSize(height);
  }

  onImageLoaded(url: string, width: number, height: number): void {
    this.naturalWidthMap.set(url, width);
    this.naturalHeightMap.set(url, height);
  }

  onImageIndexChange(index: number): void {
    this.currentIndex = index;
    this.resetTransform();
    this.wakeToolbarAndSchedule();
  }

  clearAutoHideTimer(): void {
    if (this.autoHideTimer >= 0) {
      clearTimeout(this.autoHideTimer);
      this.autoHideTimer = -1;
    }
  }

  scheduleAutoHide(): void {
    this.clearAutoHideTimer();
    this.autoHideTimer = setTimeout(() => {
      this.toolbarVisible = false;
      this.autoHideTimer = -1;
    }, this.autoHideDelayMs);
  }

  wakeToolbarAndSchedule(): void {
    this.toolbarVisible = true;
    this.scheduleAutoHide();
  }

  zoomOutStep(): ReboundTarget | null {
    this.wakeToolbarAndSchedule();
    this.zoomScale = this.clampZoom(this.zoomScale - 0.25);
    if (this.zoomScale <= 1) {
      this.resetTransform();
      return null;
    }
    return this.buildReboundTarget(false);
  }

  zoomInStep(): ReboundTarget | null {
    this.wakeToolbarAndSchedule();
    this.zoomScale = this.clampZoom(this.zoomScale + 0.25);
    return this.buildReboundTarget(false);
  }

  applyReboundTarget(target: ReboundTarget): void {
    this.translateX = target.x;
    this.translateY = target.y;
  }

  handleImageTouch(event: TouchEvent): TouchHandleResult {
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
      return { reboundTarget: null, shouldPop: false };
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
        return { reboundTarget: null, shouldPop: false };
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
      return { reboundTarget: null, shouldPop: false };
    }

    if (event.type !== TouchType.Up) {
      return { reboundTarget: null, shouldPop: false };
    }

    if (event.touches.length > 1) {
      return { reboundTarget: null, shouldPop: false };
    }

    if (this.gestureMoved && this.zoomScale > 1) {
      this.gestureMoved = false;
      this.wakeToolbarAndSchedule();
      return { reboundTarget: this.buildReboundTarget(true), shouldPop: false };
    }

    if (event.changedTouches.length === 0) {
      return { reboundTarget: null, shouldPop: false };
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
      return { reboundTarget: null, shouldPop: false };
    }

    if (this.shouldPopOnSingleTap(upX, upY)) {
      return { reboundTarget: null, shouldPop: true };
    }

    if (this.singleTapTimer >= 0) {
      clearTimeout(this.singleTapTimer);
    }
    this.singleTapTimer = setTimeout(() => {
      this.toolbarVisible = !this.toolbarVisible;
      if (this.toolbarVisible) {
        this.scheduleAutoHide();
      } else {
        this.clearAutoHideTimer();
      }
      this.singleTapTimer = -1;
    }, 260);

    this.lastTapTimeMs = nowMs;
    this.lastTapX = upX;
    this.lastTapY = upY;
    return { reboundTarget: null, shouldPop: false };
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

  private shouldPopOnSingleTap(tapX: number, tapY: number): boolean {
    if (this.zoomScale > 1) {
      return false;
    }
    let url: string = this.getCurrentUrl();
    if (url.length === 0) {
      return false;
    }
    let naturalWidth: number = this.naturalWidthMap.get(url) ?? 0;
    let naturalHeight: number = this.naturalHeightMap.get(url) ?? 0;
    if (naturalWidth <= 0 || naturalHeight <= 0) {
      return false;
    }
    let viewportW: number = this.viewportWidth;
    let viewportH: number = this.viewportHeight;
    if (viewportW <= 0 || viewportH <= 0) {
      return false;
    }
    let imageAspect: number = naturalWidth / naturalHeight;
    let viewportAspect: number = viewportW / viewportH;
    let displayW: number = viewportW;
    let displayH: number = viewportH;
    if (viewportAspect > imageAspect) {
      displayH = viewportH;
      displayW = displayH * imageAspect;
    } else {
      displayW = viewportW;
      displayH = displayW / imageAspect;
    }
    let left: number = (viewportW - displayW) / 2;
    let top: number = (viewportH - displayH) / 2;
    let right: number = left + displayW;
    let bottom: number = top + displayH;
    let isInsideImage: boolean = tapX >= left && tapX <= right && tapY >= top && tapY <= bottom;
    return !isInsideImage;
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

  private buildReboundTarget(withInertia: boolean): ReboundTarget | null {
    if (this.zoomScale <= 1) {
      this.resetTransform();
      return null;
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
    return {
      x: targetX,
      y: targetY,
      duration: this.inertiaDurationMs
    };
  }
}
