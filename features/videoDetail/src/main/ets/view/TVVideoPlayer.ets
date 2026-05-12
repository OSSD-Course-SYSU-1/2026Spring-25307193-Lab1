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

import { AvPlayerUtil, WindowUtil } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';

@Component
export struct TVVideoPlayer {
  @State currentTime: string = DetailConstants.INITIAL_TIME;
  @State totalTime: string = DetailConstants.INITIAL_TIME;
  @State progress: number = 0;
  @State avplayerState: string = '';
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Link @Watch('episodesIndexChange') episodesIndex: number;
  @Consume('isShowingEpisodes') isShowingEpisodes: boolean;
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

  aboutToAppear(): void {
    this.avPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
    this.avPlayerUtil?.addStateChangeListener(this.onPlayerStateChange);
    this.onPlayerStateChange;
  }

  aboutToDisappear(): void {
    this.avPlayerUtil?.removeStateChangeListener(this.onPlayerStateChange);
    this.avPlayerUtil?.offTimeUpdate();
    this.avPlayerUtil?.release();
  }

  episodesIndexChange() {
    this.avPlayerUtil?.offTimeUpdate();
    this.avPlayerUtil?.release();
    this.avPlayerUtil?.createAvPlayer(this.xComponentController.getXComponentSurfaceId());
    AppStorage.setOrCreate('detailSurfaceId', this.xComponentController.getXComponentSurfaceId());
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        XComponent({
          id: 'videoForTV',
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .width(-1)
          .aspectRatio(1.78)
      }
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .width('100%')
      .onClick(() => {
        this.avPlayerUtil?.playerStateControl();
      })

      Row() {
        TimeText({ time: this.currentTime })
          .margin({
            left: '56vp',
            right: '12vp'
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
            left: '12vp',
            right: '56vp'
          })
      }
      .width('100%')
      .height('32vp')
      .alignItems(VerticalAlign.Center)
      .position({
        bottom: '36vp'
      })
      .visibility(this.isShowingEpisodes ? Visibility.None : Visibility.Visible)
    }
    .height('auto')
    .layoutWeight(1)
    .width('100%')
    .backgroundColor(Color.Black)
    .focusable(false)
  }
}

@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize('12fp')
      .fontColor(Color.White)
      .lineHeight('16vp')
      .width('50vp')
  }
}