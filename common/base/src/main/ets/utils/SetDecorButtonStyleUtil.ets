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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { WindowUtil } from './WindowUtil';

const TAG = '[SetDecorStyleUtil]';

export class SetDecorButtonStyleUtil {
  static setDecorButtonForImmersive(currentTopIndex: number, widthBp: WidthBreakpoint, pageInfo: NavPathStack,
    windowUtil: WindowUtil | undefined): void {
    try {
      if (currentTopIndex === 2 && widthBp === WidthBreakpoint.WIDTH_XL && pageInfo.getAllPathName().length === 0) {
        windowUtil?.mainWindow.setDecorButtonStyle({
          colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        });
      } else {
        windowUtil?.mainWindow.setDecorButtonStyle({
          colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
        });
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to setDecorButtonStyle, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  static setDecorButtonForNormal(windowUtil: WindowUtil | undefined): void {
    try {
      windowUtil?.mainWindow.setDecorButtonStyle({
        colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to setDecorButtonStyle, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }
}