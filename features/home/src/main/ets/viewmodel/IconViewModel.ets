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

import { IconModel, VideoIcon } from '../model/IconModel';

export class VideoIconItemViewModel {
  private source: VideoIcon;

  constructor(source: VideoIcon) {
    this.source = source;
  }

  getName(): ResourceStr {
    return this.source.getName();
  }

  getImage(): Resource {
    return this.source.getImage();
  }
}

export class IconViewModel {
  private model: IconModel = new IconModel();

  getIconList(): VideoIconItemViewModel[] {
    return this.model.getIconList().map((item) => new VideoIconItemViewModel(item));
  }
}