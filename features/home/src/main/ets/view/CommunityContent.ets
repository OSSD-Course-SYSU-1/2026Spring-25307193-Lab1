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

import { BreakpointType, WindowInfo, WindowUtil } from '@ohos/commons';
import { BannerView } from './BannerView';
import { IconView } from './IconView';
import { RecommendedVideo } from './RecommendedVideo';
import { NewVideoRelease } from './NewVideoRelease';
import { DailyVideo } from './DailyVideo';
import { PreviousVideo } from './PreviousVideo';

@Component
export struct CommunityContent {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  // The current vertical sliding distance of the list.
  @State currentYOffset: number = 0;
  // Whether the list slide to the bottom
  @State isReachingEnd: boolean = false;
  @State currentIndex: number = 0;
  @State decorWidth: number = 0;

  build() {
    Column() {
      BannerView({ mainWindowInfo: this.mainWindowInfo })
      IconView({ mainWindowInfo: this.mainWindowInfo })
      RecommendedVideo({ mainWindowInfo: this.mainWindowInfo })
      NewVideoRelease({ mainWindowInfo: this.mainWindowInfo })
      DailyVideo({ mainWindowInfo: this.mainWindowInfo })
      PreviousVideo({ mainWindowInfo: this.mainWindowInfo })
    }
    // Set the background image to cover the side and top tabs.
    .backgroundImage(this.currentTopIndex === 2 ? new BreakpointType($r('app.media.immersive_background_sm'),
      $r('app.media.immersive_background_sm'), $r('app.media.immersive_background_md'),
      $r('app.media.immersive_background_lg'),
      $r('app.media.immersive_background_lg')).getValue(this.mainWindowInfo.widthBp) : $r('app.media.white_background'))
    // Set the size of the background image.
    .backgroundImageSize({
      width: '100%',
      height: new BreakpointType('384vp', '384vp', '420vp', '720vp', '720vp').getValue(this.mainWindowInfo.widthBp)
    })
    // Set the uniform background color.
    .backgroundColor(this.currentTopIndex === 2 ? (this.mainWindowInfo.widthBp !== WidthBreakpoint.WIDTH_MD ?
      $r('app.color.home_content_background') : $r('app.color.home_content_background_md')) : Color.White)
    .width('100%')
    .padding({ bottom: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '24vp' : '0vp' })
  }
}