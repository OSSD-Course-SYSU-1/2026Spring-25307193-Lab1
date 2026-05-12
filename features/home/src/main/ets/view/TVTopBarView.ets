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

import { HomeConstants } from '../constants/HomeConstants';

@Component
export struct TVTopBarView {
  @Link currentTVTopIndexForTv: number;

  build() {
    Column() {
      List() {
        ForEach(HomeConstants.TOP_TOPIC_LIST, (item: string, index: number) => {
          ListItem() {
            Row() {
              Row() {
                Row() {
                  Text(item)
                    .fontSize('24fp')
                    .fontWeight(this.currentTVTopIndexForTv === index ? 700 : 500)
                    .width(this.currentTVTopIndexForTv === index ? '70vp' : '66vp')
                    .textAlign(TextAlign.Center)
                    .fontColor(this.currentTVTopIndexForTv === index ? Color.White : $r('app.color.tv_secondary_text'))
                    .lineHeight(index === this.currentTVTopIndexForTv ? '33vp' : '25vp')
                    .focusable(true)
                    .groupDefaultFocus(index === 0 ? true : false)
                    .borderRadius(4)
                }
                .backgroundColor(this.currentTVTopIndexForTv === index ? $r('app.color.tv_tab_bg') : Color.Transparent)
                .width('92vp')
                .height('48vp')
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.currentTVTopIndexForTv = index;
                })
                .borderRadius(30)
              }
              .width('96vp')
              .height('52vp')
              .borderRadius(30)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r('sys.color.gray_02'))
            }
            .borderRadius(30)
            .width('100vp')
            .height('56vp')
            .linearGradient(this.currentTVTopIndexForTv === index ? {
              angle: 90,
              colors: [[Color.White, 0.0], [$r('sys.color.gray_02'), 1]]
            } : null)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
          .align(Alignment.Center)
        }, (item: number, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .width('100%')
      .height('100%')
    }
    .height('86vp')
    .padding(10)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .margin({
      top: '32vp',
      left: '32vp'
    })
  }
}