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

import { BreakpointType, WindowInfo } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';

@Builder
export function VideoImgRating(rating: string, isOnDisplay: boolean = false) {
  Row() {
    Text(rating)
      .fontSize('7fp')
      .fontWeight(FontWeight.Normal)
      .fontColor(Color.White)
      .height('12vp')
      .width('20vp')
      .margin({
        right: '8vp',
        bottom: '8vp'
      })
      .backgroundColor($r('app.color.main_daily_rating_background'))
      .borderRadius(2)
      .textAlign(TextAlign.Center)
  }
  .justifyContent(FlexAlign.End)
  .width('100%')
  .visibility(rating === '' || isOnDisplay ? Visibility.None : Visibility.Visible)
}

@Component
export struct VideoTitle {
  @Consume isOnDisplay: boolean;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  public title: ResourceStr = '';

  build() {
    Text(this.title)
      .fontWeight(FontWeight.Normal)
      .fontSize(this.isOnDisplay ? '18fp' : '14fp')
      .lineHeight(this.isOnDisplay ? '24vp' : '21vp')
      .margin({ top: '4vp' })
      .fontColor(this.isOnDisplay || this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .opacity(this.isOnDisplay ? 0.9: 1)
  }
}

@Component
export struct VideoContent {
  @Consume isOnDisplay: boolean;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  public content: ResourceStr = '';

  build() {
    Text(this.content)
      .fontSize(this.isOnDisplay ? '16fp' : '12fp')
      .lineHeight(this.isOnDisplay ? '21vp' : '18vp')
      .opacity(this.isOnDisplay ? 0.6: 0.4)
      .fontWeight(FontWeight.Normal)
      .maxLines(1)
      .margin({ top: '2vp' })
      .fontColor(this.isOnDisplay || this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

@Component
export struct SubtitleComponent {
  @Consume isOnDisplay: boolean;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Consume('currentTopIndex') currentTopIndex: number = 0;
  public title: ResourceStr = '';

  build() {
    Text(this.title)
      .fontSize(this.isOnDisplay ? '26fp' : '16fp')
      .fontWeight(this.isOnDisplay ? 700 : 500)
      .fontColor(this.isOnDisplay || this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
      .lineHeight(this.isOnDisplay ? '35vp' : '22vp')
      .width('100%')
      .padding({
        left: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp),
        right: new BreakpointType('16vp', '16vp', '24vp', '36vp', '36vp').getValue(this.mainWindowInfo.widthBp)
      })
      .opacity(this.isOnDisplay ? 0.9 : 1)
  }
}

@Builder
export function VideoImgComponent(imgSrc: ResourceStr = '', index: number = 0) {
  Image(imgSrc)
    .focusable(true)
    .groupDefaultFocus(index === 0 ? true : false)
    .objectFit(ImageFit.Cover)
    .width('100%')
    .height('100%')
    .draggable(false)
    .borderRadius(12)
}

@Component
export struct VideoImgPlay {
  @ObjectLink mainWindowInfo: WindowInfo;

  build() {
    Column() {
      Image($r('app.media.new_video_play'))
        .height(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '32vp' : '24vp')
        .width(this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG ? '32vp' : '24vp')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Builder
export function MembershipTag(tagText: ResourceStr = 'SVIP') {
  Stack() {
    Image($r('app.media.newMarkGray'))
      .width('45vp')
      .height('20vp')
    Text(tagText)
      .fontColor(Color.White)
      .fontSize('12vp')
  }
  .margin({
    top: '5vp',
    right: '7vp'
  })
}

/**
 * Returns tab index for focus navigation based on direction name.
 */
export function getTabIndex(direction: string): number {
  let tabIndex: number = 0;
  switch (direction) {
    case HomeConstants.DIRECTION_LIST[0]:
      tabIndex = 1;
      break;
    case HomeConstants.DIRECTION_LIST[1]:
      tabIndex = 2;
      break;
    case HomeConstants.DIRECTION_LIST[2]:
      tabIndex = 3;
      break;
    case HomeConstants.DIRECTION_LIST[3]:
      tabIndex = 4;
      break;
    case HomeConstants.DIRECTION_LIST[4]:
      tabIndex = 5;
      break;
    case HomeConstants.DIRECTION_LIST[5]:
      tabIndex = 6;
      break;
    case HomeConstants.DIRECTION_LIST[6]:
      tabIndex = 7;
      break;
    case HomeConstants.DIRECTION_LIST[7]:
      tabIndex = 8;
      break;
    case HomeConstants.DIRECTION_LIST[8]:
      tabIndex = 9;
      break;
    default:
      break;
  }
  return tabIndex;
}