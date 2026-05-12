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

import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AvPlayerUtil,
  ImmersiveType,
  Logger,
  WindowInfo,
  WindowUtil } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';

const TAG = '[VideoPlayer]';

@Component
export struct VideoPlayer {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @State currentTime: string = DetailConstants.INITIAL_TIME;
  @State totalTime: string = DetailConstants.INITIAL_TIME;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @State progress: number = 0;
  @State avplayerState: string = '';
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link videoHeight: number;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Consume('immersiveTypeBefore') immersiveTypeBefore: WindowStatusType;
  @Consume('immersiveTypeCurrent') immersiveTypeCurrent: WindowStatusType;
  private avPlayerUtil?: AvPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
  private xComponentController: XComponentController = new XComponentController();
  private onPlayerStateChange: () => void = () => {
    if (this.avPlayerUtil) {
      this.currentTime = this.avPlayerUtil.getCurrentTime();
      this.totalTime = this.avPlayerUtil.getTotalTime();
      this.progress = this.avPlayerUtil.getProgress();
      this.avplayerState = this.avPlayerUtil.getAvplayerState();
    }
  };
  private onFoldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.foldStatus = data;
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
        try {
          let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
          if ((orientation === display.Orientation.LANDSCAPE ||
            orientation === display.Orientation.LANDSCAPE_INVERTED) &&
            this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD) {
            this.isHalfFolded = true;
            // Full-screen playback.
            if (!this.isFullScreen) {
              this.isFullScreen = true;
            }
          }
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `getDefaultDisplaySync failed, errCode = ${err.code}, errMessage = ${err.message}.`)
        }
      } else {
        this.isHalfFolded = false;
      }
    }
  };

  aboutToAppear(): void {
    this.avPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
    this.avPlayerUtil?.addStateChangeListener(this.onPlayerStateChange);
    this.onPlayerStateChange;
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.on('foldStatusChange', this.onFoldStatusChange);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `onFoldStatusChange failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  aboutToDisappear(): void {
    this.avPlayerUtil?.removeStateChangeListener(this.onPlayerStateChange);
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.off('foldStatusChange');
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `onFoldStatusChange failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  build() {
    Stack({ alignContent: this.isFullScreen ? Alignment.Center : Alignment.Bottom }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: this.isHalfFolded ? FlexAlign.Start : FlexAlign.Center,
        alignItems: ItemAlign.Start
      }) {
        Column() {
          XComponent({
            id: 'home',
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .onLoad(() => {
              this.avPlayerUtil?.createAvPlayer(this.xComponentController.getXComponentSurfaceId());
              AppStorage.setOrCreate('detailSurfaceId', this.xComponentController.getXComponentSurfaceId());
            })
            .width(this.isFullScreen ? -1 : this.videoHeight + '%')
            .aspectRatio(1.78)
        }
        .justifyContent(FlexAlign.Center)
        .height(this.isHalfFolded ? this.creaseRegion[0] : (this.isFullScreen ? '100%' : 'auto'))
        .width('100%')
      }
      .width('100%')
      .onClick(() => {
        if (this.isShowingSideBar) {
          this.isShowingSideBar = false;
        } else {
          this.avPlayerUtil?.playerStateControl();
        }
      })
      .priorityGesture(
        TapGesture({ count: 2 })
          .onAction((event: GestureEvent) => {
            if (event && (this.mainWindowInfo.windowStatusType === window.WindowStatusType.FLOATING ||
              this.mainWindowInfo.windowStatusType === window.WindowStatusType.MAXIMIZE)) {
              this.isFullScreen = true;
              try {
                if (this.windowUtil !== undefined) {
                  this.immersiveTypeBefore = this.windowUtil.mainWindow.getWindowStatus();
                }
              } catch (error) {
                let err = error as BusinessError;
                Logger.error(TAG, `Window maximize failed, errCode = ${err.code}, errMessage = ${err.message}.`);
              }
              this.windowUtil?.setImmersiveType(ImmersiveType.FULLSCREEN_IMMERSIVE);
            }
          })
      )

      Column() {
        Row() {
          TimeText({ time: this.currentTime })
            .margin({
              left: '24vp',
              right: '2vp'
            })

          Slider({
            min: 0,
            max: 100,
            step: 1,
            value: this.progress
          })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.avPlayerUtil?.sliderChange(value, mode);
            })
            .layoutWeight(1)
            .selectedColor($r('app.color.time_slider_select_color'))

          TimeText({ time: this.totalTime })
            .margin({
              left: '2vp',
              right: '24vp'
            })
        }
        .width('100%')
        .height('40vp')
        .alignItems(VerticalAlign.Center)
        .visibility(this.isFullScreen ? Visibility.Visible : Visibility.None)

        Row() {
          Row() {
            Image(this.avplayerState === 'playing' ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
              .height('24vp')
              .width('24vp')
              .margin({ left: '24vp' })
              .onClick(() => {
                this.avPlayerUtil?.playerStateControl();
              })
            this.ImgIcon($r('app.media.ic_public_play_next'))
            this.ImgIcon($r('app.media.ic_public_view_list_white'))
          }
          .margin({
            top: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '4vp' : '16vp',
            bottom: this.mainWindowInfo.widthBp <=  WidthBreakpoint.WIDTH_SM ? '19vp' : '28vp'
          })

          Blank()

          Row() {
            this.TextButton($r('app.string.selections'), ()=>{
              this.isShowingSideBar = !this.isShowingSideBar;
            })
            this.TextButton($r('app.string.super'))
            this.TextButton($r('app.string.super'))
          }
          .margin({
            top: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '4vp' : '16vp',
            bottom: this.mainWindowInfo.widthBp <=  WidthBreakpoint.WIDTH_SM ? '19vp' : '28vp'
          })
        }
        .height('60vp')
        .width('100%')
        .visibility(this.isFullScreen ? Visibility.Visible : Visibility.None)
      }
      .height(this.isFullScreen ? '100%' : 'auto')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .visibility(this.isFullScreen && !this.isShowingSideBar ? Visibility.Visible : Visibility.None)
      .priorityGesture(
        TapGesture({ count: 2 })
          .onAction((event: GestureEvent) => {
            if (event && this.mainWindowInfo.windowStatusType === window.WindowStatusType.FLOATING ||
              this.mainWindowInfo.windowStatusType === window.WindowStatusType.MAXIMIZE) {
              this.isFullScreen = true;
              try {
                if (this.windowUtil) {
                  this.immersiveTypeBefore = this.windowUtil.mainWindow.getWindowStatus();
                }
              } catch (error) {
                let err = error as BusinessError;
                Logger.error(TAG, `Window maximize failed, errCode = ${err.code}, errMessage = ${err.message}.`);
              }
              this.windowUtil?.setImmersiveType(ImmersiveType.FULLSCREEN_IMMERSIVE);
            }
          })
      )

      Row() {
        TimeText({ time: this.currentTime })
          .margin({
            left: '24vp',
            right: '2vp'
          })

        Slider({
          min: 0,
          max: 100,
          step: 1,
          value: this.progress
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.avPlayerUtil?.sliderChange(value, mode);
          })
          .layoutWeight(1)
          .selectedColor($r('app.color.time_slider_select_color'))

        TimeText({ time: this.totalTime })
          .margin({
            left: '2vp',
            right: '8vp'
          })

        Image($r('app.media.ic_public_enlarge'))
          .height('24vp')
          .width('24vp')
          .margin({ right: '24vp' })
          .fillColor(Color.White)
          .onClick(() => {
            this.isFullScreen = true;
          })

        Image($r('app.media.ic_public_fullscreen'))
          .height('24vp')
          .width('24vp')
          .margin({ right: '24vp' })
          .fillColor(Color.White)
          .visibility(this.mainWindowInfo.windowStatusType === window.WindowStatusType.FLOATING ||
            this.mainWindowInfo.windowStatusType === window.WindowStatusType.MAXIMIZE ? Visibility.Visible :
            Visibility.None)
          .onClick(() => {
            this.isFullScreen = true;
            try {
              if (this.windowUtil !== undefined) {
                this.immersiveTypeBefore = this.windowUtil.mainWindow.getWindowStatus();
              }
            } catch (error) {
              let err = error as BusinessError;
              Logger.error(TAG, `Window maximize failed, errCode = ${err.code}, errMessage = ${err.message}.`);
            }
            this.windowUtil?.setImmersiveType(ImmersiveType.FULLSCREEN_IMMERSIVE);
          })
      }
      .width('100%')
      .height('40vp')
      .alignItems(VerticalAlign.Center)
      .visibility(this.isFullScreen || (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD &&
        this.videoHeight < DetailConstants.INITIAL_VIDEO_HEIGHT) ? Visibility.None : Visibility.Visible)


      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize('24fp')
          .fontColor([Color.White])
      }
      .width('40vp')
      .height('40vp')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_LG ? '#1affffff' : '')
      .borderRadius('50%')
      .position({
        x: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '32vp' : '24vp',
        y: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM && this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '24vp' : '36vp'
      })
      .visibility(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD &&
        this.videoHeight < DetailConstants.INITIAL_VIDEO_HEIGHT ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        if (this.isHalfFolded) {
          this.isHalfFolded = false;
        }
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
                Logger.error(TAG,
                  `Window maximize failed, errCode = ${error.code}, errMessage = ${error.message}.`);
              });
          } else if (this.immersiveTypeCurrent === window.WindowStatusType.FULL_SCREEN &&
            this.immersiveTypeBefore === window.WindowStatusType.FLOATING) {
            this.windowUtil?.recover();
          }
        } else {
          this.pageInfo.pop();
        }
      })
    }
    .height(this.isFullScreen && this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD && this.isShowingSideBar ? '130vp' : 'auto')
    .layoutWeight(this.isFullScreen ? 1 : 0)
    .width('100%')
    .backgroundColor(Color.Black)
    .focusable(false)
  }

  @Builder
  ImgIcon(img: ResourceStr = '') {
    Image(img)
      .height('24vp')
      .width('24vp')
      .margin({ left: '24vp' })
  }

  @Builder
  TextButton(content: ResourceStr = '', callback?: Function) {
    Text(content)
      .fontSize('12fp')
      .fontWeight(FontWeight.Normal)
      .fontColor(Color.White)
      .margin({ right: '24vp' })
      .onClick(() => {
        callback && callback()
      })
  }
}

@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize('9fp')
      .fontColor(Color.White)
      .lineHeight('12vp')
      .width('38vp')
  }
}