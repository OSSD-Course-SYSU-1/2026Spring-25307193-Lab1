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

import { WindowUtil } from '@ohos/commons';
import { DailyVideo } from './DailyVideo';
import { NewVideoRelease } from './NewVideoRelease';
import { RecommendedVideo } from './RecommendedVideo';
import { TVBannerView } from './TVBannerView';
import { TVPreviousVideo } from './TVPreviousVideo';
import { TVTopBarView } from './TVTopBarView';

@Component
export struct TVHomeContent {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @State currentTopIndexForTv: number = 0;

  build() {
    Column() {
      TVBannerView({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
      TVTopBarView({ currentTVTopIndexForTv: this.currentTopIndexForTv })
      Column() {
        RecommendedVideo({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
        NewVideoRelease({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
        DailyVideo({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
        TVPreviousVideo({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
      }
      .visibility(this.currentTopIndexForTv === 0 ? Visibility.Visible : Visibility.None)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
  }
}