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

import { BreakpointConstants } from '@ohos/commons';
import { SearchVideoImgModel, SearchVideoImg } from '../model/SearchVideoImgModel';

export class SearchVideoItemViewModel {
  private source: SearchVideoImg;

  constructor(source: SearchVideoImg) {
    this.source = source;
  }

  getImgSrc(): Resource {
    return this.source.getImgSrc();
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
}

export class SearchVideoImgViewModel {
  private model: SearchVideoImgModel = new SearchVideoImgModel();

  private toViewModels(items: SearchVideoImg[]): SearchVideoItemViewModel[] {
    return items.map((item) => new SearchVideoItemViewModel(item));
  }

  getTrendSearchList(currentWidthBreakpoint: string): SearchVideoItemViewModel[] {
    const fullList = this.model.getTrendingSearchList();
    if (currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      return this.toViewModels(fullList.slice(0, 5));
    } else if (currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      return this.toViewModels(fullList.slice(0, 10));
    } else {
      return this.toViewModels(fullList);
    }
  }

  getSearchResultImgList(): SearchVideoItemViewModel[] {
    return this.toViewModels(this.model.getSearchResultImgList());
  }

  getDiscoverSearchList(): SearchVideoItemViewModel[] {
    return this.toViewModels(this.model.getDiscoverSearchList());
  }

  getHotSearchList(): SearchVideoItemViewModel[] {
    return this.toViewModels(this.model.getHotSearchList());
  }

  getSearchResultList(): SearchVideoItemViewModel[] {
    return this.toViewModels(this.model.getSearchResultList());
  }
}