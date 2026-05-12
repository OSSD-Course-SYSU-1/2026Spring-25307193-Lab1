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

import { WindowInfo,BreakpointType } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { VideoImgItemViewModel, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex,SubtitleComponent,VideoContent,VideoImgComponent, VideoImgPlay, VideoImgRating, VideoTitle } from
  './CommonView';

@Component
export struct NewVideoRelease {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume isOnDisplay: boolean;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  private newVideoImgList: VideoImgItemViewModel[] = new VideoImgViewModel().getNewVideoImgList();

  build() {
    Column() {
      SubtitleComponent({ title: HomeConstants.HOME_SUB_TITLES[0], mainWindowInfo: this.mainWindowInfo })
        .margin({ top: this.isOnDisplay ? '35vp' : '13vp', bottom: this.isOnDisplay ? '16vp' : '0vp' })

      // Video grid
      Grid() {
        ForEach(this.newVideoImgList, (item: VideoImgItemViewModel, index: number) => {
          GridItem() {
            Column() {
              Stack({ alignContent: Alignment.Bottom }) {
                VideoImgComponent(item.getImgSrc(), index)
                VideoImgPlay({ mainWindowInfo: this.mainWindowInfo })
                  .visibility(this.isOnDisplay ? Visibility.None : Visibility.Visible)
                VideoImgRating(item.getRating(), this.isOnDisplay)
                Row() {
                  Text(item.getTitle())
                    .fontSize('16fp')
                    .fontWeight(FontWeight.Normal)
                    .lineHeight('24vp')
                    .margin({ top: '4vp' })
                    .fontColor(Color.White)
                }
                .justifyContent(FlexAlign.Start)
                .width('100%')
                .padding(8)
                .visibility(this.isOnDisplay ? Visibility.Visible : Visibility.None)
              }
              .height(new BreakpointType('120vp', '120vp', '161vp', '211vp',
                '240vp').getValue(this.mainWindowInfo.widthBp))
              .width('100%')
              .aspectRatio(HomeConstants.NEW_VIDEO_ASPECT_RATIO)

              if (!this.isOnDisplay) {
                VideoTitle({ title: item.getTitle() })
                VideoContent({ content: item.getContent() })
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
        }, (item: VideoImgItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[5]))
      .padding({
        left: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
        right: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
        top: this.isOnDisplay ? '8vp' : '13vp',
        bottom: this.isOnDisplay ? '0vp' : '13vp'
      })
      .columnsTemplate(new BreakpointType(HomeConstants.VIDEO_GRID_COLUMNS[1], HomeConstants.VIDEO_GRID_COLUMNS[1],
        HomeConstants.VIDEO_GRID_COLUMNS[3], HomeConstants.VIDEO_GRID_COLUMNS[4],
        HomeConstants.VIDEO_GRID_COLUMNS[4]).getValue(this.mainWindowInfo.widthBp))
      .rowsTemplate(HomeConstants.NEW_VIDEO_ROWS_TEMPLATE)
      .width('100%')
      .columnsGap(this.isOnDisplay ? '32vp' : '12vp')
      .height(this.isOnDisplay ? '210vp' :
        this.getNewVideoHeight(this.mainWindowInfo.widthBp, this.mainWindowInfo.windowSize.width))
    }
    .padding({
      left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG && this.currentTopIndex === 2 &&
        !this.isOnDisplay ? '96vp' : '0vp'
    })
  }

  getNewVideoHeight(currentWidthBreakpoint: number, windowWidth: number): string {
    let result: number = this.getUIContext().px2vp(windowWidth) -
    new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0], HomeConstants.VIDEO_GRID_MARGIN[0],
      HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2],
      HomeConstants.VIDEO_GRID_MARGIN[2]).getValue(this.mainWindowInfo.widthBp);
    if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG) {
      result = result - HomeConstants.LG_SIDEBAR_WIDTH;
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.SIX) / HomeConstants.SEVEN;
    } else if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_MD) {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.FOUR) / HomeConstants.FIVE;
    } else if (currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.TWO) / HomeConstants.THREE;
    } else {
      result = result - HomeConstants.XL_SIDEBAR_WIDTH;
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.SIX) / HomeConstants.SEVEN;
    }
    return (result / HomeConstants.NEW_VIDEO_ASPECT_RATIO + HomeConstants.NEW_VIDEO_DESCRIPTION_HEIGHT +
    HomeConstants.VP_UNIT);
  }
}