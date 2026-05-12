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

import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowInfo, BreakpointType, Logger, CommonConstants } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';

const TAG = '[VideoDialog]';

@Builder
function menuItemFunction(img: Resource, text: ResourceStr) {
  Row() {
    Image(img)
      .width('24vp')
      .height('24vp')
      .margin({ right: '8vp' })
    Text(text)
      .layoutWeight(1)
      .fontSize('16fp')
      .fontWeight(FontWeight.Normal)
  }
  .height('48vp')
}

@Builder
export function RightClickMenu(currentWidthBreakpoint: number) {
  Column() {
    menuItemFunction($r('app.media.ic_public_view_list'), HomeConstants.VIDEO_DIALOG_OPTIONS[0])
    menuItemFunction($r('app.media.ic_public_highlights'), HomeConstants.VIDEO_DIALOG_OPTIONS[1])
    menuItemFunction($r('app.media.ic_public_favor'), HomeConstants.VIDEO_DIALOG_OPTIONS[2])
  }
  .borderRadius(16)
  .backgroundColor(Color.White)
  .width(currentWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '186vp' : '156vp')
  .padding({
    left: '16vp',
    right: '16vp'
  })
}

/**
 * Video preview dialog with AVPlayer for playing video previews.
 */
@CustomDialog
export struct VideoDialog {
  @ObjectLink mainWindowInfo: WindowInfo;
  private xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private url?: resourceManager.RawFileDescriptor;
  private playState: boolean = true;
  private controller?: CustomDialogController;
  private onError: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(TAG, `Invoke avPlayer failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    this.avPlayer?.reset().catch((error: BusinessError) => {
      Logger.error(TAG, `reset failed, errCode = ${error.code}, errMessage = ${error.message}.`);
    });
  }
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      Logger.error(TAG, `AvPlayer is undefined.`);
      return;
    }
    switch (state) {
      case CommonConstants.AV_PLAYER_IDLE_STATE:
        try {
          this.url = await this.context.resourceManager.getRawFd(HomeConstants.PRODUCT_VIDEO_NAME);
          this.avPlayer.fdSrc = this.url;
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `getRawFd failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        }
        break;
      case CommonConstants.AV_PLAYER_INITIALIZED_STATE:
        // This status is reported after the AVPlayer sets the playback source.
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().catch((error: BusinessError) => {
          Logger.error(TAG, `prepare failed, errCode = ${error.code}, errMessage = ${error.message}.`);
        }).then(() => {
          Logger.info(TAG, `AVPlayer prepare succeeded.`);
        }, (err: BusinessError) => {
          Logger.error(TAG, `Invoke prepare failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          this.avPlayer?.reset().catch((error: BusinessError) => {
            Logger.error(TAG, `reset failed, errCode = ${error.code}, errMessage = ${error.message}.`);
          });
        });
        break;
      case CommonConstants.AV_PLAYER_PREPARED_STATE:
        // Report the state machine after the prepare interface is successfully invoked.
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        this.avPlayer.play().catch((error: BusinessError) => {
          Logger.error(TAG, `play failed, errCode = ${error.code}, errMessage = ${error.message}.`);
        });
        break;
      case CommonConstants.AV_PLAYER_PLAYING_STATE:
        // Trigger the state machine to report after the play interface is successfully invoked.
        Logger.info(TAG, `AVPlayer state playing called.`);
        this.playState = true;
        break;
      case CommonConstants.AV_PLAYER_PAUSED_STATE:
        // Trigger the state machine to report after the pause function is successfully invoked.
        Logger.info(TAG, `AVPlayer state paused called.`);
        this.playState = false;
        break;
      case CommonConstants.AV_PLAYER_COMPLETED_STATE:
        // Trigger the state machine to report after the playback ends.
        Logger.info(TAG, `AVPlayer state completed called.`);
        this.avPlayer.stop().catch((error: BusinessError) => {
          Logger.error(TAG, `stop failed, errCode = ${error.code}, errMessage = ${error.message}.`);
        });
        break;
      case CommonConstants.AV_PLAYER_STOPPED_STATE:
        // Trigger the state machine to report after the stop interface is successfully invoked.
        Logger.info(TAG, `AVPlayer state stopped called.`);
        break;
      case CommonConstants.AV_PLAYER_RELEASE_STATE:
        Logger.info(TAG, `AVPlayer state released called.`);
        break;
      case CommonConstants.AV_PLAYER_ERROR_STATE:
        Logger.error(TAG, `AVPlayer state error called.`);
        break;
      default:
        Logger.info(TAG, `AVPlayer state unknown called.`);
        break;
    }
  }

  aboutToAppear() {
    this.createAvPlayer();
  }

  aboutToDisappear() {
    try {
      this.avPlayer?.off('error');
      this.avPlayer?.off('stateChange');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to unregister callback, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    this.avPlayer?.release().catch((error: BusinessError) => {
      Logger.error(TAG, `release failed, errCode = ${error.code}, errMessage = ${error.message}.`);
    });
  }

  build() {
    Column() {
      Column() {
        XComponent({
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .borderRadius(24)
          .onLoad(() => {
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          })
          .width('100%')
          .height('100%')
      }
      .margin({ bottom: '12vp' })
      .height(new BreakpointType('161vp', '161vp', '268vp', '347vp', '347vp').getValue(this.mainWindowInfo.widthBp))
      .width(new BreakpointType('280vp', '280vp', '466vp', '604vp', '604vp').getValue(this.mainWindowInfo.widthBp))
      .aspectRatio(HomeConstants.VIDEO_DIALOG_ASPECT_RATIO)
      .onClick(() => {
        if (this.avPlayer?.state === CommonConstants.AV_PLAYER_STOPPED_STATE) {
          this.avPlayer?.prepare().catch((error: BusinessError) => {
            Logger.error(TAG, `prepare failed, errCode = ${error.code}, errMessage = ${error.message}.`);
          });
          return;
        }
        if (!this.playState) {
          this.avPlayer?.play().catch((error: BusinessError) => {
            Logger.error(TAG, `play failed, errCode = ${error.code}, errMessage = ${error.message}.`);
          });
        } else {
          this.avPlayer?.pause().catch((error: BusinessError) => {
            Logger.error(TAG, `pause failed, errCode = ${error.code}, errMessage = ${error.message}.`);
          });
        }
      })

      RightClickMenu(this.mainWindowInfo.widthBp)
    }
    .alignItems(HorizontalAlign.Start)
  }

  async createAvPlayer(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      // Entering the idle state.
      this.url = await this.context.resourceManager.getRawFd(HomeConstants.PRODUCT_VIDEO_NAME);
      this.avPlayer.fdSrc = this.url;
      this.setAVPlayerCallback();
      // Initialize the playback status.
      this.playState = false;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createAVPlayer failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }

  }

  // Registering the avplayer callback function.
  setAVPlayerCallback(): void {
    this.avPlayer?.on('error', this.onError);
    // Callback function for state machine changes.
    this.avPlayer?.on('stateChange', this.onStateChange);
  }
}