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
import { Logger, WindowInfo, BreakpointType, BreakpointVisibilityUtil } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';
import { IconViewModel, VideoIconItemViewModel } from '../viewmodel/IconViewModel';
import { getTabIndex } from './CommonView';

const TAG = '[IconView]';

@Component
export struct IconView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  private iconList: VideoIconItemViewModel[] = new IconViewModel().getIconList();
  private breakpointFlags() {
    return BreakpointVisibilityUtil.getFlags(this.mainWindowInfo);
  }

  build() {
    Column() {
      List({ space: this.getSpace(this.mainWindowInfo.windowSize.width, this.mainWindowInfo.widthBp) }) {
        ForEach(this.iconList, (item: VideoIconItemViewModel, index: number) => {
          ListItem() {
            Column() {
              Image(item.getImage())
                .width('40vp')
                .height('40vp')
                .margin({ bottom: '4vp' })
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .borderRadius(20)

              Text(item.getName())
                .fontSize('12fp')
                .fontWeight(FontWeight.Normal)
                .lineHeight('20vp')
                .fontColor(this.currentTopIndex === 2 ? Color.White : Color.Black)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .height('76vp')
          }
          .padding({
            right: index === this.iconList.length - 1 ?
              this.getSpace(this.mainWindowInfo.windowSize.width, this.mainWindowInfo.widthBp) / 2 : 0
          })
        }, (item: VideoIconItemViewModel) => JSON.stringify(item))
      }
      .clip(false)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .scrollSnapAlign(ScrollSnapAlign.START)
      .edgeEffect(EdgeEffect.None)
      .chainAnimation(true)
      .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[3]))
      .width('100%')
      .height('auto')
    }
    .padding({
      left: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp)
    })
    .margin({ top: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? '4vp' : '0vp' })
    .visibility(this.breakpointFlags().isWidthBpAboveMd && this.currentTopIndex === 2 ?
      Visibility.None : Visibility.Visible)
  }

  /**
   * Calculates spacing between icon items based on window width and breakpoint.
   */
  getSpace(windowWidth: number, currentWidthBreakpoint: number): number {
    try {
      if (this.getUIContext().getHostContext() === undefined) {
        return 0;
      }
      let result: number =
        this.getUIContext().px2vp(windowWidth) -
          (new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0], HomeConstants.VIDEO_GRID_MARGIN[0],
            HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2],
            HomeConstants.VIDEO_GRID_MARGIN[3]).getValue(this.mainWindowInfo.widthBp) / HomeConstants.TWO) -
        HomeConstants.ICON_IMG_HALF_SIZE;
      if (currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
        result = (result - HomeConstants.ICONVIEW_ITEM_WIDTH[0] * HomeConstants.FOUR) / HomeConstants.FOUR;
      } else if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_MD) {
        result = (result - HomeConstants.ICONVIEW_ITEM_WIDTH[1] * HomeConstants.SIX) / HomeConstants.SIX;
      } else if (currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG) {
        result =
          (result - HomeConstants.LG_SIDEBAR_WIDTH - HomeConstants.ICONVIEW_ITEM_WIDTH[2] * HomeConstants.EIGHT) /
          HomeConstants.EIGHT;
      } else {
        result =
          (result - HomeConstants.XL_SIDEBAR_WIDTH - HomeConstants.ICONVIEW_ITEM_WIDTH[3] * HomeConstants.EIGHT) /
          HomeConstants.EIGHT;
      }
      return result;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getNumber failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    return 0;
  }
}