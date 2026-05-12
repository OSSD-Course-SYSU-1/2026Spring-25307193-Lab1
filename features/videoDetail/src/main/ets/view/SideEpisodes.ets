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
import { display } from '@kit.ArkUI';
import { Logger, WindowInfo, WindowUtil } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';

const TAG = '[SideEpisodes]';

/**
 * Sidebar episode selector shown in fullscreen mode.
 */
@Component
export struct SideEpisodes {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;

  build() {
    Column() {
      // Episodes sidebar.
      Row() {
        Blank()
        this.SideTitleText(DetailConstants.PLAYER_TEXT_LIST[0], '65vp', 1, '36vp')
        this.SideTitleText(DetailConstants.PLAYER_TEXT_LIST[1], '56vp', 0.6)
        Blank()
      }
      .width('100%')
      .margin({
        top: '12vp',
        bottom: '12vp'
      })

      List({ space: '12vp' }) {
        ForEach(DetailConstants.PLAYER_EPISODE, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize('18fp')
                .fontColor(index === 1 ? $r('app.color.font_selected') : Color.White)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.video_playing'))
                .height('10vp')
                .width('10vp')
                .position({
                  x: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD ?
                    '6vp' : '8vp',
                  y: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD ?
                    '28vp' : '36vp'
                })
                .visibility(index === 1 ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius(8)
            .backgroundColor($r('app.color.episode_row_background'))
            .width('100%')
            .height(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD ? '44vp' : '54vp')
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .layoutWeight(1)
      .width('100%')
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .lanes(DetailConstants.EPISODE_LIST_LANES[1], '12vp')
      .padding({
        left: '24vp',
        right: '24vp',
        bottom: '12vp'
      })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.Black)
    .layoutWeight(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD ? 2 : 0)
    .height('100%')
    .width(this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD
      ? '100%'
      : DetailConstants.SIDE_BAR_MIN_WIDTH_NUMBER + DetailConstants.LENGTH_UNIT)
    .visibility(this.isShowingSide())
    .padding({ top: this.getTopPadding() })
  }

  @Builder
  SideTitleText(content: ResourceStr, width: ResourceStr, opacity: number = 1, margin: ResourceStr = '0vp') {
    Text(content)
      .fontSize('16fp')
      .fontColor(Color.White)
      .fontWeight(FontWeight.Normal)
      .lineHeight('32vp')
      .width(width)
      .opacity(opacity)
      .margin({ right: margin })
  }

  isShowingSide(): Visibility {
    if (!this.isShowingSideBar || !this.isFullScreen) {
      return Visibility.None;
    }
    if (this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG &&
      this.mainWindowInfo.heightBp < HeightBreakpoint.HEIGHT_LG) {
      return Visibility.Visible;
    }
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD &&
      this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_SM) {
      return Visibility.Visible;
    }
    return Visibility.None;
  }

  getTopPadding() {
    let decorHeight: number | undefined = undefined;
    let statusHeight: number | undefined = this.mainWindowInfo.avoidSystem?.topRect.height;
    try {
      decorHeight = this.windowUtil?.mainWindow.getTitleButtonRect().height;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to get decorHeight, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    if (!!decorHeight) {
      return decorHeight;
    } else if (!!statusHeight) {
      return this.getUIContext().px2vp(statusHeight);
    } else {
      return 0;
    }
  }
}