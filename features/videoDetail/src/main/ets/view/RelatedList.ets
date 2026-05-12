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

import { BreakpointVisibilityUtil, WindowInfo } from '@ohos/commons';
import { DetailConstants } from '../constants/DetailConstants';
import { CurrentOffsetUtil } from '../utils/CurrentOffsetUtil';
import { RelatedVideoItemViewModel, RelatedVideoViewModel } from '../viewmodel/RelatedVideoViewModel';
import { AllComments } from './AllComments';

@Component
export struct RelatedList {
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  // The current vertical sliding distance of the list.
  @Link currentYOffset: number;
  @Link isHidingSelfComment: boolean;
  @State commentImgHeight: string = DetailConstants.INITIAL_COMMENT_IMAGE_HEIGHT;
  @State commentImgWidth: string = DetailConstants.INITIAL_COMMENT_IMAGE_WIDTH;
  public screenHeight: number = 0;
  private relatedVideoList: RelatedVideoItemViewModel[] = new RelatedVideoViewModel().getRelatedVideoList();
  private peripheralVideoList: RelatedVideoItemViewModel[] = new RelatedVideoViewModel().getPeripheralVideoList();
  private episodes: string[] = DetailConstants.PLAYER_EPISODE;
  private currentIndex: number = 2;
  private iconList: Resource[] = DetailConstants.ICON_LIST;
  private scroller: Scroller = new Scroller();
  private breakpointFlags() {
    return BreakpointVisibilityUtil.getFlags(this.mainWindowInfo);
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        this.RelatedVideoComponent()
        this.VideoIntroduction()
        AllComments({
          commentImgHeight: this.commentImgHeight,
          commentImgWidth: this.commentImgWidth,
          mainWindowInfo: this.mainWindowInfo
        })
          .visibility(this.breakpointFlags().isWidthBpAboveMdAndHeightBpBelowLg ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ bottom: '10vp' })
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .visibility(!this.isFullScreen ? Visibility.Visible : Visibility.None)
    .onScrollFrameBegin((offset: number) => {
      if (this.mainWindowInfo.widthBp >= WidthBreakpoint.WIDTH_LG) {
        if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT
            ? offsetPercent : this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset < 0) && (this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight
            ? offsetPercent : DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        }
        return { offsetRemain: offset };
      } else if (this.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.heightBp <= HeightBreakpoint.HEIGHT_MD) {
        if (offset > 0) {
          this.currentYOffset += offset;
          this.isHidingSelfComment = true;
          if (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) {
            // Video zoom-out logic.
            // Percentage of screen height by sliding.
            let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
            // Video shrinkage percentage.
            let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT
              ? offsetPercent : this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
            this.videoHeight = this.videoHeight - heightOffset;
            // Returns the actual offset 0.
            return { offsetRemain: 0 };
          }
        } else if (offset < 0) {
          if (this.isHidingSelfComment) {
            this.getUIContext().animateTo({
              duration: 300
            }, () => {
              this.currentYOffset = 0;
              this.isHidingSelfComment = false;
            });
          }
          if ((this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset()))) {
            // Video magnification logic.
            let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
            let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight
              ? offsetPercent : DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
            this.videoHeight = this.videoHeight + heightOffset;
            // Returns the actual offset 0.
            return { offsetRemain: 0 };
          }
          return { offsetRemain: offset };
        }
        return { offsetRemain: offset };
      } else {
        if ((offset > 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT
            ? offsetPercent : this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset > 0) && (this.videoHeight === DetailConstants.MIN_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          return { offsetRemain: offset };
        } else if ((offset < 0) && (this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          if (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset()))) {
            // Video magnification logic.
            let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
            let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight
              ? offsetPercent : DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
            this.videoHeight = this.videoHeight + heightOffset;
            // Returns the actual offset 0.
            return { offsetRemain: 0 };
          }
          return { offsetRemain: offset };
        } else if ((offset < 0) && (this.videoHeight === 100) && (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * 169) > 169 ? 169 :
            (this.relatedVideoHeight + offsetPercent * 169);
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        }
        return { offsetRemain: 0 };
      }
    })
  }

  @Builder
  RelatedVideoComponent() {
    Column() {
      this.SubTitleAndMore(DetailConstants.SUB_TITLES[1])

      Row() {
        List({ space: '12vp' }) {
          ForEach(this.relatedVideoList, (item: RelatedVideoItemViewModel, index: number) => {
            ListItem() {
              Column() {
                Image(item.getImageSrc())
                  .height('76vp')
                  .width('135vp')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                  .margin({ bottom: '8vp' })

                Text(item.getName())
                  .fontSize('14fp')
                  .lineHeight('19vp')
                  .fontWeight(500)
                  .opacity(0.6)
                  .fontColor(index === 0 ? '#ED6F21' : Color.Black)
              }
            }
            .margin({
              top: '8vp',
              bottom: '10vp'
            })
          }, (item: RelatedVideoItemViewModel, index: number) => index + JSON.stringify(item))
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }
      .padding({
        left: '24vp',
        bottom: '10vp'
      })
      .height('121vp')
      .width('100%')
    }
    .height(this.relatedVideoHeight + DetailConstants.LENGTH_UNIT)
    .backgroundColor(Color.White)
  }

  @Builder
  VideoIntroduction() {
    Column() {
      this.SubTitle($r('app.string.introduction'))

      Column() {
        this.IntroductionContent($r('app.string.product'))
        this.IntroductionContent($r('app.string.play'))
      }
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row() {
        ForEach(this.iconList, (item: Resource) => {
          Image(item)
            .height('24vp')
            .width('24vp')
        }, (item: Resource, index: number) => index + JSON.stringify(item))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: '12vp',
        bottom: '12vp',
        left: '24vp',
        right: '24vp'
      })
      .height('48vp')
      .width('100%')

      this.SubTitle($r('app.string.anthology'))

      List({ space: '12vp' }) {
        ForEach(this.episodes, (item: string, index: number) => {
          ListItem() {
            Row() {
              Image($r('app.media.video_playing'))
                .height('10vp')
                .width('10vp')
                .position({ x: '8vp', y: '36vp' })
                .visibility((index + 1) === this.currentIndex ? Visibility.Visible : Visibility.None)

              Text(item)
                .fontSize('18fp')
                .fontWeight(FontWeight.Normal)
                .height('24vp')
                .fontColor((index + 1) === this.currentIndex ? '#ED6F21' : Color.Black)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.episodes_background'))
            .height('54vp')
            .width('68vp')
            .borderRadius(8)
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .padding({ left: '24vp' })
      .margin({ bottom: '12vp' })
      .width('100%')

      this.SubTitleAndMore($r('app.string.Peripheral'))

      List({ space: '12vp' }) {
        ForEach(this.peripheralVideoList, (item: RelatedVideoItemViewModel) => {
          ListItem() {
            Column() {
              Image(item.getImageSrc())
                .height('230vp')
                .width('164vp')
                .margin({ bottom: '4vp' })
                .borderRadius(16)

              Text(item.getName())
                .lineHeight('19vp')
                .fontSize('14fp')
                .opacity(0.6)
                .fontWeight(500)
            }
          }
        }, (item: RelatedVideoItemViewModel, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .margin({ top: '12vp' })
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .visibility(this.breakpointFlags().isWidthBpAboveMdAndHeightBpBelowLg ? Visibility.Visible : Visibility.None)
  }

  @Builder
  SubTitle(subtitle: ResourceStr) {
    Row() {
      Text(subtitle)
        .fontSize('16fp')
        .lineHeight('22vp')
        .fontWeight(500)
    }
    .padding({
      left: '24vp',
      right: '24vp'
    })
    .height('48vp')
    .width('100%')
  }

  @Builder
  SubTitleAndMore(subtitle: ResourceStr) {
    Row() {
      Text(subtitle)
        .fontSize('16fp')
        .lineHeight('22vp')
        .fontWeight(500)
      Blank()
      Text($r('app.string.more'))
        .fontSize('14fp')
        .lineHeight('19vp')
        .fontWeight(FontWeight.Normal)
        .opacity($r('app.string.more'))
      Image($r('app.media.ic_public_arrow_right'))
        .height('24vp')
        .width('24vp')
    }
    .padding({
      left: '24vp',
      right: '24vp'
    })
    .height('48vp')
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  IntroductionContent(content: ResourceStr) {
    Text(content)
      .fontSize('14fp')
      .lineHeight('28vp')
      .fontWeight(500)
      .opacity(0.6)
  }
}