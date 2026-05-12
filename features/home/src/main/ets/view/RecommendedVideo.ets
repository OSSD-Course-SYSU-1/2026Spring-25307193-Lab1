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

import { BusinessError } from '@kit.BasicServicesKit';
import { componentUtils } from '@kit.ArkUI';
import { BreakpointType, Logger, WindowUtil, WindowInfo } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { VideoImgItemViewModel, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex, MembershipTag, VideoContent, VideoImgRating, VideoTitle } from './CommonView';
import { RightClickMenu, VideoDialog } from './VideoDialog';

const TAG = '[RecommendedVideo]';

@Component
export struct RecommendedVideo {
  @ObjectLink @Watch('mainWindowInfoChange') mainWindowInfo: WindowInfo;
  @Consume isOnDisplay: boolean;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @State videoGridColumn: string = HomeConstants.VIDEO_GRID_COLUMNS[2];
  @State isShowingRecommendBorder: boolean = false;
  @State currentRecommendFocusIndex: number = 0;
  @State videoImgList: VideoImgItemViewModel[] = new VideoImgViewModel().getVideoImgList();
  private videoDialogController?: CustomDialogController;
  private curBp: WidthBreakpoint = this.mainWindowInfo.widthBp;

  aboutToAppear(): void {
    this.updateVideoGridColumn();
  }

  /**
   * Updates video grid column when window breakpoint changes.
   */
  mainWindowInfoChange(): void {
    if (this.curBp !== this.mainWindowInfo.widthBp) {
      this.curBp = this.mainWindowInfo.widthBp;
      this.updateVideoGridColumn();
    }
  }

  /**
   * Updates grid column template based on current width breakpoint.
   */
  updateVideoGridColumn(): void {
    if (this.curBp === WidthBreakpoint.WIDTH_XS) {
      this.videoGridColumn = HomeConstants.VIDEO_GRID_COLUMNS[0];
    } else if (this.curBp === WidthBreakpoint.WIDTH_SM) {
      this.videoGridColumn = HomeConstants.VIDEO_GRID_COLUMNS[0];
    } else if (this.curBp === WidthBreakpoint.WIDTH_MD) {
      this.videoGridColumn = HomeConstants.VIDEO_GRID_COLUMNS[1];
    } else if (this.curBp === WidthBreakpoint.WIDTH_LG) {
      this.videoGridColumn = HomeConstants.VIDEO_GRID_COLUMNS[2];
    } else {
      this.videoGridColumn = HomeConstants.VIDEO_GRID_COLUMNS[1];
    }
  }

  build() {
    // Video grid layout.
    Grid() {
      ForEach(this.videoImgList, (item: VideoImgItemViewModel, index: number) => {
        GridItem() {
          Column() {
            Stack({ alignContent: Alignment.Center }) {
              Image(item.getImgSrc())
                .objectFit(ImageFit.Fill)
                .width('100%')
                .height('100%')
                .hoverEffect(HoverEffect.Scale)
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .draggable(false)
                .borderRadius(12)
                .id(JSON.stringify(item))
              Column() {
                VideoImgRating(item.getRating())
              }
              .width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.End)
              .justifyContent(FlexAlign.End)
              .visibility(this.isOnDisplay ? Visibility.None : Visibility.Visible)

              Column() {
                MembershipTag(item.getMemberShipTag())
              }
              .width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.End)
              .justifyContent(FlexAlign.Start)
              .visibility(this.isOnDisplay ? Visibility.Visible : Visibility.None)
            }
            .focusable(true)
            .width('100%')
            // The width and height vary with the container assembly and the aspect ratio remains unchanged.
            .aspectRatio(1.74)
            .hoverEffect(HoverEffect.Scale)
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction(() => {
                  // Show video preview information only in the first image.
                  if (index !== 0) {
                    return;
                  }
                  // Obtains all attributes of a component.
                  try {
                    let modePosition: componentUtils.ComponentInfo =
                      this.getUIContext().getComponentUtils().getRectangleById(JSON.stringify(item));
                    let windowOffset = modePosition.windowOffset;
                    let size = modePosition.size;
                    // Obtains the height of the component from the top.
                    let rectTop: number = this.getUIContext().px2vp(windowOffset.y);
                    let rectTop2: number = this.getUIContext().px2vp(windowOffset.y + Math.floor(size.height));
                    // Obtains the width of the component from the left.
                    let rectLeft: number = this.getUIContext().px2vp(windowOffset.x);
                    let topHeightNeeded: number =
                      new BreakpointType(HomeConstants.VIDEO_DIALOG_HEIGHTS[0], HomeConstants.VIDEO_DIALOG_HEIGHTS[0],
                        HomeConstants.VIDEO_DIALOG_HEIGHTS[1], HomeConstants.VIDEO_DIALOG_HEIGHTS[2],
                        HomeConstants.VIDEO_DIALOG_HEIGHTS[2]).getValue(this.mainWindowInfo.widthBp) + rectTop -
                        rectTop2;
                    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM) {
                      topHeightNeeded += HomeConstants.HOME_HEADER_HEIGHT_SM;
                    }
                    let dialogYOffset: number;
                    // Adaptive pop-up window expansion direction.
                    if (topHeightNeeded < rectTop) {
                      dialogYOffset = rectTop2 -
                      new BreakpointType(HomeConstants.VIDEO_DIALOG_HEIGHTS[0], HomeConstants.VIDEO_DIALOG_HEIGHTS[0],
                        HomeConstants.VIDEO_DIALOG_HEIGHTS[1], HomeConstants.VIDEO_DIALOG_HEIGHTS[2],
                        HomeConstants.VIDEO_DIALOG_HEIGHTS[2]).getValue(this.mainWindowInfo.widthBp);
                    } else {
                      dialogYOffset = rectTop;
                    }
                    let isLayoutFullScreen = this.windowUtil?.mainWindow?.getWindowProperties().isLayoutFullScreen;
                    // Subtract the width and height of the window.
                    if (isLayoutFullScreen !== undefined && !isLayoutFullScreen) {
                      dialogYOffset -= HomeConstants.WINDOW_UNDEFINED_TOP;
                      rectLeft -= HomeConstants.WINDOW_UNDEFINED_LEFT;
                    } else {
                      Logger.info(TAG, `No need to subtract extra height.`);
                    }
                    this.videoDialogController = new CustomDialogController({
                      builder: VideoDialog({ mainWindowInfo: this.mainWindowInfo }),
                      autoCancel: true,
                      customStyle: true,
                      alignment: DialogAlignment.TopStart,
                      offset: {
                        dx: rectLeft,
                        dy: dialogYOffset
                      }
                    });
                    // Display the customized pop-up window to play the video.
                    this.videoDialogController.open();
                  } catch (error) {
                    let err = error as BusinessError;
                    Logger.error(TAG, `Show video preview failed, errCode = ${err.code}, errMessage = ${err.message}`);
                  }
                }))
            .bindContextMenu(RightClickMenu(this.mainWindowInfo.widthBp), ResponseType.RightClick)
            VideoTitle({ title: item.getTitle() })
            VideoContent({ content: item.getContent() })
          }
          .alignItems(HorizontalAlign.Start)
        }
      }, (item: VideoImgItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[4]))
    .editMode(false)
    // Sets the number of grid layout columns and evenly divides the width.
    .columnsTemplate(this.videoGridColumn)
    .rowsTemplate('1fr 1fr')
    .width('100%')
    .rowsGap(this.isOnDisplay ? '32vp' : '12vp')
    .columnsGap(this.isOnDisplay ? '32vp' : '12vp')
    // Dynamically calculates the total height based on the following numbers of breakpoints.
    .height(this.getGridHeight(this.videoGridColumn, this.mainWindowInfo.widthBp, this.mainWindowInfo.windowSize.width))
    .padding({
      left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG && this.currentTopIndex === 2 &&
        !this.isOnDisplay ?
        new BreakpointType('112vp', '112vp', '120vp', '132vp', '132vp').getValue(this.mainWindowInfo.widthBp) :
        new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
      right: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
      top: '12vp',
      bottom: '6vp'
    })
    // Zooming and pinching functions of the grid.
    .gesture(PinchGesture({ fingers: 2 }).onActionUpdate((event: GestureEvent) => {
      if (event.scale > 1 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM) {
        if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ||
          this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL) {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr';
          })
        } else {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr';
          })
        }
      } else if (event.scale < 1 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM) {
        if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ||
          this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL) {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr';
          })
        } else {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr 1fr';
          })
        }
      } else {
        Logger.warn(TAG, `Two-finger operation is not supported.`);
      }
    }))
  }

  getGridHeight(videoGridColumn: string, currentWidthBreakpoint: number, windowWidth: number): string {
    // Obtain the window width and subtract the blank parts on both sides.
    let result: number = this.getUIContext().px2vp(windowWidth) -
    new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0], HomeConstants.VIDEO_GRID_MARGIN[0],
      HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2],
      HomeConstants.VIDEO_GRID_MARGIN[2]).getValue(this.mainWindowInfo.widthBp);
    if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG && !this.isOnDisplay) {
      result = result - HomeConstants.LG_SIDEBAR_WIDTH;
    }
    if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_XL) {
      result = result - HomeConstants.XL_SIDEBAR_WIDTH;
    }
    // Calculate the width of a single image based on the number of grid columns.
    if (videoGridColumn === '1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.VIDEO_GRID_GAP_COUNT_TWO_COLUMNS) /
      HomeConstants.TWO;
    } else if (videoGridColumn === '1fr 1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.VIDEO_GRID_GAP_COUNT_THREE_COLUMNS) /
      HomeConstants.THREE;
    } else if (videoGridColumn === '1fr 1fr 1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.VIDEO_GRID_GAP_COUNT_FOUR_COLUMNS) /
      HomeConstants.FOUR;
    } else {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * HomeConstants.VIDEO_GRID_GAP_COUNT_FIVE_COLUMNS) /
      HomeConstants.FIVE;
    }
    // Calculate the height of a single image, title, and content, and calculate the total height of the grid layout.
    return result / HomeConstants.VIDEO_DIALOG_ASPECT_RATIO * HomeConstants.VIDEO_GRID_ROW_COUNT +
    HomeConstants.VIDEO_GRID_DESCRIPTION_HEIGHT + HomeConstants.HEIGHT_UNIT;
  }
}