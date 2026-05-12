/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { WindowInfo } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { BannerViewModel, TVBannerItemViewModel } from '../viewmodel/BannerViewModel';
import { getTabIndex } from './CommonView';

@Component
export struct TVBannerView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @State firstShowIndex: number = 0; // The subscript of the first banner.
  @State bannerScaleList: Array<ScaleOptions | null> = new BannerViewModel().getTVBannerScaleList();
  @State bannerTranslateList: Array<TranslateOptions> = []; // Component translation array.
  @State bannerZIndexList: Array<number> = []; // The zIndex for displaying images.
  @State bannerImgDataList: Array<Resource> = []; // The banner image shows an array.
  @State currentCenterIndex: number = 2; // The subscript for the currently centered banner.
  @State bannerCardHeight: number = HomeConstants.TV_BANNER_CARD_HEIGHT_CENTER;
  @State borderRadiusValue: Array<string> = []; // Array of rounded corners for the outer border of the image.
  private slipDirection: number = 0; // 0:Swipe to the left,1:Swipe to the right.
  private swiperController: SwiperController = new SwiperController();
  // Array of swiper banner image displays.
  private bannerImgList: TVBannerItemViewModel[] = new BannerViewModel().getTVBannerList();
  private scaleParamData: Array<ScaleOptions> = [
    HomeConstants.TV_BANNER_IMAGE_SCALE_1, HomeConstants.TV_BANNER_IMAGE_SCALE_2,
    HomeConstants.TV_BANNER_IMAGE_SCALE_3, HomeConstants.TV_BANNER_IMAGE_SCALE_2,
    HomeConstants.TV_BANNER_IMAGE_SCALE_1
  ]; // Array of TV Banner scale param.

  aboutToAppear(): void {
    this.updateBannerCard();
  }

  build() {
    Column() {
      // Banner layout.
      Swiper(this.swiperController) {
        ForEach(this.bannerImgList, (item: TVBannerItemViewModel, index: number) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(this.bannerImgDataList[index % this.bannerImgDataList.length])
              .height(this.getBannerCardHeight(index))
              .width(this.getBannerCardWidth(index))
              .objectFit(ImageFit.Fill)
              .focusable(true)
              .draggable(false)
              .borderRadius(16)

            Row() {
              Text(item.title)
                .fontSize('16fp')
                .fontColor(Color.White)
                .fontWeight(800)
              Stack() {
                Image($r('app.media.newMarkGray'))
                  .width('45vp')
                  .height('20vp')
                Text($r('app.string.Membership'))
                  .fontColor(Color.White)
                  .fontSize('12vp')
              }
              .margin({
                top: '5vp',
                right: '7vp'
              })
            }
            .margin({
              bottom: '22vp'
            })
            .padding({
              left: '32vp',
              right: '32vp'
            })
            .zIndex(this.bannerZIndexList[index % this.bannerZIndexList.length] + 1)
            .translate({
              x: -(this.bannerTranslateList[index % this.bannerTranslateList.length]?.x as number || 0),
              y: 0
            })
            .justifyContent(FlexAlign.SpaceBetween)
            .width(this.getBannerCardWidth(index))
            .visibility(this.currentCenterIndex === index ? Visibility.Visible : Visibility.None)
          }
          .width(this.getBannerCardWidth(index))
          .height(this.bannerCardHeight)
          .zIndex(this.bannerZIndexList[this.getBannerSafeIndex(index)])
          .translate({
            x: (this.bannerTranslateList[this.getBannerSafeIndex(index)]?.x as number || 0) +
              this.getBannerWidthCompensation(index),
            y: this.bannerTranslateList[this.getBannerSafeIndex(index)]?.y as number || 0
          })
        }, (item: TVBannerItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .height(this.bannerCardHeight)
      .displayCount(HomeConstants.TV_BANNER_IMAGE_COUNT)
      .indicator(false)
      .loop(true)
      .disableSwipe(true)
      .autoPlay(true)
      .interval(5000)
      .effectMode(EdgeEffect.None)
      .tabIndex(getTabIndex('Banner'))
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            // Set the success callback for the sliding gesture recognition.
            if (event.offsetX < -6) { // Gesture: Swipe left.
              this.swiperController.showNext();
              this.slipDirection = 0; // Swipe to the left.
            } else if (event.offsetX > 6) { // Gesture: Swipe right.
              this.swiperController.showPrevious();
              this.slipDirection = 1; // Swipe to the right.
            }
          })
      )
      .onAnimationStart(() => {
        this.gestureProcess();
      })
    }
    .width('100%')
    .margin({
      top: '124vp'
    })
  }

  private updateBannerCard(): void {
    const bannerDataLength: number = this.bannerImgList.length;
    if (bannerDataLength === 0) {
      return;
    }
    let resList: number[] = [];
    // Calculate centerOffset.
    const centerOffset = Math.floor(HomeConstants.TV_BANNER_IMAGE_COUNT / 2);
    // The current index of the center of the Banner card.
    this.currentCenterIndex = (this.firstShowIndex + centerOffset) % bannerDataLength;
    for (let showIndex = 0; showIndex < HomeConstants.TV_BANNER_IMAGE_COUNT; showIndex++) {
      const current = this.firstShowIndex + showIndex + bannerDataLength;
      const currentIndex = current % bannerDataLength;
      resList.push(currentIndex);
    }
    let currentsCenterIndex: number = this.currentCenterIndex;
    for (let index = 0; index < bannerDataLength; index++) {
      const indexOf: number = resList.indexOf(index);
      if (indexOf !== -1) {
        const indexScale: ScaleOptions = this.scaleParamData[indexOf];
        this.bannerScaleList[index] = indexScale;
        this.bannerTranslateList[index] = this.getTranslateParam(indexOf, index);
      } else {
        this.bannerScaleList[index] = HomeConstants.TV_BANNER_IMAGE_SCALE_1;
        this.bannerTranslateList[index] = this.getTranslateParam(HomeConstants.TWO, index);
        this.bannerZIndexList[index] = HomeConstants.TV_BANNER_DEFAULT_Z_INDEX;
      }
      this.borderRadiusValue[index] = HomeConstants.TV_BANNER_BORDER_RADIUS_FIVE_PERCENT;
      // Determine that if the banner is a middle-sized card, display the large image; otherwise,
      // display the small image.
      this.bannerImgDataList[index] =
        currentsCenterIndex === index ? this.bannerImgList[index].imgHorizontal : this.bannerImgList[index].imgVertical;
    }
    this.borderRadiusValue[this.currentCenterIndex] = HomeConstants.TV_BANNER_BORDER_RADIUS_TWO_PERCENT;
    this.bannerZIndexList[this.currentCenterIndex] = HomeConstants.TV_BANNER_CENTER_Z_INDEX;
  }

  private getTranslateParam(index: number, currentIndex: number): TranslateOptions {
    let res: TranslateOptions = {};
    if (index === 1) {
      res.x = -HomeConstants.TV_BANNER_CARD_TRANSLATE_X_OFFSET;
      this.bannerZIndexList[currentIndex] = HomeConstants.TV_BANNER_SIDE_Z_INDEX;
    } else if (index === 3) {
      this.bannerZIndexList[currentIndex] = HomeConstants.TV_BANNER_SIDE_Z_INDEX;
      res.x = HomeConstants.TV_BANNER_CARD_TRANSLATE_X_OFFSET;
    } else {
      this.bannerZIndexList[currentIndex] = HomeConstants.TV_BANNER_DEFAULT_Z_INDEX;
      res.x = 0;
    }
    // In real width/height layout mode, keep all card bottoms on same baseline.
    res.y = 0;
    return res;
  }

  private getBannerSafeIndex(index: number): number {
    const length: number = this.bannerImgList.length;
    if (length === 0) {
      return 0;
    }
    return index % length;
  }

  private getBannerScale(index: number): ScaleOptions {
    const safeIndex: number = this.getBannerSafeIndex(index);
    return this.bannerScaleList[safeIndex] || { x: 1, y: 1 };
  }

  private getBannerCardWidth(index: number): number {
    return HomeConstants.TV_BANNER_CARD_WIDTH * (this.getBannerScale(index).x || 1);
  }

  private getBannerCardHeight(index: number): number {
    return this.bannerCardHeight * (this.getBannerScale(index).y || 1);
  }

  private getBannerWidthCompensation(index: number): number {
    return (HomeConstants.TV_BANNER_CARD_WIDTH - this.getBannerCardWidth(index)) / 2;
  }

  private getBannerTextOffsetX(index: number): number {
    return -this.getBannerWidthCompensation(index);
  }

  private slidingAnimation(): void {
    this.getUIContext().animateTo({
      duration: 350,
      curve: Curve.Friction,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Alternate,
      expectedFrameRateRange: {
        min: 10,
        max: 120,
        expected: 60
      }
    }, () => {
      this.updateBannerCard();
    });
  }

  private gestureProcess(): void {
    if (this.slipDirection === 1) {
      // Swipe right with your hand.
      if (this.firstShowIndex === 1) {
        this.firstShowIndex = this.bannerImgList.length;
      } else {
        this.firstShowIndex -= 1;
      }
    } else if (this.slipDirection === 0) {
      // Swipe left with your hand.
      if (this.firstShowIndex === this.bannerImgList.length) {
        this.firstShowIndex = 1;
      } else {
        this.firstShowIndex += 1;
      }
    }
    this.slidingAnimation();
    this.slipDirection = 0; // Set the sliding direction of the swiper component to the default and slide to the left.
  }
}