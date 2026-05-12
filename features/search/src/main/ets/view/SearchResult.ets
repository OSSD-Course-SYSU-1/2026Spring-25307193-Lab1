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

import { BreakpointConstants, WindowInfo, BreakpointType } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';
import { SearchVideoImgViewModel, SearchVideoItemViewModel } from '../viewmodel/SearchVideoImgViewModel';

@Component
export struct SearchResult {
  @State resultTabIndex: number = 0;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @ObjectLink mainWindowInfo: WindowInfo;

  build() {
    Scroll() {
      Column() {
        this.typeTabs()
        this.resultVideos()
      }
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  typeTabs() {
    Row() {
      List() {
        ForEach(SearchConstants.SEARCH_RESULT_TAB_LIST, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontSize('16fp')
                .fontWeight(index === this.resultTabIndex ? 500 : FontWeight.Normal)
                .fontColor(index === this.resultTabIndex ? $r('app.color.type_tabs_font_selected') : $r('app.color.type_tabs_font'))
                .lineHeight('22vp')
                .margin({ top: '17vp' })

              Divider()
                .strokeWidth(SearchConstants.TYPE_TABS_DIVIDER_STROKE_WIDTH)
                .width(item.length === SearchConstants.SEARCH_INDEX[0] ? '32vp' : '48vp')
                .color($r('app.color.type_tabs_font_selected'))
                .margin({ top: '7vp' })
                .lineCap(LineCapStyle.Round)
                .visibility(index === this.resultTabIndex ? Visibility.Visible : Visibility.None)
            }
            .width('48vp')
            .height('100%')
            .margin({ right: index !== SearchConstants.SEARCH_RESULT_TAB_LIST.length - 1 ? '16vp': '0vp' })
            .onClick(() => {
              this.resultTabIndex = index;
            })
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)

      Blank()

      Image($r('app.media.ic_public_sift'))
        .height('16vp')
        .width('16vp')
        .opacity(0.8)
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('56vp')
    .margin({ top: '12vp' })
  }

  @Builder
  resultVideos() {
    Row() {
      Text(SearchConstants.SEARCH_RESULT_TITLE)
        .fontSize('16fp')
        .fontWeight(500)
    }
    .height('48vp')
    .margin({
      top: '8vp',
      bottom: '8vp'
    })

    GridRow({
      columns: {
        sm: BreakpointConstants.GRID_ROW_COLUMNS[2],
        md: BreakpointConstants.GRID_ROW_COLUMNS[0],
        lg: BreakpointConstants.GRID_ROW_COLUMNS[1]
      },
      gutter: '12vp'
    }){
      ForEach(new SearchVideoImgViewModel().getSearchResultImgList(), (item: SearchVideoItemViewModel) => {
        GridCol({
          span: {
            sm: BreakpointConstants.GRID_COLUMN_SPANS[5],
            md: BreakpointConstants.GRID_COLUMN_SPANS[1],
            lg: BreakpointConstants.GRID_COLUMN_SPANS[3]
          }
        }) {
          Row() {
            Image(item.getImgSrc())
              .objectFit(ImageFit.Fill)
              .margin({ right: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp' })
              .layoutWeight(3)
              .height('100%')

            Column() {
              Text(item.getTitle())
                .fontSize(new BreakpointType('14fp', '14fp', '16fp', '18fp', '18fp')
                  .getValue(this.mainWindowInfo.widthBp))
                .fontWeight(500)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.getContent())
                .fontSize(new BreakpointType('10fp', '10fp', '12fp', '14fp', '14fp')
                  .getValue(this.mainWindowInfo.widthBp))
                .lineHeight(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '19fp' : '16fp')
                .opacity(0.5)
                .fontWeight(FontWeight.Normal)
                .margin({ top: '4vp' })
                .maxLines(1)
              Text(item.getOtherInfo())
                .fontSize(new BreakpointType('10fp', '10fp', '12fp', '14fp', '14fp')
                  .getValue(this.mainWindowInfo.widthBp))
                .lineHeight(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '19vp' : '16vp')
                .opacity(0.5)
                .fontWeight(FontWeight.Normal)
                .margin({ top: '2vp' })
                .maxLines(1)

              Row() {
                Button(SearchConstants.SEARCH_RESULT_BUTTON_TEXTS[0])
                  .backgroundColor($r('app.color.button_background_1'))
                  .fontWeight(500)
                  .borderRadius(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? 8 : '50%')
                  .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '14fp' : '12fp')
                  .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '34vp' : '25vp')
                  .fontColor(Color.White)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.pageInfo.pushPath({ name: SearchConstants.PAGE_NAME_FOR_VIDEO });
                  })

                Blank()
                  .width('12vp')

                Button(SearchConstants.SEARCH_RESULT_BUTTON_TEXTS[1])
                  .backgroundColor($r('app.color.button_background_2'))
                  .fontWeight(500)
                  .borderRadius(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? 8 : '50%')
                  .fontSize(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '14fp' : '12fp')
                  .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '34vp' : '25vp')
                  .fontColor($r('app.color.type_tabs_font_selected'))
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom)
              .layoutWeight(1)
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .layoutWeight(3)
          }
          .aspectRatio(1.56)
          .height(new BreakpointType('179vp', '179vp', '198vp', '238vp', '238vp')
            .getValue(this.mainWindowInfo.widthBp))
          .width('100%')
          .padding({
            top: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp',
            bottom: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp',
            left: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp',
            right: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? '10vp' : '12vp'
          })
          .backgroundColor($r('app.color.result_background'))
          .borderRadius(16)
        }
      }, (item: SearchVideoItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .margin({ bottom: '12vp' })
  }
}