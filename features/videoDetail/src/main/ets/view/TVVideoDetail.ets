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

import { KeyCode } from '@kit.InputKit';
import {
  WindowUtil,
  WindowInfo, DeviceScreen,
  AvPlayerUtil, CommonConstants
} from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';
import { RelatedVideoItemViewModel, RelatedVideoViewModel } from '../viewmodel/RelatedVideoViewModel';
import { TVVideoDetailView } from './TVVideoDetailView';

@Component
export struct TVVideoDetail {
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Provide('isShowingEpisodes') isShowingEpisodes: boolean = false;
  @State @Watch('exitPlaying') isPlaying: boolean = false;
  private scroller: Scroller = new Scroller();
  private avPlayerUtil?: AvPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
  public screenHeight: number = 0;
  private relatedVideoList: RelatedVideoItemViewModel[] = new RelatedVideoViewModel().getRelatedVideoList();
  private peripheralVideoList: RelatedVideoItemViewModel[] = new RelatedVideoViewModel().getPeripheralVideoList();
  private exitPlaying() {
    if (this.avPlayerUtil?.getAvplayerState() === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.avPlayerUtil.playerStateControl();
    }
  }

  aboutToAppear() {
    this.screenHeight = DeviceScreen.getDeviceHeight();
  }

  aboutToDisappear() {
    this.isPlaying = false;
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          TVVideoDetailView({ screenHeight: this.screenHeight, isPlaying: this.isPlaying })
          this.TVRelatedList()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .layoutWeight(1)
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .height('100%')
    }
    .onBackPressed(() => {
      if(this.isPlaying) {
        this.isPlaying = false;
        return true;
      } else {
        return false;
      }
    })
    .backgroundColor($r('app.color.video_detail_background_for_tv'))
    .hideTitleBar(true)
    .onKeyEvent((event?: KeyEvent) => {
      // If the key type is pressed, the subsequent code will be executed,
      // and the specific key logic will be executed when released.
      if (!event || event.type !== KeyType.Down || !this.isPlaying) {
        return;
      }
      if (event.keyCode === KeyCode.KEYCODE_DPAD_CENTER || event.keyCode === KeyCode.KEYCODE_SPACE) {
        // Space key and dpad enter key control pause/play.
        this.avPlayerUtil?.playerStateControl();
      } else if (event.keyCode === KeyCode.KEYCODE_DPAD_RIGHT) {
        // Right-click fast forward.
        this.avPlayerUtil?.fastForward();
      } else if (event.keyCode === KeyCode.KEYCODE_DPAD_LEFT) {
        // Left click to go back quickly.
        this.avPlayerUtil?.rewind();
      } else if (event.keyCode === KeyCode.KEYCODE_DPAD_DOWN) {
        // Down click to determine whether showing episodes.
        this.isShowingEpisodes = !this.isShowingEpisodes;
      } else if (event.keyCode === KeyCode.KEYCODE_ESCAPE || event.keyCode === KeyCode.KEYCODE_BACK) {
        // Esc key and back key to exit.
        this.isPlaying = false;
      } else {
        return;
      }
    })
  }

  @Builder
  TVRelatedList() {
    Column() {
      this.TVRelatedVideo(DetailConstants.SUB_TITLES[1], this.relatedVideoList, '176vp', '312vp')
      this.TVRelatedVideo(DetailConstants.SUB_TITLES[5], this.peripheralVideoList, '299vp', '213vp')
    }
    .margin({ bottom: '90vp' })
    .width('100%')
    .visibility(this.isPlaying ? Visibility.None : Visibility.Visible)
  }

  @Builder
  TVRelatedVideo(title: ResourceStr, dataSource: RelatedVideoItemViewModel[], imageHeight: ResourceStr,
    imageWidth: ResourceStr) {
    Column() {
      Text(title)
        .lineHeight('35vp')
        .fontSize('26fp')
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi')
        .fontColor(Color.White)
        .opacity(0.9)
        .margin({
          top: '35vp',
          bottom: '24vp',
          left: '56vp'
        })

      List({ space: '32vp' }) {
        ForEach(dataSource, (item: RelatedVideoItemViewModel, index: number) => {
          ListItem() {
            Column() {
              Image(item.getImageSrc())
                .height(imageHeight)
                .width(imageWidth)
                .borderRadius(20)
                .margin({ bottom: '8vp' })
                .hoverEffect(HoverEffect.Scale)

              Text(item.getName())
                .lineHeight('21vp')
                .fontSize('16fp')
                .fontWeight(400)
                .fontFamily('HarmonyHeiTi')
                .opacity(0.6)
                .fontColor(index === 0 && this.isPlaying ? $r('app.color.font_selected') : Color.White)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .clip(false)
        }, (item: RelatedVideoItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .padding({
        left: '56vp',
        right: '56vp',
      })
      .width('100%')
      .clip(false)
    }
    .alignItems(HorizontalAlign.Start)
  }
}