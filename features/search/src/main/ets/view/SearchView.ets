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

import { BreakpointType, SetDecorButtonStyleUtil, WindowInfo, WindowUtil } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';
import { SearchVideoImgViewModel, SearchVideoItemViewModel } from '../viewmodel/SearchVideoImgViewModel';
import { SearchContent } from './SearchContent';
import { SearchByKeyword } from './SearchByKeyword';
import { SearchHeader } from './SearchHeader';
import { SearchResult } from './SearchResult';

@Component
export struct SearchView {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @ObjectLink mainWindowInfo: WindowInfo;
  @State currentIndex: number = 0;
  @State searchVideoList: SearchVideoItemViewModel[] = [];
  @State searchInput: string = '';

  build() {
    NavDestination() {
      GridRow({
        columns: {
          xs: 4,
          sm: 4,
          md: 12,
          lg: 12,
          xl: 12,
        }
      }) {
        GridCol({
          span: {
            xs: 4,
            sm: 4,
            md: 12,
            lg: 12,
            xl: 12
          }
        }) {
          Column() {
            SearchHeader({ searchInput: this.searchInput, mainWindowInfo: this.mainWindowInfo })
            SearchContent({ searchVideoList: this.searchVideoList, mainWindowInfo: this.mainWindowInfo })
              .layoutWeight(1)
              .visibility(this.searchInput === SearchConstants.SEARCH_INPUT_LIST[0] || this.searchInput ===
              SearchConstants.SEARCH_INPUT_LIST[1] ? Visibility.None : Visibility.Visible)
            SearchByKeyword({ searchInput: this.searchInput, mainWindowInfo: this.mainWindowInfo })
              .layoutWeight(1)
              .visibility(this.searchInput === SearchConstants.SEARCH_INPUT_LIST[0] ? Visibility.Visible :
                Visibility.None)
            SearchResult({ mainWindowInfo: this.windowUtil?.mainWindowInfo })
              .layoutWeight(1)
              .visibility(this.searchInput === SearchConstants.SEARCH_INPUT_LIST[1] ? Visibility.Visible :
                Visibility.None)
          }
          .height('100%')
          .width('100%')
          .padding({
            left: new BreakpointType('16vp', '16vp', '24vp', '32vp', '32vp').getValue(this.mainWindowInfo.widthBp),
            right: new BreakpointType('16vp', '16vp', '24vp', '32vp', '32vp').getValue(this.mainWindowInfo.widthBp),
          })
        }
      }
      .onBreakpointChange((breakPoints) => {
        this.searchVideoList = new SearchVideoImgViewModel().getTrendSearchList(breakPoints);
      })
    }
    .hideTitleBar(true)
    .onAppear(() => {
      SetDecorButtonStyleUtil.setDecorButtonForNormal(this.windowUtil);
    })
    .onDisAppear(() => {
      SetDecorButtonStyleUtil.setDecorButtonForImmersive(this.currentTopIndex, this.mainWindowInfo.widthBp,
        this.pageInfo, this.windowUtil);
    })
  }
}
