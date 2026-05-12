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
import { WindowInfo } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';

@Component
export struct FooterEpisodes {
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;
  private isOnSmOrXs(): boolean {
    return this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM;
  }

  build() {
    Column() {
      // Selection bottom bar.
      Row() {
        Text(DetailConstants.PLAYER_TEXT_LIST[0])
          .fontSize(this.isOnSmOrXs() ? '16fp' : '24fp')
          .fontColor(Color.White)
          .fontWeight(this.isOnSmOrXs() ?  400 : 500)
          .lineHeight(this.isOnSmOrXs() ?  '32vp' : '33vp')
          .width('48vp')
          .margin({ right: this.isOnSmOrXs() ? '36vp' : '24vp' })
        Text(DetailConstants.PLAYER_TEXT_LIST[1])
          .fontSize(this.isOnSmOrXs() ? '16fp' : '18fp')
          .fontColor(Color.White)
          .fontWeight(400)
          .lineHeight(this.isOnSmOrXs() ? '32vp' : '25vp')
          .width('58vp')
          .opacity(0.6)
      }
      .margin({
        top: this.isOnSmOrXs() ? '8vp' : '25vp',
        bottom: this.isOnSmOrXs() ? '8vp' : '12vp'
      })
      .width('100%')
      .height(this.isOnSmOrXs() ? '32vp' : '56vp')
      .justifyContent(this.isOnSmOrXs() ? FlexAlign.Center : FlexAlign.Start)


      List({ space: '12vp' }) {
        ForEach(DetailConstants.PLAYER_EPISODE, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize('18fp')
                .fontColor(index === 1 ? '#ED6F21' : Color.White)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.video_playing'))
                .height('10vp')
                .width('10vp')
                .position({
                  x: '8vp',
                  y: this.isOnSmOrXs() ? '26vp' : '36vp'
                })
                .visibility(index === 1 ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius(8)
            .backgroundColor($r('app.color.episode_row_background'))
            .width('100%')
            .height(this.isOnSmOrXs() ? '44vp' : '54vp')
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: '12vp' })
      .lanes(this.isOnSmOrXs() ? DetailConstants.EPISODE_LIST_LANES[1] :
        DetailConstants.EPISODE_LIST_LANES[0], '12vp')
    }
    .layoutWeight(1)
    .width('100%')
    .visibility(this.isShowingFooter())
    .backgroundColor(Color.Black)
    .padding({
      left: this.isOnSmOrXs() ? '12vp' : '24vp',
      right: this.isOnSmOrXs() ? '12vp' : '24vp'
    })
  }

  isShowingFooter(): Visibility {
    if (!this.isShowingSideBar || !this.isFullScreen) {
      return Visibility.None;
    }
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_MD && this.mainWindowInfo.heightBp >
    HeightBreakpoint.HEIGHT_SM) {
      return Visibility.Visible;
    }
    if (this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG &&
      this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) {
      return Visibility.Visible;
    }
    return Visibility.None;
  }
}