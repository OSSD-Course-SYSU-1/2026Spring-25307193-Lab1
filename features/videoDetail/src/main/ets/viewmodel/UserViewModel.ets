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

import { UserModel, UserInfo } from '../model/UserModel';

export class UserInfoViewModel {
  private source: UserInfo;

  constructor(source: UserInfo) {
    this.source = source;
  }

  getName(): string {
    return this.source.getName();
  }

  getImageSrc(): Resource {
    return this.source.getImageSrc();
  }

  getComment(): ResourceStr {
    return this.source.getComment();
  }

  getCommentImageSrc(): Resource | undefined {
    return this.source.getCommentImageSrc();
  }

  getTime(): ResourceStr {
    return this.source.getTime();
  }
}

export class UserViewModel {
  private model: UserModel = new UserModel();

  getRelatedVideoList(): UserInfoViewModel[] {
    return this.model.getRelatedVideoList().map((item) => new UserInfoViewModel(item));
  }

  getSelfInfo(): UserInfoViewModel {
    return new UserInfoViewModel(this.model.getSelfInfo());
  }
}
