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
import { Logger, WindowInfo, WindowUtil, BreakpointType } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';
import { UserInfoViewModel, UserViewModel } from '../viewmodel/UserViewModel';

const TAG = '[AllComments]';

@Component
export struct AllComments {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link commentImgHeight: string;
  @Link commentImgWidth: string;
  private commentsList: UserInfoViewModel[] = new UserViewModel().getRelatedVideoList();

  build() {
    Column() {
      Row() {
        this.TitleText(DetailConstants.SUB_TITLES[0])
      }
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .height('48vp')
      .width('100%')

      Column() {
        ForEach(this.commentsList, (item: UserInfoViewModel, index: number) => {
          Row() {
            Image(item.getImageSrc())
              .height('36vp')
              .width('36vp')
              .margin({ right: '16vp' })

            this.TitleText(item.getName())
          }
          .height('48vp')
          .width('100%')
          .margin({ top: '10vp' })
          .alignItems(VerticalAlign.Center)

          Row() {
            Text(item.getComment())
              .margin({ left: '52vp' })
              .opacity(0.6)
              .fontSize('14fp')
              .lineHeight('28vp')
              .fontWeight(500)
          }
          .margin({ top: '4vp' })
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Image(item.getCommentImageSrc())
              .width(new BreakpointType(DetailConstants.XSMALL_COMMENT_IMAGE_WIDTH,
                DetailConstants.SMALL_COMMENT_IMAGE_WIDTH, DetailConstants.MEDIUM_COMMENT_IMAGE_WIDTH,
                this.commentImgWidth, this.commentImgWidth).getValue(this.mainWindowInfo.widthBp))
              .height(new BreakpointType(DetailConstants.XSMALL_COMMENT_IMAGE_HEIGHT,
                DetailConstants.SMALL_COMMENT_IMAGE_HEIGHT, DetailConstants.MEDIUM_COMMENT_IMAGE_HEIGHT,
                this.commentImgHeight, this.commentImgHeight).getValue(this.mainWindowInfo.widthBp))
              .borderRadius(8)
              .aspectRatio(1.56)
          }
          .padding({ left: '52vp' })
          .margin({ top: '12vp' })
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .visibility(!item.getCommentImageSrc() ? Visibility.None : Visibility.Visible)

          Row() {
            Text(item.getTime())
              .opacity(0.6)
              .fontSize('12fp')
              .lineHeight('18vp')
              .fontWeight(FontWeight.Normal)
              .margin({ left: '52vp' })

            Blank()

            this.IconImage($r('app.media.ellipsis_message'), '24vp')
            this.IconImage($r('app.media.hand_thumbsup'), '24vp')
            this.IconImage($r('app.media.arrowshape_turn_up_right'))
          }
          .margin({ top: '14vp' })
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Divider()
            .color(Color.Black)
            .opacity(0.05)
            .margin({
              top: '12vp'
            })
            .height('1vp')
            .width('100%')
            .visibility(index === this.commentsList.length - 1 ? Visibility.None : Visibility.Visible)
        }, (item: UserInfoViewModel, index: number) => index + JSON.stringify(item))
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .padding({ top: this.getTopPadding() })
  }

  @Builder
  TitleText(content: ResourceStr) {
    Text(content)
      .fontSize('16fp')
      .lineHeight('22vp')
      .fontWeight(500)
  }

  @Builder
  IconImage(image: ResourceStr = '', margin: ResourceStr = '0vp') {
    Image(image)
      .height('16vp')
      .width('16vp')
      .margin({ right: margin })
  }

  getTopPadding(): number {
    if (!(this.mainWindowInfo.heightBp < HeightBreakpoint.HEIGHT_LG &&
      this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG)) {
      return 0;
    }
    let decorHeight: number | undefined = undefined;
    let statusHeight: number | undefined = this.mainWindowInfo.avoidSystem?.topRect.height;
    try {
      decorHeight = this.windowUtil?.mainWindow.getTitleButtonRect().height;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to get decorHeight, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    if (!!decorHeight) {
      return decorHeight;
    } else if (!!statusHeight) {
      return this.getUIContext().px2vp(statusHeight);
    } else {
      return 0;
    }
  }
}