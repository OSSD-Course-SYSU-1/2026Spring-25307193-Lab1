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

import { SearchConstants } from '../constants/SearchConstants';

export class SearchKeyboardModel {
  private letterKeys: ResourceStr[] = [
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', SearchConstants.SEARCH_ACTION[0],
    'Z', 'X', 'C', 'V', 'B', 'N', 'M', SearchConstants.SEARCH_ACTION[1]
  ];
  private digitKeys: ResourceStr[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  getLetterKeys(): ResourceStr[] {
    return this.letterKeys;
  }

  getDigitKeys(): ResourceStr[] {
    return this.digitKeys;
  }
}
