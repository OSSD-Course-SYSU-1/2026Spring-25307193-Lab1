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

import { WindowInfo, BreakpointType, BreakpointVisibilityUtil } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { BannerItemViewModel, BannerViewModel } from '../viewmodel/BannerViewModel';
import { getTabIndex } from './CommonView';

@Component
export struct BannerView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  private bannerImgList: BannerItemViewModel[] = new BannerViewModel().getBannerList();
  private breakpointFlags() {
    return BreakpointVisibilityUtil.getFlags(this.mainWindowInfo);
  }

  build() {
    Column() {
      // Banner layout.
      Row() {
        Swiper() {
          ForEach(this.bannerImgList, (item: BannerItemViewModel, index: number) => {
            Image(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ?
              item.getBannerImg().getImgSrcSm() :
              item.getBannerImg().getImgSrc())
              .objectFit(ImageFit.Fill)
              .borderRadius(16)
              .focusable(true)
              .height(item.getBannerImg().getHeight().getValue(this.mainWindowInfo.widthBp))
              .width('100%')
              // The width and height vary with the container assembly and the aspect ratio remains unchanged.
              .aspectRatio(new BreakpointType(1.91,
                this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_MD ? 1.91 : 1.49, 1.6, 2.1,
                1.6).getValue(this.mainWindowInfo.widthBp))
              .groupDefaultFocus(index === 0 ? true : false)
              .focusable(true)
              .padding({
                top: '12vp',
                bottom: '12vp',
                left: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '16vp' : '0vp',
                right: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '16vp' : '0vp'
              })
          }, (item: BannerItemViewModel, index: number) => index + JSON.stringify(item))
        }
        .displayCount(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? 1 : 2)
        // Interval between banner images
        .itemSpace('12vp')
        .prevMargin(new BreakpointType('0vp', '0vp',
          '12vp', '64vp', '64vp')
          .getValue(this.mainWindowInfo.widthBp))
        .nextMargin(new BreakpointType('0vp', '0vp',
          '12vp', '64vp', '64vp')
          .getValue(this.mainWindowInfo.widthBp))
        // Setting the navigation point Style of the swiper.
        .indicator(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? Indicator.dot()
          .itemWidth('6vp')
          .itemHeight('6vp')
          .selectedItemWidth('12vp')
          .selectedItemHeight('6vp')
          .color($r('app.color.swiper_indicator'))
          .bottom('12vp')
          .selectedColor(Color.White) : false
        )
        .loop(true)
        .width('100%')
        .visibility(this.breakpointFlags().isWidthBpAboveMd && this.currentTopIndex === 1 ? Visibility.None :
          Visibility.Visible)
        .effectMode(EdgeEffect.None)
        // The sizes of the front and rear banners on the MD and LG devices are different.
        .index(2)
        .tabIndex(getTabIndex('Banner'))

        // Switch the tab to switch the banner display effect.
        Row({ space: '12vp' }) {
          BannerText({
            banner: this.bannerImgList[2],
            index: 0,
            mainWindowInfo: this.mainWindowInfo
          })
            .layoutWeight(4)
            .height('100%')

          BannerText({
            banner: this.bannerImgList[1],
            index: 1,
            mainWindowInfo: this.mainWindowInfo
          })
            .layoutWeight(4)
            .height('100%')

          Column() {
            BannerText({
              banner: this.bannerImgList[0],
              index: 2,
              mainWindowInfo: this.mainWindowInfo
            })
              .margin({ bottom: '6vp' })
              .layoutWeight(1)

            BannerText({
              banner: this.bannerImgList[4],
              index: 3,
              mainWindowInfo: this.mainWindowInfo
            })
              .margin({ top: '6vp' })
              .layoutWeight(1)
          }
          .layoutWeight(3)
        }
        .height(this.getBannerNewHeight(this.mainWindowInfo.windowSize.width))
        .width('100%')
        .visibility(this.breakpointFlags().isWidthBpAboveMd && this.currentTopIndex === 1 ? Visibility.Visible :
          Visibility.None)
        .padding({
          left: '32vp',
          right: '32vp',
          top: '8vp',
          bottom: '16vp'
        })
      }
      .width('100%')
      .visibility(this.currentTopIndex === 2 ? Visibility.None : Visibility.Visible)

      Row() {
        // Immersive layout.
        Column() {
          Text(this.bannerImgList[2].getDescription().getIsLeftCenter().getValue(this.mainWindowInfo.widthBp) ?
            `${this.bannerImgList[2].getDescription().getDescription()[0]}${this.bannerImgList[2].getDescription()
              .getDescription()[1]}` : this.bannerImgList[2].getDescription().getDescription()[0])
            .fontSize(new BreakpointType('18fp', '18fp', '28fp', '40fp', '40fp').getValue(this.mainWindowInfo.widthBp))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[0])
            .lineHeight(new BreakpointType('20vp', '20vp', '36vp', '54vp',
              '54vp').getValue(this.mainWindowInfo.widthBp))
            .fontColor(Color.White)
            .letterSpacing('1vp')
            .maxLines(1)

          Text(this.bannerImgList[2].getDescription().getDescription()[1])
            .fontSize(new BreakpointType('18fp', '18fp', '28fp', '40fp', '40fp').getValue(this.mainWindowInfo.widthBp))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[0])
            .lineHeight(new BreakpointType('20vp', '20vp', '36vp', '54vp',
              '54vp').getValue(this.mainWindowInfo.widthBp))
            .fontColor(Color.White)
            .letterSpacing('1vp')
            .maxLines(1)
            .visibility(this.bannerImgList[2].getDescription().getIsLeftCenter().getValue(this.mainWindowInfo.widthBp) ?
              Visibility.None : Visibility.Visible)

          Text(this.bannerImgList[2].getDescription().getDescription()[2])
            .fontSize(new BreakpointType('14fp', '14fp', '21fp', '28fp', '28fp').getValue(this.mainWindowInfo.widthBp))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[1])
            .lineHeight(new BreakpointType('19vp', '19vp', '28vp', '48vp',
              '48vp').getValue(this.mainWindowInfo.widthBp))
            .fontColor(Color.White)
            .margin({
              top: this.bannerImgList[2].getDescription().getTopPosition().getValue(this.mainWindowInfo.widthBp)[1]
            })
            .letterSpacing('3vp')
            .maxLines(1)
        }
        .padding({
          left: new BreakpointType('0vp', '0vp', '82vp', '58vp', '58vp').getValue(this.mainWindowInfo.widthBp),
          top: new BreakpointType('139vp', '139vp', '90vp', '106vp', '106vp').getValue(this.mainWindowInfo.widthBp)
        })
        .height('100%')
        .width('100%')
        .alignItems(new BreakpointType(true, true, false, false, false).getValue(this.mainWindowInfo.widthBp) ?
          HorizontalAlign.Center : HorizontalAlign.Start)
        .justifyContent(!this.bannerImgList[2].getDescription().getIsTopCenter().getValue(this.mainWindowInfo.widthBp) ?
          FlexAlign.Start : FlexAlign.Center)
      }
      .margin({
        top: '36vp'
      })
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .height(new BreakpointType('334vp', '334vp', '370vp', '396vp', '396vp').getValue(this.mainWindowInfo.widthBp))
      .width('100%')
      .visibility(this.currentTopIndex === 2 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .padding({
      left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG && this.currentTopIndex === 2 ? '96vp' : '0vp'
    })
  }

  /**
   * Calculates banner height for LG/XL breakpoints based on window width and aspect ratio.
   */
  getBannerNewHeight(windowWidth: number): string {
    let result: number =
      this.getUIContext().px2vp(windowWidth) -
      new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0], HomeConstants.VIDEO_GRID_MARGIN[0],
        HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2], HomeConstants.VIDEO_GRID_MARGIN[2])
        .getValue(this.mainWindowInfo.widthBp);
    if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG) {
      // Calculate the width of a single image based on the percent.
      result = (result - HomeConstants.LG_SIDEBAR_WIDTH - HomeConstants.BANNER_GRID_GAP_DOUBLE) *
      HomeConstants.BANNER_GRID_WIDTH_RATIO_NUMERATOR / HomeConstants.BANNER_GRID_WIDTH_RATIO_DENOMINATOR;
      // Calculate the total height of the grid layout.
      return result / HomeConstants.BANNER_IMG_ASPECT_RATIO_LG + HomeConstants.VP_UNIT;
    } else {
      result = (result - HomeConstants.XL_SIDEBAR_WIDTH - HomeConstants.BANNER_GRID_GAP_DOUBLE) *
      HomeConstants.BANNER_GRID_WIDTH_RATIO_NUMERATOR / HomeConstants.BANNER_GRID_WIDTH_RATIO_DENOMINATOR;
      return result / HomeConstants.BANNER_IMG_ASPECT_RATIO_XL + HomeConstants.VP_UNIT;
    }
  }
}

/**
 * Banner text overlay component for displaying text on banner images.
 */
@Component
struct BannerText {
  @ObjectLink mainWindowInfo: WindowInfo;
  public banner: BannerItemViewModel = new BannerViewModel().getBannerList()[0];
  public index: number = 0;

  build() {
    Image(((this.index === 0) || (this.index === 1)) ? this.banner.getBannerImg().getImgSrcSm() :
      this.banner.getBannerImg().getImgSrc())
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Fill)
      .hoverEffect(HoverEffect.Scale)
      .borderRadius(16)
  }
}