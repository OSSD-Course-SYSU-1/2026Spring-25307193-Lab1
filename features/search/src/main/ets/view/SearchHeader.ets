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

import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, WindowInfo, WindowUtil } from '@ohos/commons';
import { SearchConstants } from '../constants/SearchConstants';

const TAG = '[SearchHeader]';

@Component
export struct SearchHeader {
  @Link searchInput: string;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @ObjectLink @Watch('mainWindowInfoChange') mainWindowInfo: WindowInfo;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @State topAvoidHeight: number = 0;
  @State decorWidth: number = 0;
  @State decorHeight: number = 0;

  /**
   * Updates layout when window info changes.
   */
  mainWindowInfoChange() {
    this.topAvoidHeight = this.getUIContext().px2vp(this.mainWindowInfo.avoidSystem?.topRect.height);
    this.topAvoidHeight = Math.max(this.topAvoidHeight, 8);
    if (this.windowUtil !== undefined) {
      try {
        this.decorWidth = this.windowUtil.mainWindow.getTitleButtonRect().width;
        this.decorHeight = this.windowUtil.mainWindow.getTitleButtonRect().height;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `getTitleButtonRect failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  aboutToAppear(): void {
    this.mainWindowInfoChange();
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_public_arrow_left1'))
          .height('24vp')
          .width('24vp')
      }
      .justifyContent(FlexAlign.Center)
      .height('40vp')
      .width('40vp')
      .margin({ right: '8vp' })
      .onClick(() => {
        this.pageInfo.pop();
        this.searchInput = '';
        try {
          this.windowUtil?.mainWindow.setWindowDecorVisible(this.mainWindowInfo.widthBp < WidthBreakpoint.WIDTH_XL);
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `setWindowDecorVisible failed, errCode = ${err.code}, errMessage = ${err.message}`);
        }
      })
      .backgroundColor(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? '' : $r('app.color.search_header_background'))
      .borderRadius('1000vp')

      Stack({ alignContent: Alignment.Start }) {
        // Search box.
        TextInput({ placeholder: SearchConstants.SEARCH_PLACEHOLDER, text: this.searchInput })
          .placeholderFont({
            size: '16fp',
            weight: FontWeight.Normal
          })
          .placeholderColor('#99000000')
          .height('40vp')
          .fontSize('16fp')
          .padding({
            left: '36vp',
            right: '12vp'
          })
          .width('100%')
          .enableKeyboardOnFocus(false)
          .onChange((value: string) => {
            this.searchInput = value;
          })
          .cancelButton({
            style: CancelButtonStyle.INPUT,
            icon: {
              src: $r('app.media.xmark'),
              size: 16,
              color: '#99000000'
            }
          })
          .backgroundColor('#0d000000')

        // Search image.
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize('16fp')
          .margin({ left: '12vp' })
          .fontColor(['app.color.search_header_img_color'])
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1)
    }
    .padding({
      top: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? '0vp' : `${this.topAvoidHeight}vp`,
      right: this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? `${this.decorWidth}vp` : '0vp',
      bottom: this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD ? '8vp' : '0vp'
    })
    .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_XL ? this.decorHeight : 'auto')
    .width('100%')
  }
}