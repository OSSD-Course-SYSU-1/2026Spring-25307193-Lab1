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

@Component
export struct TVHomeHeader {
  @Link currentBottomIndex: number;
  private iconList: Array<Resource> = [$r('sys.symbol.dot_grid_2x2'), $r('sys.symbol.arrow_counterclockwise_clock'),
    $r('sys.symbol.magnifyingglass')];
  private btnList: Array<Resource> = [$r('app.string.tab_home'), $r('app.string.tab_development'), $r('app.string.tab_member'), $r('app.string.tab_mine')];

  build() {
    Row({ space: '20vp' }) {
      List({ space: '10vp' }) {
        ForEach(this.iconList, (item: Resource, index: number) => {
          ListItem() {
            Row() {
              SymbolGlyph(item)
                .fontSize('24fp')
                .fontColor([Color.White])
            }
            .backgroundColor(this.currentBottomIndex === index ? $r('app.color.tv_tab_selected_bg') : $r('app.color.tv_tab_bg'))
            .width('40vp')
            .height('100%')
            .border({
              width: 0,
              radius: 20
            })
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.currentBottomIndex = index;
            })
          }
        }, (item: Resource) => JSON.stringify(item))
      }
      .listDirection(Axis.Horizontal)
      .height('40vp')
      .width('auto')

      Row() {
      }
      .height('35vp')
      .width('0.5vp')
      .border({
        width: 1,
        color: $r('app.color.tv_tab_bg')
      })

      List() {
        ForEach(this.btnList, (item: Resource, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize('18fp')
                .fontWeight(800)
                .fontColor(this.currentBottomIndex === index + this.iconList.length ? Color.White : $r('app.color.tv_secondary_text'))
            }
            .backgroundColor(this.currentBottomIndex === index + this.iconList.length ? $r('app.color.tv_tab_bg') :
              Color.Transparent)
            .width('78vp')
            .height('100%')
            .border({
              width: 0,
              radius: 25
            })
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.currentBottomIndex = index + this.iconList.length;
            })
          }
          .align(Alignment.Center)
        }, (item: Resource) => JSON.stringify(item))
      }
      .listDirection(Axis.Horizontal)
      .height('48vp')
      .width('auto')
    }
    .backgroundColor($r('app.color.tv_header_bg'))
    .borderRadius(50)
    .height('63vp')
    .padding({
      left: '12vp',
      right: '18vp',
    })
    .margin({ top: '20vp' })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}