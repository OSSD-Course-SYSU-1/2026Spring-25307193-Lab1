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

import { WindowInfo, Logger } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';

const TAG = '[SearchByKeyword]';

@Component
export struct SearchByKeyword {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link searchInput: string;

  build() {
    Column() {
      List() {
        ForEach(SearchConstants.HUA_LIST, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontSize('16fp')
                .fontWeight(500)
                .height('47.5vp')

              Divider()
                .color(Color.Black)
                .height('1vp')
                .opacity(0.05)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({
              right: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG && index % 2 === 0 ? '12vp' : '0vp'
            })
            .height('48vp')
            .onClick(() => {
              if (index === 3) {
                this.searchInput = item;
              } else {
                Logger.info(TAG, `Please click on the third list item`);
              }
            })
          }
        }, (item: string, index: number) => item + index)
      }
      .lanes(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? 2 : 1)
    }
    .layoutWeight(1)
    .padding({ top: '16vp' })
  }
}