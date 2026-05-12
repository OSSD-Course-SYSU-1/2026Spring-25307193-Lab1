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

import { VideoImgModel, VideoImage } from '../model/VideoImgModel';

export class VideoImgItemViewModel {
  private source: VideoImage;

  constructor(source: VideoImage) {
    this.source = source;
  }

  getImgSrc(): Resource {
    return this.source.getImgSrc();
  }

  getRating(): string {
    return this.source.getRating();
  }

  getTitle(): ResourceStr {
    return this.source.getTitle();
  }

  getContent(): ResourceStr {
    return this.source.getContent();
  }

  getOtherInfo(): ResourceStr {
    return this.source.getOtherInfo();
  }

  getMemberShipTag(): Resource | ResourceStr {
    return this.source.getMemberShipTag();
  }
}

export class VideoImgViewModel {
  private model: VideoImgModel = new VideoImgModel();

  private toViewModels(items: VideoImage[]): VideoImgItemViewModel[] {
    return items.map((item) => new VideoImgItemViewModel(item));
  }

  getVideoImgList(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getVideoImgList());
  }

  getNewVideoImgList(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getNewVideoImgList());
  }

  getDailyVideoImgList(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getDailyVideoImgList());
  }

  getMainDailyVideoImg(): VideoImgItemViewModel {
    return new VideoImgItemViewModel(this.model.getMainDailyVideoImg());
  }

  getPreviousVideoOne(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getPreviousVideoOne());
  }

  getTVPreviousVideoOne(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getTVPreviousVideoOne());
  }

  getTVPreviousVideoImgListTwo(): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getTVPreviousVideoImgListTwo());
  }

  getPreviousVideoTwo(currentWidthBreakpoint: number): VideoImgItemViewModel[] {
    return this.toViewModels(this.model.getPreviousVideoTwo(currentWidthBreakpoint));
  }
}