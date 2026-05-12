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

import { BreakpointConstants, WindowInfo, BreakpointType } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { VideoImgItemViewModel, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex, SubtitleComponent } from './CommonView';

@Component
export struct TVPreviousVideo {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume isOnDisplay: boolean;
  @Consume('pageInfo') pageInfo: NavPathStack;
  private previousVideoImgListOne: VideoImgItemViewModel[] = new VideoImgViewModel().getTVPreviousVideoOne();
  private previousVideoImgListTwo: VideoImgItemViewModel[] = new VideoImgViewModel().getTVPreviousVideoImgListTwo();

  build() {
    Column() {
      SubtitleComponent({ title: HomeConstants.HOME_SUB_TITLES[2], mainWindowInfo: this.mainWindowInfo })
        .margin({ top: this.isOnDisplay ? '35vp' : '13vp', bottom: this.isOnDisplay ? '16vp' : '0vp' })

      GridRow({
        columns: {
          xs: BreakpointConstants.GRID_ROW_COLUMNS[2],
          sm: BreakpointConstants.GRID_ROW_COLUMNS[2],
          md: BreakpointConstants.GRID_ROW_COLUMNS[0],
          lg: BreakpointConstants.GRID_ROW_COLUMNS[0],
          xl: BreakpointConstants.GRID_ROW_COLUMNS[1]
        },
        gutter: this.isOnDisplay ? '32vp' : '12vp'
      }) {
        ForEach(this.previousVideoImgListOne, (item: VideoImgItemViewModel, _index: number) => {
          GridCol({
            span: {
              xs: BreakpointConstants.GRID_COLUMN_SPANS[5],
              sm: BreakpointConstants.GRID_COLUMN_SPANS[5],
              md: BreakpointConstants.GRID_COLUMN_SPANS[1],
              lg: BreakpointConstants.GRID_COLUMN_SPANS[4],
              xl: BreakpointConstants.GRID_COLUMN_SPANS[3]
            }
          }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(item.getImgSrc())
                .objectFit(ImageFit.Cover)
                .margin({
                  right: this.isOnDisplay ? '0vp' :
                    this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp'
                })
                .layoutWeight(3)
                .height('100%')
                .borderRadius(16)

              Text(item.getTitle())
                .fontSize(new BreakpointType('14fp', '14fp', '16fp', '18fp',
                  '20fp').getValue(this.mainWindowInfo.widthBp))
                .fontWeight(500)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(Color.White)
                .margin({
                  left: '15vp',
                  bottom: '20vp'
                })
            }
            .aspectRatio(0.7)
            .width('100%')
            .borderRadius(36)
            .onClick(() => {
              this.pageInfo.pushPath({ name: HomeConstants.PAGE_NAME_FOR_VIDEO });
            })
          }
        }, (item: VideoImgItemViewModel, index: number) => index + JSON.stringify(item))

        ForEach(this.previousVideoImgListTwo, (item: VideoImgItemViewModel, _index: number) => {
          GridCol({
            span: {
              xs: BreakpointConstants.GRID_COLUMN_SPANS[5],
              sm: BreakpointConstants.GRID_COLUMN_SPANS[5],
              md: BreakpointConstants.GRID_COLUMN_SPANS[1],
              lg: BreakpointConstants.GRID_COLUMN_SPANS[1],
              xl: BreakpointConstants.GRID_COLUMN_SPANS[3]
            }
          }) {
            Row() {
              Image(item.getImgSrc())
                .objectFit(ImageFit.Cover)
                .layoutWeight(3)
                .height('100%')
                .borderRadius(16)
            }
            .aspectRatio(2.3)
            .width('100%')
            .borderRadius(36)
          }
          .margin({
            top: this.isOnDisplay ? '0vp' : '12vp'
          })
        }, (item: VideoImgItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .padding({
        left: new BreakpointType('16vp', '16vp', '24vp', '36vp', '42vp').getValue(this.mainWindowInfo.widthBp),
        right: new BreakpointType('16vp', '16vp', '24vp', '36vp', '42vp').getValue(this.mainWindowInfo.widthBp)})
      .margin({ top: this.isOnDisplay ? '8vp' : '12vp', bottom: this.isOnDisplay ? '32vp' : '0vp' })
    }
    .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[8]))
  }
}