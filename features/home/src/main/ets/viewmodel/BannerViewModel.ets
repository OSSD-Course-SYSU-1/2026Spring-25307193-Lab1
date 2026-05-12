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

import { BreakpointType } from '@ohos/commons';
import {
  Banner,
  BannerDescription,
  BannerImg,
  BannerModel,
  TVBanner
} from '../model/BannerModel';

export class BannerDescriptionItemViewModel {
  private source: BannerDescription;

  constructor(source: BannerDescription) {
    this.source = source;
  }

  getDescription(): ResourceStr[] {
    return this.source.getDescription();
  }

  getFontSize(): BreakpointType<Resource[]> {
    return this.source.getFontSize();
  }

  getFontWeight(): number[] {
    return this.source.getFontWeight();
  }

  getLineHeight(): BreakpointType<Resource[]> {
    return this.source.getLineHeight();
  }

  getLeftPosition(): BreakpointType<string[]> {
    return this.source.getLeftPosition();
  }

  getTopPosition(): BreakpointType<string[]> {
    return this.source.getTopPosition();
  }

  getIsLeftCenter(): BreakpointType<boolean> {
    return this.source.getIsLeftCenter();
  }

  getIsTopCenter(): BreakpointType<boolean> {
    return this.source.getIsTopCenter();
  }
}

export class BannerImgItemViewModel {
  private source: BannerImg;

  constructor(source: BannerImg) {
    this.source = source;
  }

  getImgSrc(): Resource {
    return this.source.getImgSrc();
  }

  getImgSrcSm(): Resource {
    return this.source.getImgSrcSm();
  }

  getHeight(): BreakpointType<Resource> {
    return this.source.getHeight();
  }
}

export class BannerItemViewModel {
  private source: Banner;

  constructor(source: Banner) {
    this.source = source;
  }

  getBannerImg(): BannerImgItemViewModel {
    return new BannerImgItemViewModel(this.source.getBannerImg());
  }

  getDescription(): BannerDescriptionItemViewModel {
    return new BannerDescriptionItemViewModel(this.source.getDescription());
  }
}

export class TVBannerItemViewModel {
  public readonly imgHorizontal: Resource;
  public readonly imgVertical: Resource;
  public readonly title: Resource;

  constructor(source: TVBanner) {
    this.imgHorizontal = source.imgHorizontal;
    this.imgVertical = source.imgVertical;
    this.title = source.title;
  }
}

export class BannerViewModel {
  private model: BannerModel = new BannerModel();

  private toBannerItemViewModels(items: Banner[]): BannerItemViewModel[] {
    return items.map((item) => new BannerItemViewModel(item));
  }

  private toTVBannerItemViewModels(items: TVBanner[]): TVBannerItemViewModel[] {
    return items.map((item) => new TVBannerItemViewModel(item));
  }

  getBannerList(): BannerItemViewModel[] {
    return this.toBannerItemViewModels(this.model.getBannerList());
  }

  getTVBannerList(): TVBannerItemViewModel[] {
    return this.toTVBannerItemViewModels(this.model.getTVBannerList());
  }

  getTVBannerScaleList(): Array<ScaleOptions> {
    return this.model.getTVBannerScaleList();
  }
}
