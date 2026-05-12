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

import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointType, Logger, WindowInfo, WindowUtil } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { HomeHeader } from './HomeHeader';
import { FeaturedContent } from './FeaturedContent';
import { VideoContent } from './VideoContent';
import { CommunityContent } from './CommunityContent';

const TAG = '[Home]';

@Component
export struct Home {
  @Consume('pageInfo') pageInfo: NavPathStack;
  @ObjectLink @Watch('mainWindowInfoChange') mainWindowInfo: WindowInfo;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @Provide isOnDisplay: boolean = false;
  @State scrollHeight: number = 0;
  @State topAvoidHeight: number = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.topRect.height);
  @State bottomAvoidHeight: number = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.bottomRect.height);
  @Link bottomBarHeight: number;
  @State topBarHeight: number = HomeConstants.TOP_BAR_HEIGHT + this.topAvoidHeight;
  @State barOpacity: number = 1;
  // The current vertical sliding distance of the list.
  @State currentYOffset: number = 0;
  @State currentIndex: number = 0;
  @State decorWidth: number = 0;
  private scroller: Scroller = new Scroller();
  private sideScroller: Scroller = new Scroller();
  private isHiding: boolean = false;
  private curWidthBp: number = WidthBreakpoint.WIDTH_SM;
  callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.barOpacity = 1;
      if (this.currentTopIndex === 2) {
        this.sideScroller.scrollToIndex(this.currentIndex);
      } else {
        this.scroller.scrollToIndex(this.currentIndex);
      }
    } else if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      if (this.currentTopIndex === 2) {
        this.sideScroller.scrollToIndex(this.currentIndex);
      } else {
        this.scroller.scrollToIndex(this.currentIndex);
      }
    }
    Logger.info(TAG, 'Listening enabled. Data: ' + JSON.stringify(data));
  };

  /**
   * If mainWindowInfo changes, change the home page style.
   */
  mainWindowInfoChange(): void {
    this.topAvoidHeight = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.topRect.height);
    this.bottomAvoidHeight = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.bottomRect.height);
    // Calculate the height of top and bottom.
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) {
      this.topBarHeight = HomeConstants.HOME_HEADER_HEIGHT_SM + this.topAvoidHeight;
    } else {
      this.topBarHeight = HomeConstants.TOP_BAR_HEIGHT + this.topAvoidHeight;
    }
    this.bottomBarHeight = this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ?
      HomeConstants.BOTTOM_TAB_BAR_HEIGHT_SM + this.bottomAvoidHeight :
      HomeConstants.BOTTOM_TAB_BAR_HEIGHT + this.bottomAvoidHeight;

    // Set decoration.
    try {
      if (!(this.pageInfo.getAllPathName().length >= 1 &&
        this.pageInfo.getAllPathName()[this.pageInfo.getAllPathName().length - 1] ===
        HomeConstants.PAGE_NAME_FOR_VIDEO)) {
        this.windowUtil?.mainWindow.setWindowDecorVisible(this.mainWindowInfo.widthBp < WidthBreakpoint.WIDTH_XL);
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setWindowDecorVisible failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    this.curWidthBp = this.mainWindowInfo.widthBp;
    if (this.curWidthBp >= WidthBreakpoint.WIDTH_XL) {
      if (this.windowUtil) {
        try {
          this.decorWidth = this.windowUtil.mainWindow.getTitleButtonRect().width;
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `getTitleButtonRect failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        }
      }
    } else {
      this.decorWidth = 0;
    }
  }

  aboutToAppear(): void {
    // Set fold status change listen.
    try {
      display.on('foldStatusChange', this.callback);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to update fold status, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    if (this.windowUtil) {
      try {
        this.windowUtil.mainWindow.setDecorButtonStyle({ buttonIconSize: HomeConstants.DECOR_BUTTON_ICON_SIZE });
        this.windowUtil.mainWindow.setWindowDecorHeight(HomeConstants.DECOR_WINDOW_HEIGHT);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to set DecorButtonStyle, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
    // Initial home page style.
    this.mainWindowInfoChange();
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', this.callback);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to off fold status, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  build() {
    if (this.currentTopIndex === 2) { // Immerse for community
      Stack() {
        this.HomeScrollContent()

        HomeHeader({
          mainWindowInfo: this.mainWindowInfo,
          scrollHeight: this.scrollHeight,
          decorWidth: this.decorWidth
        })
          .opacity(this.barOpacity)
          .height(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
            this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? this.topBarHeight : 'auto')
          .padding({
            left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? '96vp' : '0vp',
            top: new BreakpointType(0, 0, this.currentTopIndex === 2 ? '0vp' : this.topAvoidHeight,
              this.currentTopIndex === 2 ? '0vp' : this.topAvoidHeight,
              this.currentTopIndex === 2 ? '0vp' : this.topAvoidHeight).getValue(this.mainWindowInfo.widthBp),
            bottom: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
              this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '8vp' : '0vp'
          })
      }
      .height('100%')
      .width('100%')
      .alignContent(Alignment.Top)
    } else {
      Column() {
        HomeHeader({
          mainWindowInfo: this.mainWindowInfo,
          scrollHeight: this.scrollHeight,
          decorWidth: this.decorWidth
        })
          .opacity(this.barOpacity)
          .height(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
            this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? this.topBarHeight : 'auto')
          .padding({ top: new BreakpointType(0, 0, this.topAvoidHeight, this.topAvoidHeight, this.topAvoidHeight)
            .getValue(this.mainWindowInfo.widthBp),
            bottom: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
              this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '8vp' : '0vp' })

        this.HomeScrollContent()
      }
    }
  }

  /**
   * Scrollable content area containing tab-specific content (Featured, Video, Community).
   */
  @Builder
  HomeScrollContent() {
    Scroll(this.scroller) {
      if (this.currentTopIndex === 0) {
        // Featured Content Page
        FeaturedContent({ mainWindowInfo: this.mainWindowInfo })
      } else if (this.currentTopIndex === 1) {
        // Video Content Page
        VideoContent({ mainWindowInfo: this.mainWindowInfo })
      } else if (this.currentTopIndex === 2) {
        // Community Content Page
        CommunityContent({ mainWindowInfo: this.mainWindowInfo })
      } else {
        Column()
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .onScrollFrameBegin((offset: number) => {
      // Obtains the sliding offset on the y axis during sliding.
      this.scrollHeight = this.scroller.currentOffset().yOffset;
      if (this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ||
        this.mainWindowInfo.heightBp > HeightBreakpoint.HEIGHT_MD) {
        return { offsetRemain: offset };
      }
      if (offset > 0) {
        this.currentYOffset += offset;
        if (this.currentYOffset <= HomeConstants.SCROLL_BAR_HIDE_THRESHOLD) {
          this.bottomBarHeight =
            this.bottomBarHeight * (1 - this.currentYOffset / HomeConstants.SCROLL_BAR_HIDE_THRESHOLD);
          this.topBarHeight = this.topBarHeight * (1 - this.currentYOffset / HomeConstants.SCROLL_BAR_HIDE_THRESHOLD);
          this.barOpacity = 1 - this.currentYOffset / HomeConstants.SCROLL_BAR_HIDE_THRESHOLD;
        } else {
          this.topBarHeight = 0;
          this.bottomBarHeight = 0;
          this.barOpacity = 0;
        }
        this.isHiding = true;
      }
      if (offset < 0 && this.isHiding) {
        this.getUIContext().animateTo({
          duration: HomeConstants.BAR_RESTORE_ANIMATION_DURATION
        }, () => {
          this.bottomBarHeight = this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
            this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ?
            HomeConstants.BOTTOM_TAB_BAR_HEIGHT_SM + this.bottomAvoidHeight :
            HomeConstants.BOTTOM_TAB_BAR_HEIGHT + this.bottomAvoidHeight;
          this.topBarHeight = HomeConstants.TOP_BAR_HEIGHT + this.topAvoidHeight;
          this.barOpacity = 1;
          this.currentYOffset = 0;
          this.isHiding = false;
        });
      }
      return { offsetRemain: offset };
    })
  }
}

