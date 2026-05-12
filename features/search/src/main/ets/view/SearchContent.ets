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

import { WindowInfo, BreakpointType } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';
import { SearchVideoItemViewModel } from '../viewmodel/SearchVideoImgViewModel';

/**
 * Search content area with history, discovery, and hot trending sections.
 */
@Component
export struct SearchContent {
  @State currentIndex: number = 0;
  @Link searchVideoList: SearchVideoItemViewModel[];
  @ObjectLink mainWindowInfo: WindowInfo;

  build() {
    Scroll() {
      Column() {
        this.searchHistory()
        this.searchDiscovery()
        this.searchHotTrending()
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  @Builder
  searchHistory() {
    Row() {
      Text(SearchConstants.SEARCH_SUB_TITLES[0])
        .fontSize('20fp')
        .fontWeight(500)
      Blank()
      Image($r('app.media.ic_public_delete'))
        .height('24vp')
        .width('24vp')
        .opacity(0.8)
    }
    .margin({ top: '12vp' })
    .width('100%')
    .height('28vp')

    Row() {
      this.searchContent()
      this.searchContent()
    }
    .width('100%')
    .height('28vp')
    .margin({ top: '12vp' })
  }

  @Builder
  searchContent() {
    Row() {
      Text(SearchConstants.SEARCH_SUB_TITLES[1])
        .fontSize('12fp')
        .fontWeight(500)
    }
    .justifyContent(FlexAlign.Center)
    .width('64vp')
    .height('28vp')
    .borderRadius( this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? '8vp' : '14vp')
    .backgroundColor($r('app.color.result_background'))
    .margin({ right: new BreakpointType('8vp', '8vp', '16vp', '16vp', '16vp')
      .getValue(this.mainWindowInfo.widthBp) })
  }

  // [Start search_discovery]
  @Builder
  searchDiscovery() {
    Row() {
      Text($r('app.string.find'))
        .fontSize('20fp')
        .fontWeight(500)

      Blank()

      if(this.mainWindowInfo.widthBp < WidthBreakpoint.WIDTH_XL){
        Image($r('app.media.ic_public_rotate1'))
          .height('24vp')
          .width('24vp')
      }
    }
    .height('24vp')
    .width('100%')
    .margin({ top: '24vp' })

    List() {
      ForEach(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? SearchConstants.SEARCH_DISCOVERY_LARGE :
        SearchConstants.SEARCH_DISCOVERY_LARGE.slice(0, 6), (item: string, index: number) => {
        ListItem() {
          Column() {
            Text(item)
              .fontSize('16vp')
              .fontWeight(500)
          }
          .padding({ right: this.getDividerPadding(this.mainWindowInfo.widthBp, index) })
          .height('21vp')
          .width('100%')
          .margin({ top: '12vp' })
          .alignItems(HorizontalAlign.Start)
        }
      }, (item: string, index: number) => index + JSON.stringify(item))
    }
    .width('100%')
    .lanes(new BreakpointType(2, 2, 2, 3, 3).getValue(this.mainWindowInfo.widthBp))
  }

  @Builder
  searchHotTrending() {
    List({
      space: new BreakpointType(SearchConstants.HOT_TRENDING_LIST_SPACES[0],
        SearchConstants.HOT_TRENDING_LIST_SPACES[1], SearchConstants.HOT_TRENDING_LIST_SPACES[2],
        SearchConstants.HOT_TRENDING_LIST_SPACES[3],
        SearchConstants.HOT_TRENDING_LIST_SPACES[4]).getValue(this.mainWindowInfo.widthBp)
    }) {
      ForEach(SearchConstants.SEARCH_TABS, (item: string, index: number) => {
        ListItem() {
          Column() {
            Text(item)
              .fontSize('16fp')
              .lineHeight('21vp')
              .fontWeight(500)
              .fontColor(index === this.currentIndex ? $r('app.color.type_tabs_font_selected') : Color.Black)
              .opacity(index !== this.currentIndex ? 0.6 : 1)
              .margin({ top: '17vp' })

            Divider()
              .strokeWidth(SearchConstants.TYPE_TABS_DIVIDER_STROKE_WIDTH)
              .width('32vp')
              .color($r('app.color.type_tabs_font_selected'))
              .visibility(index === this.currentIndex ? Visibility.Visible : Visibility.None)
              .margin({ top: '8vp' })
              .lineCap(LineCapStyle.Round)
          }
          .height('56vp')
          .justifyContent(FlexAlign.Start)
        }
        .onClick(() => {
          this.currentIndex = index;
        })
      }, (item: string, index: number) => item + index)
    }
    .margin({ top: '12vp' })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)

    List() {
      ForEach(this.searchVideoList, (item: SearchVideoItemViewModel) => {
        ListItem() {
          Row() {
            Image(item.getImgSrc())
              .height('48vp')
              .width('48vp')
              .margin({ right: '15vp' })

            Column() {
              Text(item.getTitle())
                .fontSize('16fp')
                .fontWeight(500)
                .lineHeight('22vp')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.getContent())
                .fontSize('14fp')
                .fontWeight(FontWeight.Normal)
                .lineHeight('19vp')
                .opacity(0.4)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: '2vp' })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height('100%')
        }
        .height('72vp')
      }, (item: SearchVideoItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .width('100%')
    .height(this.mainWindowInfo.widthBp < WidthBreakpoint.WIDTH_LG ? '384vp' : '312vp')
    .lanes(new BreakpointType(SearchConstants.SEARCH_LIST_LANES[4], SearchConstants.SEARCH_LIST_LANES[3],
      SearchConstants.SEARCH_LIST_LANES[2], SearchConstants.SEARCH_LIST_LANES[1],
      SearchConstants.SEARCH_LIST_LANES[0]).getValue(this.mainWindowInfo.widthBp), '12vp')
    .padding({
      top: '12vp',
      bottom: '12vp'
    })
    .divider({
      strokeWidth: 1,
      color: $r('app.color.hot_video_list_divider_color'),
      startMargin: '63vp'
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST, // Triggering the parent scroll first when scrolling down
      scrollBackward: NestedScrollMode.SELF_FIRST  // When scrolling up, the current List is triggered first
    })
  }

  /**
   * Returns divider padding for discovery list based on breakpoint and item index.
   */
  getDividerPadding(breakpoint: WidthBreakpoint, index: number): string {
    if (breakpoint >= WidthBreakpoint.WIDTH_LG) {
      if (index % SearchConstants.SEARCH_LIST_LANES[0] !== 2) {
        return SearchConstants.SEARCH_RECOMMEND_DIVIDER_PADDING;
      }
    } else {
      if (index % SearchConstants.SEARCH_LIST_LANES[1] === 0) {
        return SearchConstants.SEARCH_RECOMMEND_DIVIDER_PADDING;
      }
    }
    return '0vp';
  }
}