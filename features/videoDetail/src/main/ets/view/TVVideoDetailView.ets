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

import { AvPlayerUtil, CommonConstants } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';
import { TVVideoPlayer } from './TVVideoPlayer';

@Component
export struct TVVideoDetailView {
  @Consume('isShowingEpisodes') isShowingEpisodes: boolean;
  @Prop screenHeight: number;
  @Link isPlaying: boolean;
  @State episodesIndex: number = -1;
  private episodes: string[] = DetailConstants.PLAYER_EPISODE;
  private avPlayerUtil?: AvPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());

  build() {
    Stack() {
      this.videoBackground();

      this.Mask();

      TVVideoPlayer({ episodesIndex: this.episodesIndex })
        .visibility(this.isPlaying ? Visibility.Visible : Visibility.None)

      this.titleBar();

      this.videoDetailContent();
    }
    .width('100%')
    .height(this.isPlaying ? this.screenHeight : this.screenHeight * 0.9)
  }

  @Builder
  videoBackground() {
    Image($r('app.media.video_background_for_tv'))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)
      .syncLoad(true)
      .visibility(this.isPlaying ? Visibility.None : Visibility.Visible)
  }

  @Builder
  Mask() {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['rgba(0, 0, 0, 0)', 0.0], ['rgba(0, 0, 0, 0.6)', 1.0]]
      })
      .visibility(this.isPlaying ? Visibility.None : Visibility.Visible)
  }

  @Builder
  titleBar() {
    Row() {
      this.subTitle($r('app.string.released'))

      this.episodesChooseIcon();
    }
    .width('100%')
    .height('86vp')
    .justifyContent(this.isPlaying ? FlexAlign.SpaceBetween : FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    .padding({
      left: '56vp',
      right: '56vp',
      top: '25vp'
    })
    .position({
      top: '0vp'
    })
  }

  @Builder
  videoDetailContent() {
    Column() {
      this.videoDescribe();
      this.videoEpisodes();
    }
    .position({ bottom: '0vp' })
  }

  @Builder
  episodesChooseIcon() {
    Row({ space: '12vp' }) {
      Image($r('app.media.chevron_down_circle'))
        .width('32vp')
        .height('32vp')
        .fillColor(Color.White)
        .opacity(0.6)

      Text($r('app.string.anthology'))
        .lineHeight('32vp')
        .fontSize('24fp')
        .fontWeight(400)
        .fontColor(Color.White)
        .fontFamily('HarmonyHeiTi')
        .opacity(0.6)
    }
    .visibility(this.isPlaying ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.isShowingEpisodes = !this.isShowingEpisodes;
    })
  }

  @Builder
  subTitle(title: ResourceStr) {
    Text(title)
      .lineHeight('35vp')
      .fontSize('26fp')
      .fontWeight(700)
      .fontColor(Color.White)
      .fontFamily('HarmonyHeiTi')
      .opacity(0.9)
      .margin({ bottom: '16vp' })
  }

  @Builder
  videoDescribeContent(content: ResourceStr) {
    Text(content)
      .lineHeight('28vp')
      .fontSize('18fp')
      .fontWeight(500)
      .fontColor(Color.White)
      .fontFamily('HarmonyHeiTi')
  }

  @Builder
  videoDescribe() {
    Column() {
      this.subTitle($r('app.string.introduction'))

      this.videoDescribeContent($r('app.string.product'))

      this.videoDescribeContent($r('app.string.play'))
    }
    .width('100%')
    .padding({
      left: '56vp',
      bottom: '35vp' })
    .alignItems(HorizontalAlign.Start)
    .visibility(this.isPlaying ? Visibility.None : Visibility.Visible)
  }

  @Builder
  videoEpisodes() {
    Column() {
      this.subTitle($r('app.string.anthology'))

      List({ space: '12vp' }) {
        ForEach(this.episodes, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize('18fp')
                .fontWeight(FontWeight.Normal)
                .height('24vp')
                .fontColor(this.episodesIndex === index ? $r('app.color.font_selected') : Color.White)

              Image($r('app.media.video_playing'))
                .height('10vp')
                .width('10vp')
                .position({
                  left: '8vp',
                  bottom: '8vp'
                })
                .visibility(this.episodesIndex === index ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.episodes_background'))
            .height('54vp')
            .width('68vp')
            .borderRadius(12)
            .borderWidth(1)
            .borderColor($r('app.color.episodes_border_for_tv'))
            .onClick(() => {
              this.isPlaying = true;
              if (this.episodesIndex === index &&
                (this.avPlayerUtil?.getAvplayerState() === CommonConstants.AV_PLAYER_PAUSED_STATE ||
                  this.avPlayerUtil?.getAvplayerState() === CommonConstants.AV_PLAYER_COMPLETED_STATE)) {
                this.avPlayerUtil.playerStateControl();
              }
              this.episodesIndex = index;
              this.isShowingEpisodes = false;
            })
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .height('54vp')
      .width('100%')
    }
    .width('100%')
    .padding({
      left: '56vp',
      bottom: '35vp' })
    .alignItems(HorizontalAlign.Start)
    .visibility(this.isPlaying ? (this.isShowingEpisodes ? Visibility.Visible: Visibility.None) : Visibility.Visible)
  }
}