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

export interface TVSearchTabsParams {
  currentIndex: number;
  list: ResourceStr[];
  onTabChange: (index: number) => void;
}

@Builder
export function TVSearchTabs(params: TVSearchTabsParams) {
  List({ space: 16 }) {
    ForEach(params.list, (item: ResourceStr, index: number) => {
      ListItem() {
        Column() {
          Text(item)
            .fontSize('24fp')
            .lineHeight('32vp')
            .fontWeight(index === params.currentIndex ? 700 : FontWeight.Normal)
            .fontColor(Color.White)
            .opacity(index === params.currentIndex ? 0.9 : 0.6)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding({ top: '8vp', bottom: '8vp', left: '22vp', right: '22vp' })
        .height('48vp')
        .justifyContent(FlexAlign.Start)
      }
      .onClick(() => {
        params.onTabChange(index);
      })
    }, (item: ResourceStr, index: number) => index + String(item))
  }
  .margin({ top: '16vp' })
  .padding({ top: '19vp', left: '56vp', right: '56vp', bottom: '19vp' })
  .listDirection(Axis.Horizontal)
  .width('100%')
  .scrollBar(BarState.Off)
}