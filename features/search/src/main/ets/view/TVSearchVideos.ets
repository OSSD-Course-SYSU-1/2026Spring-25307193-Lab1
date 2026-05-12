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
import { SearchConstants } from '../constants/SearchConstants';
import { SearchVideoImgViewModel, SearchVideoItemViewModel } from '../viewmodel/SearchVideoImgViewModel';

@Component
export struct TVSearchVideos{
  @Consume('pageInfo') pageInfo: NavPathStack;
  private searchVideoImgViewModel: SearchVideoImgViewModel = new SearchVideoImgViewModel();
  @Prop videoList: SearchVideoItemViewModel[] = [];

  build() {
    this.resultVideos()
  }

  @Builder
  resultVideos() {
    List({ space: 32 }) {
      ForEach(this.videoList || this.searchVideoImgViewModel.getSearchResultList(),
        (item: SearchVideoItemViewModel) => {
        ListItem() {
          Column() {
            Image(item.getImgSrc())
              .height('290vp')
              .width('208vp')
              .borderRadius(12)
              .margin({ bottom: '16vp' })

            Text(item.getTitle())
              .fontSize('18fp')
              .fontWeight(500)
              .fontColor(Color.White)
              .opacity(0.9)
              .lineHeight('24vp')
              .maxLines(1)
              .width('100%')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('208vp')
        .onClick(() =>{
          this.pageInfo.pushPath({ name: SearchConstants.PAGE_NAME_FOR_VIDEO });
        })
      }, (item: SearchVideoItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .width('100%')
    .padding({ top: '12vp', left: '56vp', right: '56vp', bottom: '12vp' })
    .clip(false)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }
}