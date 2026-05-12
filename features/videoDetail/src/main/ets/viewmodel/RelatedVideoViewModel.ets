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

import { RelatedVideoModel, RelatedVideo } from '../model/RelatedVideoModel';

export class RelatedVideoItemViewModel {
  private source: RelatedVideo;

  constructor(source: RelatedVideo) {
    this.source = source;
  }

  getName(): ResourceStr {
    return this.source.getName();
  }

  getImageSrc(): Resource {
    return this.source.getImageSrc();
  }
}

export class RelatedVideoViewModel {
  private model: RelatedVideoModel = new RelatedVideoModel();

  getRelatedVideoList(): RelatedVideoItemViewModel[] {
    return this.model.getRelatedVideoList().map((item) => new RelatedVideoItemViewModel(item));
  }

  getPeripheralVideoList(): RelatedVideoItemViewModel[] {
    return this.model.getPeripheralVideoList().map((item) => new RelatedVideoItemViewModel(item));
  }
}
