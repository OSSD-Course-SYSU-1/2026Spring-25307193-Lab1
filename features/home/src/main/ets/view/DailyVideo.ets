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

import { BreakpointType, BreakpointVisibilityUtil, WindowInfo } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { VideoImgItemViewModel, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex,
  MembershipTag,
  SubtitleComponent, VideoImgComponent, VideoImgPlay, VideoImgRating } from './CommonView';

@Component
export struct DailyVideo {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume isOnDisplay: boolean;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @State isShowingMainBorder: boolean = false;
  private dailyVideoImgList: VideoImgItemViewModel[] = new VideoImgViewModel().getDailyVideoImgList();
  private mainDailyVideoImg: VideoImgItemViewModel = new VideoImgViewModel().getMainDailyVideoImg();
  private breakpointFlags() {
    return BreakpointVisibilityUtil.getFlags(this.mainWindowInfo);
  }

  build() {
    Column() {
      SubtitleComponent({ title: $r('app.string.DailyVideo'), mainWindowInfo: this.mainWindowInfo })
        .margin({ top: this.isOnDisplay ? '35vp' : '13vp', bottom: this.isOnDisplay ? '16vp' : '0vp' })

      GridRow({
        columns: { sm: 4, md: 12 },
        gutter: this.isOnDisplay ? '32vp' : '12vp'
      }) {
        // Main video section.
        GridCol({ span: { xs: 4, sm: 4, md: 6, lg: 6, xl: 6 } }) {
          Column() {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(this.mainDailyVideoImg.getImgSrc() ? this.mainDailyVideoImg.getImgSrc() : '')
                .focusable(true)
                .objectFit(ImageFit.Cover)
                .width('100%')
                .height('100%')
                .draggable(false)
                .borderRadius(this.isOnDisplay ? 18 : {
                  topLeft: 16,
                  topRight: 16
                })
              VideoImgPlay({ mainWindowInfo: this.mainWindowInfo })
                .visibility(this.isOnDisplay ? Visibility.None : Visibility.Visible)

              Row() {
                Text(this.mainDailyVideoImg.getTitle())
                  .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '20fp' : '16fp')
                  .fontColor(Color.White)
                  .fontWeight(700)
                  .margin({ left: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp' })
                  .layoutWeight(1)
                  .maxLines(1)

                Text(this.mainDailyVideoImg.getRating())
                  .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '12fp' : '8fp')
                  .fontWeight(FontWeight.Normal)
                  .fontColor(Color.White)
                  .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '18vp' : '12vp')
                  .width(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '30vp' : '20vp')
                  .margin({
                    right: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp',
                    top: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '6vp' : '5vp'
                  })
                  .backgroundColor($r('app.color.main_daily_rating_background'))
                  .borderRadius(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '3vp' : '2vp')
                  .textAlign(TextAlign.Center)
                  .visibility(this.isOnDisplay ? Visibility.None : Visibility.Visible)
              }
              .alignItems(VerticalAlign.Top)
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '46vp' : '33vp')

              Column() {
                MembershipTag()
              }
              .width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.End)
              .justifyContent(FlexAlign.Start)
              .visibility(this.isOnDisplay ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .layoutWeight(5)

            if (!this.isOnDisplay) {
              Row() {
                Image($r('app.media.daily_small_video'))
                  .height(new BreakpointType('40vp', '40vp', '44vp', '68vp',
                    '88vp').getValue(this.mainWindowInfo.widthBp))
                  .width(new BreakpointType('76vp', '76vp', '84vp', '129vp',
                    '168vp').getValue(this.mainWindowInfo.widthBp))
                  .borderRadius(8)

                Column() {
                  Text(this.mainDailyVideoImg.getOtherInfo())
                    .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '14vp')
                    .fontWeight(FontWeight.Normal)
                    .maxLines(1)
                  Text(this.mainDailyVideoImg.getContent())
                    .opacity(0.4)
                    .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '14vp' : '12vp')
                    .fontWeight(FontWeight.Normal)
                    .maxLines(1)
                }
                .margin({
                  left: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp',
                  right: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp'
                })
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Button($r('app.string.follow'))
                  .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '14fp' : '12fp')
                  .fontColor($r('app.color.tab_sel_color'))
                  .fontWeight(500)
                  .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '34vp' : '34vp')
                  .width(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '77vp' : '77vp')
                  .borderRadius(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? 12 : '50%')
                  .backgroundColor($r('app.color.button_background'))
              }
              .alignItems(VerticalAlign.Center)
              .padding({
                left: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp',
                right: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16vp' : '12vp'
              })
              .layoutWeight(2)
            }
          }
          .tabIndex(getTabIndex('DailyVideoOne'))
          .width('100%')
          // Dynamically setting the height at different breakpoints.
          .height(this.isOnDisplay ? '356vp' :
            this.getDailyVideoHeight(this.mainWindowInfo.widthBp, this.mainWindowInfo.windowSize.width, true))
          .borderRadius(18)
          .backgroundColor($r('app.color.home_component_background'))
        }
        .padding({
          top: this.isOnDisplay ? '8vp' : '13vp',
          bottom: this.isOnDisplay ? '0vp' : this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ? '13vp' : '0vp',
          left: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
          right: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '16vp' : '0vp'
        })

        // Sub video section.
        GridCol({
          span: {
            xs: 4,
            sm: 4,
            md: 6,
            lg: 6,
            xl: 6
          }
        }) {
          Grid() {
            ForEach(this.dailyVideoImgList, (item: VideoImgItemViewModel) => {
              GridItem() {
                Column() {
                  Stack({ alignContent: Alignment.Bottom }) {
                    VideoImgComponent(item.getImgSrc())
                    VideoImgPlay({
                      mainWindowInfo: this.mainWindowInfo
                    })
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

                    Column() {
                      MembershipTag()
                    }
                    .width('100%')
                    .height('100%')
                    .alignItems(HorizontalAlign.End)
                    .justifyContent(FlexAlign.Start)
                    .visibility(this.isOnDisplay ? Visibility.Visible : Visibility.None)
                  }
                  .width('100%')
                  // The width and height vary with the container assembly and the aspect ratio remains unchanged.
                  .aspectRatio(1.74)

                  Text(item.getTitle())
                    .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '16fp' : '14fp')
                    .fontWeight(FontWeight.Normal)
                    .lineHeight(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '24vp' : '21vp')
                    .margin({ top: '4vp' })
                    .fontColor(this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
                    .visibility(this.isOnDisplay ? Visibility.None : Visibility.Visible)

                  Text(item.getContent())
                    .fontSize('12fp')
                    .fontWeight(FontWeight.Normal)
                    .lineHeight('18vp')
                    .margin({ top: '2vp' })
                    .opacity(0.4)
                    .fontColor(this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
                    .visibility(this.breakpointFlags().isWidthBpBelowMd ? Visibility.Visible : Visibility.None)
                }
                .alignItems(HorizontalAlign.Start)
              }
            }, (item: VideoImgItemViewModel, index: number) => index + JSON.stringify(item))
          }
          .tabIndex(getTabIndex('DailyVideoTwo'))
          // Dynamically setting the height at different breakpoints.
          .height(this.isOnDisplay ? '364vp' :
            this.getDailyVideoHeight(this.mainWindowInfo.widthBp, this.mainWindowInfo.windowSize.width, false))
          .width('100%')
          // Sets the number of grid layout columns and evenly divides the height.
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .rowsGap(this.isOnDisplay ? '32vp' : '12vp')
          .columnsGap(this.isOnDisplay ? '32vp' : '12vp')
          .padding({
            top: this.isOnDisplay ? '8vp' : this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ? '13vp' : '6vp',
            bottom: this.isOnDisplay ? '0vp' : this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ? '13vp' : '6vp',
            left: this.isOnDisplay ? '0vp' : this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '16vp' : '6vp',
            right: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp)
          })
        }
      }
    }
    .padding({
      left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG && this.currentTopIndex === 2 &&
        !this.isOnDisplay ? '96vp' : '0vp'
    })
    .margin({ top: this.isOnDisplay ? '0vp' : '12vp' })
  }

  getDailyVideoHeight(currentWidthBreakpoint: number, windowWidth: number, isMain: boolean): string {
    // Obtain the window width and subtract the blank parts on both sides.
    let result: number = this.getUIContext().px2vp(windowWidth) - new BreakpointType(
      HomeConstants.VIDEO_GRID_MARGIN[0], HomeConstants.VIDEO_GRID_MARGIN[0],
      HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2], HomeConstants.VIDEO_GRID_MARGIN[2])
      .getValue(this.mainWindowInfo.widthBp) - HomeConstants.VIDEO_GRID_ITEM_SPACE;
    // Calculate the width of a single image based on the number of grid columns.
    if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG) {
      result = (result - HomeConstants.LG_SIDEBAR_WIDTH) / HomeConstants.DAILY_VIDEO_GRID_COLUMN_COUNT;
    } else if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_MD) {
      result /= HomeConstants.DAILY_VIDEO_GRID_COLUMN_COUNT;
    } else if (currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
      result /= HomeConstants.DAILY_VIDEO_GRID_COLUMN_COUNT_SM;
    } else {
      result = (result - HomeConstants.XL_SIDEBAR_WIDTH) / HomeConstants.DAILY_VIDEO_GRID_COLUMN_COUNT;
    }
    // Calculate the height of a single image and title, and calculate the total height of the grid layout.
    result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE) / HomeConstants.VIDEO_DIALOG_ASPECT_RATIO;
    if (currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
      if (isMain) {
        return (result + HomeConstants.DAILY_VIDEO_DESCRIPTION_HEIGHT[0] + HomeConstants.VP_UNIT);
      } else {
        return (result + HomeConstants.DAILY_VIDEO_DESCRIPTION_HEIGHT[2] + HomeConstants.VP_UNIT);
      }
    } else {
      if (!isMain) {
        return (result + HomeConstants.DAILY_VIDEO_DESCRIPTION_HEIGHT[1] + HomeConstants.VP_UNIT);
      } else {
        return (result + HomeConstants.DAILY_VIDEO_DESCRIPTION_HEIGHT[3] + HomeConstants.VP_UNIT);
      }
    }
  }
}