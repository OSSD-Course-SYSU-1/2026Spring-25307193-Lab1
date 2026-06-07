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
import { WindowInfo, Logger } from '@ohos/commons';
import { RelatedList } from './RelatedList';
import { CurrentOffsetUtil } from '../utils/CurrentOffsetUtil';
import { DetailConstants } from '../constants/DetailConstants';
import { VideoPlayer } from './VideoPlayer';
import { FooterEpisodes } from './FooterEpisodes';
import { SideEpisodes } from './SideEpisodes';
import { AISummary } from './AISummary';

const TAG = '[VideoDetailView]';

@Component
export struct VideoDetailView {
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  // The current vertical sliding distance of the list.
  @Link currentYOffset: number;
  @Link isHidingSelfComment: boolean;
  @State isShowingSideBar: boolean = false;
  @State foldStatus: display.FoldStatus | undefined = undefined
  public screenHeight: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        this.foldStatus = display.getFoldStatus();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `getFoldStatus failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          Column() {
            VideoPlayer({
              videoHeight: this.videoHeight,
              isShowingSideBar: this.isShowingSideBar,
              foldStatus: this.foldStatus,
              mainWindowInfo: this.mainWindowInfo
            })

            Blank()
              .height(this.creaseRegion[1])
              .width('100%')
              .visibility(this.isHalfFolded && this.isShowingSideBar && this.isFullScreen ? Visibility.Visible :
                Visibility.None)

            FooterEpisodes({
              isShowingSideBar: this.isShowingSideBar,
              foldStatus: this.foldStatus,
              mainWindowInfo: this.mainWindowInfo
            })
          }
          .layoutWeight(3)

          SideEpisodes({
            isShowingSideBar: this.isShowingSideBar,
            foldStatus: this.foldStatus,
            mainWindowInfo: this.mainWindowInfo
          })
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor(Color.Black)
        .height(this.isFullScreen ? '100%' : 'auto')
        .width('100%')

        // AI视频总结组件
        AISummary({
          videoIdProp: 'video1',
          videoTitleProp: '华为春季旗舰新品发布会'
        })
          .margin({ top: '16vp' })
          .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)

        RelatedList({
          relatedVideoHeight: this.relatedVideoHeight,
          videoHeight: this.videoHeight,
          screenHeight: this.screenHeight,
          currentYOffset: this.currentYOffset,
          isHidingSelfComment: this.isHidingSelfComment,
          mainWindowInfo: this.mainWindowInfo
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height('100%')
    .onScrollFrameBegin((offset: number) => {
      if (this.isFullScreen) {
        return { offsetRemain: offset };
      }
      if (this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG) {
        if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((offset < 0) && (this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else {
          Logger.info(TAG, `No specific function`);
        }
      } else if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD) {
        if (offset > 0) {
          this.currentYOffset += offset;
          this.isHidingSelfComment = true;
          if (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) {
            // Video zoom-out logic.
            // Percentage of screen height by sliding.
            let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
            // Video shrinkage percentage.
            let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
              this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
            this.videoHeight = this.videoHeight - heightOffset;
          }
        } else if (offset < 0) {
          if (this.isHidingSelfComment) {
            this.getUIContext().animateTo({
              duration: 300
            }, () => {
              this.currentYOffset = 0;
              this.isHidingSelfComment = false;
            });
          }
          if ((this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
            (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
            // Video magnification logic.
            let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
            let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
              DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
            this.videoHeight = this.videoHeight + heightOffset;
          }
        }
      } else {
        if ((offset > 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight === 0) &&
          (offset < 0) && (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else if ((offset < 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) &&
          (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) >
          DetailConstants.RELATED_LIST_HEIGHT ? DetailConstants.RELATED_LIST_HEIGHT : (this.relatedVideoHeight +
            offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else {
          Logger.info(TAG, `No specific function`);
        }
      }
      // Returns the actual offset 0.
      return { offsetRemain: 0 };
    })
  }
}