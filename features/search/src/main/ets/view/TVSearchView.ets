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

import { Logger } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';
import { SearchVideoImgViewModel, SearchVideoItemViewModel } from '../viewmodel/SearchVideoImgViewModel';
import { SearchKeyboardViewModel, KeyboardItemViewModel } from '../viewmodel/SearchKeyboardViewModel';
import { TVSearchTabs } from './TVSearchTabs';
import { TVSearchVideos } from './TVSearchVideos';

const TAG = '[TVSearchView]';

@Component
export struct TVSearchView {
  @State isHover: boolean = false;
  @State searchInput: string = '';
  @State selectionStart: number = 0;
  @State selectionEnd: number = 0;
  @State nextCaret: number = -1;
  @State currentIndexForContent: number = 0;
  @State currentIndexForResult:  number = 0;
  private keyboard: SearchKeyboardViewModel = new SearchKeyboardViewModel();
  private videoImgViewModel: SearchVideoImgViewModel = new SearchVideoImgViewModel();
  private textInputController: TextInputController = new TextInputController();
  private searchVideoImgViewModel: SearchVideoImgViewModel = new SearchVideoImgViewModel();

  build() {
    Column() {
      this.searchHeader()

      this.KeyBoardGrid()

      this.TVSearchContent()

      this.TVSearchResult()
    }
    .margin({ top: '128vp' })
    .padding({ bottom: '48vp' })
    .width('100%')
  }

  @Builder
  searchHeader() {
    Stack({ alignContent: Alignment.Start }) {
      TextInput({ placeholder: $r('app.string.search2'), text: this.searchInput, controller: this.textInputController })
        .placeholderFont({
          size: '24fp',
          weight: FontWeight.Normal
        })
        .placeholderColor($r('app.color.search_placeholder'))
        .fontColor(Color.White)
        .fontSize('24fp')
        .width('100%')
        .backgroundColor(Color.Transparent)
        .enableKeyboardOnFocus(false)
        .padding({ left: '50vp', top: '0vp', bottom: '0vp' })
        .onChange((value: string) => {
          this.searchInput = value;
          this.setCaret();
        })
        .onHover((isHover) => {
          this.isHover = isHover;
        })
        .onTouch((event) => {
          this.isHover = event.type === TouchType.Down;
        })
        .onTextSelectionChange((selectionStart: number, selectionEnd: number) => {
          this.selectionStart = selectionStart;
          this.selectionEnd = selectionEnd;
        })
        .alignSelf(ItemAlign.Center)
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize('32fp')
        .fontColor([Color.White])
        .opacity(0.6)
    }
    .alignSelf(ItemAlign.Center)
    .width('757vp')
    .height('48vp')
    .padding({ bottom: '16vp' })
    .border({ width: { bottom: '2vp' }, color: { bottom: $r('app.color.search_header_border_tv') } })
  }

  @Styles
  TextInputOnClicked() {
    .backgroundColor(Color.Black)
  }

  @Builder
  KeyBoardGrid() {
    Row() {
      Grid() {
        ForEach(this.keyboard.getLetterList(), (item: KeyboardItemViewModel) => {
          GridItem() {
            this.KeyBoardGridItem(item)
          }
          .backgroundColor('rgba(241,243,245,0.2)')
          .borderRadius(8)
          .columnStart(item.columnStart)
          .columnEnd(item.columnEnd)
          .clip(false)
        }, (item: KeyboardItemViewModel) => item.label + JSON.stringify(item))
      }
      .clip(false)
      .width('804vp')
      .height('138vp')
      .rowsGap('5vp')
      .columnsGap('5vp')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsTemplate('repeat(10, 1fr)')

      Grid() {
        ForEach(this.keyboard.getDigitList(), (item: KeyboardItemViewModel) => {
          GridItem() {
            this.KeyBoardGridItem(item)
          }
          .backgroundColor('rgba(241,243,245,0.2)')
          .borderRadius(8)
          .columnStart(item.columnStart)
          .columnEnd(item.columnEnd)
          .clip(false)
        }, (item: KeyboardItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .width('318vp')
      .height('138vp')
      .clip(false)
      .rowsGap('5vp')
      .columnsGap('5vp')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .padding({
      left: '56vp',
      right: '56vp'
    })
    .margin({ top: '24vp' })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  @Builder
  KeyBoardGridItem(item: KeyboardItemViewModel) {
    Row() {
      if (item.label === SearchConstants.SEARCH_ACTION[0]) {
        this.KeyBoardImg($r('app.media.ic_public_trash_fill'))
      } else if (item.label === SearchConstants.SEARCH_ACTION[1]) {
        Row(){
          this.KeyBoardImg($r('app.media.ic_public_delete_left_fill'))
          Text($r('app.string.backspace'))
            .fontColor(Color.White)
            .opacity(0.9)
            .fontSize('18fp')
            .margin({ left: '4vp' })
        }
      } else {
        Text(item.label)
          .fontColor(Color.White)
          .fontSize('20fp')
          .fontWeight(500)
      }
    }
    .hoverEffect(HoverEffect.Highlight)
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onKeyPress(item.label);
    })
  }

  @Builder
  KeyBoardImg(img: ResourceStr) {
    Image(img)
      .width('28vp')
      .height('28vp')
  }

  @Builder
  searchDiscovery() {
    Text($r('app.string.everyone_is_searching'))
      .fontWeight(700)
      .fontSize('26fp')
      .lineHeight('35vp')
      .padding({
        top: '35vp',
        bottom: '16vp',
        left: '56vp'
      })
      .width('100%')
      .textAlign(TextAlign.Start)
    List({ space: '32vp' }) {
      ForEach(this.videoImgViewModel.getDiscoverSearchList(), (item: SearchVideoItemViewModel) => {
        ListItem() {
          Column() {
            Image(item.getImgSrc())
              .width('168vp')
              .borderRadius(16)
              .margin({ bottom: '16vp' })
            Text(item.getTitle())
              .fontSize('18fp')
              .fontWeight(500)
              .lineHeight('24vp')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .width('168vp')
      }, (item: SearchVideoItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)
    .listDirection(Axis.Horizontal)
    .padding({ left: '56vp', right: '56vp' })
  }

  @Builder
  TVSearchContent() {
    Column() {
      this.searchHistory()
      this.everyoneSearching()
      this.searchHotTrending()
    }
    .visibility(this.searchInput === SearchConstants.SEARCH_INPUT_LIST[2] ? Visibility.None :
      Visibility.Visible)
  }

  @Builder
  searchHistory() {
    List({ space: 32 }) {
      ForEach(SearchConstants.SEARCH_HISTORY_AND_DISCOVERY, (item: ResourceStr, index: number) => {
        ListItem() {
          Row() {
            if(index === 0){
              Image($r('app.media.ic_public_delete1'))
                .height('24vp')
                .width('24vp')
                .margin({ right: '3vp' })
                .opacity(0.9)
            }
            Text(item)
              .fontSize('24fp')
              .fontColor(Color.White)
              .opacity(0.9)
              .fontWeight(500)
          }
          .height('56vp')
          .borderRadius(28)
          .padding({ left: '16vp', right: '16vp' })
          .backgroundColor($r('app.color.search_background'))
          .hoverEffect(HoverEffect.Highlight)
          .border({
            color: $r('app.color.search_border'),
            width: '1vp'
          })
        }
      }, (item: ResourceStr, index: number) => index + String(item))
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .padding({ left: '56vp' })
    .margin({ top: '32vp' })
  }

  @Builder
  searchHotTrending() {
    TVSearchTabs({
      currentIndex: this.currentIndexForContent,
      list: SearchConstants.SEARCH_TABS,
      onTabChange: (index: number) => {
        this.currentIndexForContent = index;
      }
    })
    TVSearchVideos({ videoList: this.searchVideoImgViewModel.getHotSearchList() })
  }

  @Builder
  everyoneSearching() {
    Text($r('app.string.everyone_is_searching'))
      .fontWeight(700)
      .fontSize('26fp')
      .lineHeight('35vp')
      .fontColor(Color.White)
      .opacity(0.9)
      .padding({
        top: '35vp',
        bottom: '16vp',
        left: '56vp'
      })
      .width('100%')
      .textAlign(TextAlign.Start)

    List({ space: '32vp' }) {
      ForEach(this.searchVideoImgViewModel.getDiscoverSearchList(), (item: SearchVideoItemViewModel) => {
        ListItem() {
          Column() {
            Image(item.getImgSrc())
              .width('168vp')
              .height('232vp')
              .borderRadius(16)
              .margin({ bottom: '16vp' })
              .hoverEffect(HoverEffect.Scale)

            Text(item.getTitle())
              .fontSize('18fp')
              .fontWeight(500)
              .fontColor(Color.White)
              .opacity(0.9)
              .lineHeight('24vp')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .width('168vp')
        .clip(false)
      }, (item: SearchVideoItemViewModel, index: number) => index + JSON.stringify(item))
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)
    .listDirection(Axis.Horizontal)
    .clip(false)
    .padding({ left: '56vp', right: '56vp' })
  }

  @Builder
  TVSearchResult() {
    Column(){
      this.SearchForHua()
      this.SearchResult()
    }
    .visibility(this.searchInput === SearchConstants.SEARCH_INPUT_LIST[2] ? Visibility.Visible :
      Visibility.None)
  }

  @Builder
  SearchForHua() {
    List({ space: 32 }){
      ForEach(SearchConstants.HUA_LIST_FOR_HUA, (item: ResourceStr) => {
        ListItem(){
          Row(){
            Text(item)
              .fontSize('24fp')
              .fontColor(Color.White)
              .opacity(0.9)
              .fontWeight(500)
          }
          .height('56vp')
          .borderRadius(28)
          .padding({ left: '16vp', right: '16vp' })
          .backgroundColor($r('app.color.search_background'))
          .border({
            color: $r('app.color.search_border'),
            width: 1
          })
          .hoverEffect(HoverEffect.Highlight)
        }
      }, (item: ResourceStr, index: number) => index + String(item))
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)
    .listDirection(Axis.Horizontal)
    .padding({ left: '56vp' })
    .margin({ top: '32vp' })
  }

  @Builder
  SearchResult() {
    TVSearchTabs({
      currentIndex: this.currentIndexForResult,
      list: SearchConstants.SEARCH_RESULT_TAB_LIST,
      onTabChange: (index: number) => {
        this.currentIndexForResult = index;
      }
    })
    TVSearchVideos({
      videoList: new SearchVideoImgViewModel().getSearchResultList()
    })
  }

  private onKeyPress(key: ResourceStr): void {
    const len = this.selectionEnd - this.selectionStart;
    switch (key) {
      case SearchConstants.SEARCH_ACTION[0]: {
        this.searchInput = '';
        break;
      }
      case SearchConstants.SEARCH_ACTION[1]: {
        if (len > 0) {
          this.nextCaret = this.selectionStart
          this.searchInput = this.searchInput.slice(0, this.selectionStart) + this.searchInput.slice(this.selectionEnd);
        } else if (this.selectionStart > 0) {
          this.nextCaret = this.selectionStart - 1
          this.searchInput =
            this.searchInput.slice(0, this.selectionStart - 1) + this.searchInput.slice(this.selectionEnd);
        }
        break;
      }
      default: {
        const beforeCursor = this.searchInput.slice(0, this.selectionStart);
        const afterCursor = this.searchInput.slice(this.selectionEnd);
        this.searchInput = beforeCursor + key + afterCursor;
        this.nextCaret = this.selectionStart + 1
        break;
      }
    }
  }

  setCaret() {
    if (this.nextCaret !== -1) {
      Logger.info(TAG, `To keep caret position right, change caret to ${this.nextCaret}.`);
      this.textInputController.caretPosition(this.nextCaret)
      this.nextCaret = -1
    }
  }
}
