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

import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { StartOptions, AbilityConstant, Want, common } from '@kit.AbilityKit';
import Logger from './Logger';

const TAG = '[WindowUtil]';

export enum ImmersiveType {
  NORMAL,
  IMMERSIVE,
  FULLSCREEN_IMMERSIVE
}

export class WindowUtil {
  public uiContext?: UIContext;
  public mainWindow: window.Window;
  public mainWindowInfo: WindowInfo = new WindowInfo();
  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    this.mainWindowInfo.windowStatusType = statusType;
  }
  public onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.mainWindowInfo.windowSize = windowSize;
    if (this.uiContext !== undefined) {
      this.mainWindowInfo.widthBp = this.uiContext.getWindowWidthBreakpoint();
      this.mainWindowInfo.heightBp = this.uiContext.getWindowHeightBreakpoint();
    }
  };
  public onAvoidAreaChange: (avoidOptions: window.AvoidAreaOptions) => void =
    (avoidOptions: window.AvoidAreaOptions) => {
      if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        this.mainWindowInfo.avoidSystem = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_CUTOUT) {
        this.mainWindowInfo.avoidCutout = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
        this.mainWindowInfo.avoidSystemGesture = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_KEYBOARD) {
        this.mainWindowInfo.avoidKeyboard = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        this.mainWindowInfo.avoidNavigationIndicator = avoidOptions.area;
      } else {
        return;
      }
    };

  constructor(mainWindow: window.Window) {
    this.mainWindow = mainWindow;
  }

  setImmersiveType(type: ImmersiveType) {
    try {
      if (type === ImmersiveType.NORMAL) {
        this.mainWindow.setWindowLayoutFullScreen(false)
          .then(() => {
            Logger.info(TAG, `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, `Failed to set immersive mode. errCode = ${err.code}, errMessage = ${err.message}.`);
          });
        this.setSystemBarEnabled(true);
        // Only used after the function loadContent() or setUIContent().
        this.mainWindow.setWindowDecorVisible(true);
        this.recover();
      } else if (type === ImmersiveType.IMMERSIVE) {
        this.mainWindow.setWindowLayoutFullScreen(true)
          .then(() => {
            Logger.info(TAG, `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, `Failed to set immersive mode. errCode = ${err.code}, errMessage = ${err.message}.`);
          });
        this.setSystemBarEnabled(true);
        this.mainWindow.setWindowDecorVisible(false);
        this.recover();
      } else if (type === ImmersiveType.FULLSCREEN_IMMERSIVE) {
        this.mainWindow.setWindowLayoutFullScreen(true)
          .then(() => {
            Logger.info(TAG, `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, `Failed to set immersive mode. errCode = ${err.code}, errMessage = ${err.message}.`);
          });
        if (this.mainWindow.getWindowStatus() === window.WindowStatusType.MAXIMIZE ||
          (this.mainWindow.getWindowStatus() === window.WindowStatusType.FLOATING &&
            this.mainWindow.getWindowDecorHeight() !== 0)) {
          this.mainWindow.maximize()
            .then(() => {
              Logger.info(TAG, `Succeeded in maximizing the window.`);
            })
            .catch((err: BusinessError) => {
              Logger.error(TAG, `Failed to maximize the window. errCode = ${err.code}, errMessage = ${err.message}.`);
            });
        }
        this.setSystemBarEnabled(false);
        this.mainWindow.setWindowDecorVisible(false);
      }
      this.mainWindowInfo.isImmersive = type;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to set immersive type. errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  setUIContext() {
    try {
      this.uiContext = this.mainWindow.getUIContext();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to set UI context. errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  setSystemBarEnabled(isVisible: boolean): void {
    this.mainWindow.setSpecificSystemBarEnabled('status', isVisible)
      .then(() => {
        Logger.info(TAG, `Succeeded in setting status bar to be invisible.`);
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to set status bar to be invisible. errCode = ${err.code}, errMessage = ${err.message}.`);
      });
    this.mainWindow.setSpecificSystemBarEnabled('navigationIndicator', isVisible)
      .then(() => {
        Logger.info(TAG, `Succeeded in setting navigation indicator to be invisible.`);
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to set navigation indicator to be invisible. errCode = ${err.code}, errMessage = ${err.message}.`);
      });
  }

  recover(): void {
    try {
      if (this.mainWindow.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
        this.mainWindow.recover()
          .then(() => {
            Logger.info(TAG, `Succeeded in recovering the window.`);
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, `Failed to recover the window. errCode = ${err.code}, errMessage = ${err.message}.`);
          });
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to recover. errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  setWindowOrientation(orientation: window.Orientation): void {
    this.mainWindow.setPreferredOrientation(orientation)
      .then(() => {
        Logger.info(TAG, `Succeeded in setting window orientation.`);
        // Update window orientation.
        this.mainWindowInfo.orientation = orientation;
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to set window orientation. errCode = ${err.code}, errMessage = ${err.message}.`);
      });
  }

  updateWindowInfo(): void {
    try {
      // First time get window status.
      this.mainWindowInfo.windowStatusType = this.mainWindow.getWindowStatus();
      this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);
      // First time get window size.
      let width: number = this.mainWindow.getWindowProperties().windowRect.width;
      let height: number = this.mainWindow.getWindowProperties().windowRect.height;
      let windowSize: window.Size = {
        width: width,
        height: height
      }
      this.mainWindowInfo.windowSize = windowSize;
      // First time get width/height breakpoint.
      if (this.uiContext !== undefined) {
        this.mainWindowInfo.widthBp = this.uiContext.getWindowWidthBreakpoint();
        this.mainWindowInfo.heightBp = this.uiContext.getWindowHeightBreakpoint();
      }
      // Register for window size change monitoring, update window size and width/height breakpoint.
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);

      // First time get avoid area infos.
      this.mainWindowInfo.avoidSystem = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.mainWindowInfo.avoidNavigationIndicator =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.mainWindowInfo.avoidCutout = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
      this.mainWindowInfo.avoidSystemGesture =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
      this.mainWindowInfo.avoidKeyboard = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to update window info. errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  release(): void {
    try {
      this.mainWindow.off('windowStatusChange', this.onStatusTypeChange);
      this.mainWindow.off('windowSizeChange', this.onWindowSizeChange);
      this.mainWindow.off('avoidAreaChange', this.onAvoidAreaChange);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to off. errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  setSplitScreen(bundleName: string, abilityName: string, moduleName: string): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    // Create StartOptions and set them to the main window mode.
    let option: StartOptions = { windowMode: AbilityConstant.WindowMode.WINDOW_MODE_SPLIT_PRIMARY };
    let want: Want = { bundleName: bundleName, abilityName: abilityName, moduleName: moduleName };
    context.startAbility(want, option).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to start ability. errCode = ${err.code}, errMessage = ${err.message}.`);
    });
  }

  cancelSplitScreen(): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    context.terminateSelf().catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to terminate self. errCode = ${err.code}, errMessage = ${err.message}.`);
    });
  }

  setWindowLimits(maxWidth: number, maxHeight: number, minWidth: number, minHeight: number): void {
    let windowLimits: window.WindowLimits = {
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      minHeight: minHeight
    }
    this.mainWindow.setWindowLimits(windowLimits).then((data: window.WindowLimits) => {
      Logger.info(TAG, `Succeeded in changing the window limits. Cause: ${JSON.stringify(data)}.`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to change the window limits. errCode = ${err.code}, errMessage = ${err.message}.`);
    });
  }

  resize(width: number, height: number): void {
    this.mainWindow.resize(width, height, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        Logger.error(TAG, `Failed to change the window size. errCode = ${err.code}, errMessage = ${err.message}.`);
        return;
      }
      Logger.info(TAG, `Succeeded in changing the window size.`);
    });
  }

  /**
   * Calculate the rotation angle of the device within the screen plane.
   */
  getCalDegree(x: number, y: number, z: number): number {
    let degree: number = 0;
    // three is Effective Delta Angle Threshold Coefficient.
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }
}

@Observed
export class WindowInfo {
  // Window status.
  public windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;
  // Is the window an immersive layout.
  public isImmersive: ImmersiveType = ImmersiveType.NORMAL;
  // Window orientation.
  public orientation: window.Orientation = window.Orientation.UNSPECIFIED;
  // Window size.
  public windowSize: window.Size = { width: 0, height: 0 };
  // Width/height breakpoint.
  public widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  public heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  // Avoid area infos.
  public avoidSystem?: window.AvoidArea;
  public avoidNavigationIndicator?: window.AvoidArea;
  public avoidCutout?: window.AvoidArea;
  public avoidSystemGesture?: window.AvoidArea;
  public avoidKeyboard?: window.AvoidArea;
}
