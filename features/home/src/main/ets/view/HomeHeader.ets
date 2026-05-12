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

import {
  ImmersiveType,
  WindowInfo,
  WindowUtil,
  BreakpointType,
  SetDecorButtonStyleUtil
} from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { getTabIndex } from './CommonView';

@Component
export struct HomeHeader {
  @ObjectLink @Watch('mainWindowInfoChange') mainWindowInfo: WindowInfo;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Link scrollHeight: number;
  @Link decorWidth: number;
  @State isShowingBorder: boolean = false;
  @State topAvoidHeight: number = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.topRect.height);

  /**
   * Updates top avoid height when main window info changes.
   */
  mainWindowInfoChange() {
    this.topAvoidHeight = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.topRect.height);
    SetDecorButtonStyleUtil.setDecorButtonForImmersive(this.currentTopIndex, this.mainWindowInfo.widthBp, this.pageInfo,
      this.windowUtil);
  }

  /**
   * Returns grid column span for small breakpoint based on screen size.
   */
  getSMBreakPointColSpans(): number {
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) {
      return 4;
    } else {
      return 2;
    }
  }

  /**
   * Returns top padding for search bar based on breakpoint.
   */
  getTopSearchBarPaddingTop(): string | Resource {
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) {
      return '0vp';
    }
    return '8vp'
  }

  /**
   * Returns top padding for top tab bar based on breakpoint.
   */
  getTopTabBarPaddingTop(): string | Resource {
    if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
      this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) {
      return this.topAvoidHeight + HomeConstants.VP_UNIT;
    }
    return '8vp'
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 12, lg: 12, xl: 12 } }) {
        GridCol({ span: { sm: this.getSMBreakPointColSpans(), md: 7, lg: 7, xl: 7 } }) {
          this.TopTabBar()
        }
        .margin({ top: this.getTopTabBarPaddingTop() })
        .height(this.currentTopIndex === 2 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ?
          `${this.topAvoidHeight + 59}${HomeConstants.VP_UNIT}` : '59vp')
        .padding({
          top: this.currentTopIndex === 2 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ?
            `${this.topAvoidHeight}${HomeConstants.VP_UNIT}` : '0vp'
        })

        GridCol({ span: { sm: this.getSMBreakPointColSpans(), md: 5, lg: 5, xl: 5 } }) {
          this.searchBar()
        }
        .margin({ top: this.getTopSearchBarPaddingTop(), right: this.decorWidth })
        .height(this.currentTopIndex === 2 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ?
          `${this.topAvoidHeight + 59}${HomeConstants.VP_UNIT}` : '59vp')
        .width('146vp')
        .padding({
          top: this.currentTopIndex === 2 && this.mainWindowInfo.widthBp > WidthBreakpoint.WIDTH_SM ?
            `${this.topAvoidHeight}${HomeConstants.VP_UNIT}` : '0vp'
        })
      }
      // The background color of the top tab bar is changed during the slide-down process.
      .backgroundColor(this.scrollHeight >=
      new BreakpointType(HomeConstants.BACKGROUND_CHANGE_HEIGHT[0], HomeConstants.BACKGROUND_CHANGE_HEIGHT[0],
        HomeConstants.BACKGROUND_CHANGE_HEIGHT[1], HomeConstants.BACKGROUND_CHANGE_HEIGHT[2],
        HomeConstants.BACKGROUND_CHANGE_HEIGHT[2])
        .getValue(this.mainWindowInfo.widthBp) && this.currentTopIndex === 2 ? $r('app.color.home_content_background') :
        Color.Transparent)
    }
    .width('100%')
  }

  @Builder
  TopTabBar() {
    Row() {
      Column() {
        List() {
          ForEach(HomeConstants.TOP_TOPIC_LIST, (item: string, index: number) => {
            ListItem() {
              Text(item)
                .fontSize(this.currentTopIndex === index ? '24fp' : '18fp')
                .fontWeight(this.currentTopIndex === index ? 700 : 500)
                .textAlign(TextAlign.Center)
                .fontColor(this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .borderRadius(4)
                .opacity(this.currentTopIndex === index ? 1 : 0.6)
            }
            .align(Alignment.Center)
            .margin({
              top: this.currentTopIndex === index ? '12vp' : '16vp',
              bottom: this.currentTopIndex === index ? '11vp' : '15vp'
            })
            .padding({
              left: new BreakpointType(8, 8, 12, 18, 18).getValue(this.mainWindowInfo.widthBp),
              right: new BreakpointType(8, 8, 12, 18, 18).getValue(this.mainWindowInfo.widthBp)
            })
            .onClick(() => {
              this.currentTopIndex = index;
              this.scrollHeight = 0;
              SetDecorButtonStyleUtil.setDecorButtonForImmersive(index, this.mainWindowInfo.widthBp, this.pageInfo,
                this.windowUtil);
            })
          }, (item: number, index: number) => index + JSON.stringify(item))
        }
        .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[1]))
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .padding({ left: '24vp' })
        .width('100%')
        .height('100%')
      }
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      Row() {
        Image($r('app.media.ic_public_more'))
          .width('24vp')
          .height('24vp')
          .fillColor(this.currentTopIndex === 2 ? Color.White : Color.Black)
      }
      .backgroundColor(this.currentTopIndex === 2 ? $r('app.color.icon_button_background_light') : $r('app.color.button_background'))
      .width('40vp')
      .height('40vp')
      .margin({
        left: '24vp',
        right: '24vp'
      })
      .border({
        width: 0,
        radius: 20
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .visibility((this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) ? Visibility.Visible : Visibility.None)
    }
    .height('56vp')
    .width('100%')
  }

  @Builder
  searchBar() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        TextInput({ placeholder: HomeConstants.SEARCH_PLACEHOLDER })
          .placeholderFont({
            size: '16fp',
            weight: FontWeight.Normal
          })
          .placeholderColor(this.currentTopIndex === 2 ? Color.White : '#99000000')
          .height('40vp')
          .fontSize('16fp')
          .padding({
            left: '36vp',
            right: '12vp'
          })
          .width('100%')
          .onClick(() => {
            this.pageInfo.pushPath({ name : HomeConstants.PAGE_NAME_FOR_SEARCH });
          })
          .onSubmit((enterKey: EnterKeyType) => {
            if (enterKey === EnterKeyType.Go) {
              this.pageInfo.pushPath({ name : HomeConstants.PAGE_NAME_FOR_SEARCH });
            }
          })
          .enterKeyType(EnterKeyType.Go)
          .enableKeyboardOnFocus(false)
          .backgroundColor(this.currentTopIndex === 2 ? '#1affffff' : '#0d000000')
          .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[1]))
          .focusable(false)

        // Search image.
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize('16fp')
          .margin({ left: '12vp' })
          .fontColor([this.currentTopIndex === 2 ? Color.White : 'app.color.search_header_img_color'])
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1)
      .visibility((this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD) ? Visibility.None : Visibility.Visible)

      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize('24fp')
          .fontColor([this.currentTopIndex === 2 ? Color.White : 'app.color.search_header_img_color'])
      }
      .backgroundColor(this.currentTopIndex === 2 ? $r('app.color.icon_button_background_light') : $r('app.color.button_background'))
      .width('40vp')
      .height('40vp')
      .border({
        width: 0,
        radius: 20
      })
      .margin({ bottom: '4vp' })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .visibility((this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD) ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.windowUtil?.setImmersiveType(ImmersiveType.IMMERSIVE);
        this.pageInfo.pushPath({ name: HomeConstants.PAGE_NAME_FOR_SEARCH });
      })

      // History image.
      Row() {
        SymbolGlyph($r('sys.symbol.arrow_counterclockwise_clock'))
          .fontSize('24fp')
          .fontColor([this.currentTopIndex === 2 ? Color.White : Color.Black])
      }
      .backgroundColor(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? '' :
        this.currentTopIndex === 2 ? $r('app.color.icon_button_background_light') : $r('app.color.button_background'))
      .width('40vp')
      .height('40vp')
      .margin({
        left: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
          this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '8vp' : '15vp',
        bottom: '4vp' })
      .border({
        width: 0,
        radius: 20
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize('24fp')
          .fontColor([this.currentTopIndex === 2 ? Color.White : Color.Black])
      }
      .backgroundColor(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? '' : this.currentTopIndex === 2 ?
        $r('app.color.icon_button_background_light') : $r('app.color.button_background'))
      .width('40vp')
      .height('40vp')
      .margin({ left: '8vp', bottom: '4vp' })
      .border({
        width: 0,
        radius: 20
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .visibility((this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp >= HeightBreakpoint.HEIGHT_LG) ? Visibility.None : Visibility.Visible)
    }
    .padding({
      left: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '10.5vp' : '24vp',
      right: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '10.5vp' : '24vp'
    })
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('56vp')
  }
}