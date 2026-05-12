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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { KeyCode } from '@kit.InputKit';
import { display, window } from '@kit.ArkUI';
import {
  AvPlayerUtil,
  DeviceScreen,
  Logger,
  WindowUtil,
  BreakpointConstants,
  DisplayUtil,
  WindowInfo,
  BreakpointVisibilityUtil,
  SetDecorButtonStyleUtil,
} from '@ohos/commons';
import { SelfComment } from './SelfComment';
import { AllComments } from './AllComments';
import { VideoDetailView } from './VideoDetailView';
import { DetailConstants } from '../constants/DetailConstants';

const TAG = '[VideoDetail]';

@Component
export struct VideoDetail {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @StorageLink('isHalfFolded') @Watch('onHalfFoldedChange') isHalfFolded: boolean = false;
  @StorageLink('isFullScreen') @Watch('onFullScreenChange') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @State commentImgHeight: string = DetailConstants.INITIAL_COMMENT_IMAGE_HEIGHT;
  @State commentImgWidth: string = DetailConstants.INITIAL_COMMENT_IMAGE_WIDTH;
  @State relatedVideoHeight: number = DetailConstants.INITIAL_RELATED_VIDEO_HEIGHT;
  @State videoHeight: number = DetailConstants.INITIAL_VIDEO_HEIGHT;
  @State currentYOffset: number = 0;
  @State isHidingSelfComment: boolean = false;
  @Provide('immersiveTypeBefore') immersiveTypeBefore: WindowStatusType = window.WindowStatusType.UNDEFINED;
  @Provide('immersiveTypeCurrent') immersiveTypeCurrent: WindowStatusType = window.WindowStatusType.UNDEFINED;
  private avPlayerUtil?: AvPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
  public screenHeight: number = 0;
  private mainWindow?: window.Window;
  private breakpointFlags() {
    return BreakpointVisibilityUtil.getFlags(this.mainWindowInfo);
  }
  /**
   * Handles window size changes and updates orientation for video playback.
   */
  private onWindowSizeChange: (windowSize: window.Size) => void = () => {
    if (this.pageInfo.getAllPathName().length >= 1 &&
      this.pageInfo.getAllPathName()[this.pageInfo.getAllPathName().length - 1] !==
      DetailConstants.PAGE_NAME_FOR_VIDEO) {
      return;
    }
    if (this.isFullScreen) {
      if ((this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD &&
        this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_SM) ||
        (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM &&
          this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_LG)) {
        this.windowUtil?.setWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        if (!this.isHalfFolded) {
          this.windowUtil?.setWindowOrientation(window.Orientation.FOLLOW_DESKTOP);
        }
      }
    } else {
      this.windowUtil?.setWindowOrientation(window.Orientation.FOLLOW_DESKTOP);
    }
  };

  private onHalfFoldedChange(): void {
    if (this.isHalfFolded) {
      this.windowUtil?.setWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
    } else {
      if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD &&
        this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_MD) {
        this.windowUtil?.setWindowOrientation(window.Orientation.FOLLOW_DESKTOP);
      }
    }
  }

  private onFullScreenChange(): void {
    if (this.isFullScreen) {
      if ((this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD &&
        this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_SM) ||
        (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM &&
          this.mainWindowInfo.heightBp === HeightBreakpoint.HEIGHT_LG)) {
        this.windowUtil?.setWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        if (!this.isHalfFolded) {
          this.windowUtil?.setWindowOrientation(window.Orientation.FOLLOW_DESKTOP);
        }
      }
    } else {
      this.windowUtil?.setWindowOrientation(window.Orientation.FOLLOW_DESKTOP);
    }

    // The navigation bar is hidden in full-screen playback. Otherwise, the navigation bar is displayed.
    try {
      this.windowUtil?.setSystemBarEnabled(!this.isFullScreen);
      // Set the color of the three keys.
      let colorMode: ConfigurationConstant.ColorMode =
        this.isFullScreen ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
          ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
      let style: window.DecorButtonStyle = {
        colorMode: colorMode
      };
      this.windowUtil?.mainWindow.setDecorButtonStyle(style);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to set DecorButtonStyle, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  aboutToAppear() {
    DisplayUtil.getFoldCreaseRegion(this.getUIContext());
    this.screenHeight = DeviceScreen.getDeviceHeight();
    try {
      this.windowUtil?.mainWindow.setWindowDecorVisible(false);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to set WindowDecorVisible, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    this.mainWindow = this.windowUtil?.mainWindow;
    this.mainWindow?.on('windowSizeChange', this.onWindowSizeChange);
  }

  async aboutToDisappear() {
    this.isFullScreen = false;
    this.avPlayerUtil?.offTimeUpdate();
    this.avPlayerUtil?.release();
    if (this.mainWindowInfo.widthBp < WidthBreakpoint.WIDTH_XL) {
      try {
        this.windowUtil?.mainWindow.setWindowDecorVisible(true);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to set WindowDecorVisible, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }

    this.mainWindow?.off('windowSizeChange', this.onWindowSizeChange);
  }

  build() {
    NavDestination() {
      GridRow({
        columns: {
          sm: 4,
          md: 12,
          lg: 12,
          xl: 12
        }
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 12,
            lg: 12,
            xl: 12
          }
        }) {
          SideBarContainer() {
            Column() {
              // Sidebar area.
              Stack() {
                Scroll() {
                  AllComments({
                    commentImgHeight: this.commentImgHeight,
                    commentImgWidth: this.commentImgWidth,
                    mainWindowInfo: this.mainWindowInfo
                  })
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .width('100%')
                .padding({ bottom: '12vp' })

                Column()
                  .width('100%')
                  .height(this.getTopHeight())
                  .backgroundColor(Color.White)
              }
              .layoutWeight(1)
              .alignContent(Alignment.Top)

              SelfComment({ currentYOffset: this.currentYOffset, mainWindowInfo: this.mainWindowInfo })
            }
            .visibility(this.breakpointFlags().isWidthBpAboveMdAndHeightBpBelowLg ? Visibility.Visible :
              Visibility.None)
            .justifyContent(FlexAlign.Start)
            .height('100%')
            .width('100%')
            .backgroundColor(Color.White)
            .onAreaChange((newValue: Area) => {
              if (newValue.width !== 0) {
                // Handling when the width of the sidebar changes.
                let sidebarWidthVp: number = this.getUIContext().px2vp(this.mainWindowInfo.windowSize.width) *
                  DetailConstants.SIDE_BAR_WIDTH_RATIO;
                let height: number = DetailConstants.COMMENT_IMAGE_MIN_HEIGHT_NUMBER +
                  (Number(newValue.width) - DetailConstants.SIDE_BAR_MIN_WIDTH_NUMBER) /
                    (sidebarWidthVp - DetailConstants.SIDE_BAR_MIN_WIDTH_NUMBER) *
                    (DetailConstants.COMMENT_IMAGE_MAX_HEIGHT_NUMBER - DetailConstants.COMMENT_IMAGE_MIN_HEIGHT_NUMBER);
                let width: number = DetailConstants.COMMENT_IMAGE_MIN_WIDTH_NUMBER +
                  (Number(newValue.width) - DetailConstants.SIDE_BAR_MIN_WIDTH_NUMBER) /
                    (sidebarWidthVp - DetailConstants.SIDE_BAR_MIN_WIDTH_NUMBER) *
                    (DetailConstants.COMMENT_IMAGE_MAX_WIDTH_NUMBER - DetailConstants.COMMENT_IMAGE_MIN_WIDTH_NUMBER);
                this.commentImgHeight = JSON.stringify(height);
                this.commentImgWidth = JSON.stringify(width);
              }
            })

            Column() {
              // Content area.
              VideoDetailView({
                screenHeight: this.screenHeight,
                relatedVideoHeight: this.relatedVideoHeight,
                videoHeight: this.videoHeight,
                currentYOffset: this.currentYOffset,
                isHidingSelfComment: this.isHidingSelfComment,
                mainWindowInfo: this.mainWindowInfo
              })
                .layoutWeight(1)

              SelfComment({ currentYOffset: this.currentYOffset, mainWindowInfo: this.mainWindowInfo })
                .visibility(this.breakpointFlags().isWidthBpAboveMdAndHeightBpBelowLg || this.isFullScreen ?
                  Visibility.None : Visibility.Visible)
            }
            .height('100%')
            .width('100%')
          }
          .showSideBar(this.breakpointFlags().isWidthBpAboveMdAndHeightBpBelowLg && !this.isFullScreen ? true : false)
          .showControlButton(false)
          .autoHide(false)
          .sideBarPosition(SideBarPosition.End)
          .sideBarWidth('400vp')
          .minSideBarWidth('400vp')
          .maxSideBarWidth(this.getUIContext().px2vp(this.mainWindowInfo.windowSize.width * 0.4))
        }
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .onBreakpointChange((breakPoints) => {
        if (breakPoints !== BreakpointConstants.BREAKPOINT_LG && breakPoints !== BreakpointConstants.BREAKPOINT_XL &&
          this.videoHeight < DetailConstants.INITIAL_VIDEO_HEIGHT) {
          this.relatedVideoHeight = 0;
        } else if (breakPoints === BreakpointConstants.BREAKPOINT_LG ||
          breakPoints === BreakpointConstants.BREAKPOINT_XL) {
          this.relatedVideoHeight = DetailConstants.INITIAL_RELATED_VIDEO_HEIGHT;
        } else {
          Logger.info(TAG, `No specific function.`);
        }
      })
    }
    .onAppear(() => {
      SetDecorButtonStyleUtil.setDecorButtonForNormal(this.windowUtil);
    })
    .onDisAppear(() => {
      SetDecorButtonStyleUtil.setDecorButtonForImmersive(this.currentTopIndex, this.mainWindowInfo.widthBp,
        this.pageInfo, this.windowUtil);
    })
    .hideTitleBar(true)
    .onShown(() => {
      if (this.avPlayerUtil?.getAvplayerState() !== DetailConstants.AV_PLAYER_PLAYING_STATE) {
        this.avPlayerUtil?.playerStateControl();
      }
      if (canIUse('SystemCapability.Window.SessionManager')) {
        let isDisplayFoldable: boolean = false;
        try {
          isDisplayFoldable = display.isFoldable();
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `Get display isFoldable failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        }
        if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD && isDisplayFoldable) {
          this.isHalfFolded = false;
        }
      }
    })
    .onKeyEvent((event?: KeyEvent) => {
      //If the key type is pressed, the subsequent code will not be executed,
      // and the specific key logic will be executed when released.
      if (!event || event.type !== KeyType.Down) {
        return;
      }
      // Space key controls pause/play.
      if (event.keyCode === KeyCode.KEYCODE_SPACE) {
        this.avPlayerUtil?.playerStateControl();
      } else if (event.keyCode === KeyCode.KEYCODE_ESCAPE) {
        //Press ESC to exit full screen.
        if (this.isFullScreen) {
          this.isFullScreen = false;
          try {
            if (this.windowUtil !== undefined) {
              this.immersiveTypeCurrent = this.windowUtil.mainWindow.getWindowStatus();
            }
          } catch (error) {
            let err = error as BusinessError;
            Logger.error(TAG, `Window getWindowStatus failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          }
          if (this.immersiveTypeCurrent === window.WindowStatusType.FULL_SCREEN &&
            this.immersiveTypeBefore === window.WindowStatusType.MAXIMIZE) {
            this.windowUtil?.mainWindow.maximize(window.MaximizePresentation.EXIT_IMMERSIVE)
              .catch((error: BusinessError) => {
              Logger.error(TAG, `Window maximize failed, errCode = ${error.code}, errMessage = ${error.message}.`);
            });
          } else if (this.immersiveTypeCurrent === window.WindowStatusType.FULL_SCREEN &&
            this.immersiveTypeBefore === window.WindowStatusType.FLOATING) {
            this.windowUtil?.recover();
          }
        }
      } else if (event.keyCode === KeyCode.KEYCODE_DPAD_RIGHT) {
        //Right-click fast forward
        this.avPlayerUtil?.fastForward();
      } else if (event.keyCode === KeyCode.KEYCODE_DPAD_LEFT) {
        //Left click to go back quickly
        this.avPlayerUtil?.rewind();
      } else {
        return;
      }
    })
  }

  getTopHeight(): number {
    if (!(this.mainWindowInfo.heightBp < HeightBreakpoint.HEIGHT_LG &&
      this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG)) {
      return 0;
    }
    let decorHeight: number | undefined = undefined;
    try {
      decorHeight = this.windowUtil?.mainWindow.getTitleButtonRect().height;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to get decorHeight, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    if (!!decorHeight) {
      return decorHeight;
    } else {
      return 0;
    }
  }
}