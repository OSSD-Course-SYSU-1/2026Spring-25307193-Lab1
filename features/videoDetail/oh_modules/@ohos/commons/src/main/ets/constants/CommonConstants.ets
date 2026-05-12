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

/**
 * Common constants for all features.
 */
export class CommonConstants {
  /**
   * Idle state of avPlayer.
   */
  public static readonly AV_PLAYER_IDLE_STATE: string = 'idle';

  /**
   * Initialized state of avPlayer.
   */
  public static readonly AV_PLAYER_INITIALIZED_STATE: string = 'initialized';

  /**
   * Prepared state of avPlayer.
   */
  public static readonly AV_PLAYER_PREPARED_STATE: string = 'prepared';

  /**
   * Playing state of avPlayer.
   */
  public static readonly AV_PLAYER_PLAYING_STATE: string = 'playing';

  /**
   * Pause state of avPlayer.
   */
  public static readonly AV_PLAYER_PAUSED_STATE: string = 'paused';

  /**
   * Completed state of avPlayer.
   */
  public static readonly AV_PLAYER_COMPLETED_STATE: string = 'completed';

  /**
   * Stopped state of avPlayer.
   */
  public static readonly AV_PLAYER_STOPPED_STATE: string = 'stopped';

  /**
   * Release state of avPlayer.
   */
  public static readonly AV_PLAYER_RELEASE_STATE: string = 'released';

  /**
   * Error state of avPlayer.
   */
  public static readonly AV_PLAYER_ERROR_STATE: string = 'error';

  /**
   * Product video name.
   */
  public static readonly PRODUCT_VIDEO_NAME: string = 'product.mp4';

  /**
   * List space.
   */
  public static readonly LIST_SPACE: string = '12vp';

  /**
   * List space for TV.
   */
  public static readonly LIST_SPACE_FOR_TV: string = '24vp';

  /**
   * colon.
   */
  public static readonly COLON: string = ':';

  /**
   * Time prefix.
   */
  public static readonly TIME_PREFIX: string = '0';

  /**
   * Empty time.
   */
  public static readonly EMPTY_TIME: string = '00';

  /**
   * Window util.
   */
  public static readonly WINDOW_UTIL: string = 'windowUtil';

  /**
   * Full percent.
   */
  public static readonly FULL_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  public static readonly NINETY_PERCENT: string = '90%';

  /**
   * One hundred for progress.
   */
  public static readonly PROGRESS_HUNDRED: number = 100;

  /**
   * One thousand for progress.
   */
  public static readonly PROGRESS_THOUSAND: number = 1000;

  /**
   * Second in hour.
   */
  public static readonly SECOND_IN_HOUR: number = 3600;

  /**
   * Second in minute.
   */
  public static readonly SECOND_IN_MINUTE: number = 60;

  /**
   * Zero
   */
  public static readonly ZERO: number = 0;

  /**
   * One
   */
  public static readonly ONE: number = 1;

  /**
   * Two
   */
  public static readonly TWO: number = 2;

  /**
   * Three
   */
  public static readonly THREE: number = 3;

  /**
   * Four
   */
  public static readonly FOUR: number = 4;

  /**
   * Five
   */
  public static readonly FIVE: number = 5;

  /**
   * Six
   */
  public static readonly SIX: number = 6;

  /**
   * Seven
   */
  public static readonly SEVEN: number = 7;

  /**
   * Eight
   */
  public static readonly EIGHT: number = 8;

  /**
   * Nine
   */
  public static readonly NINE: number = 9;

  /**
   * Ten
   */
  public static readonly TEN: number = 10;

  /**
   * VP unit.
   */
  public static readonly VP_UNIT: string = 'vp';

  /**
   *  Constant for screen dpi.
   */
  public static readonly SCREEN_DPI_CONSTANT: number = 160;

  /**
   * Font weight 400.
   */
  public static readonly FONT_WEIGHT_400: number = 400;

  /**
   * Font weight 500.
   */
  public static readonly FONT_WEIGHT_500: number = 500;

  /**
   * Font weight 700.
   */
  public static readonly FONT_WEIGHT_700: number = 700;

  /**
   * Font family HarmonyHeiTi.
   */
  public static readonly FONT_HARMONY_HEITI: string = 'HarmonyHeiTi';

  /**
   * Text opacity.
   */
  public static readonly TEXT_OPACITY: number[] = [0.4, 0.5, 0.6, 1, 0.8, 0.9];

  /**
   * Divider opacity.
   */
  public static readonly DIVIDER_OPACITY: number = 0.05;

  /**
   * X component surface width.
   */
  public static readonly X_COMPONENT_SURFACE_WIDTH: number = 1920;

  /**
   * X component surface height.
   */
  public static readonly X_COMPONENT_SURFACE_HEIGHT: number = 1080;

  /**
   * Video aspect ratio.
   */
  public static readonly VIDEO_ASPECT_RATIO: number = 1.78;

  /**
   * Comment image aspect ratio.
   */
  public static readonly COMMENT_IMAGE_RATIO: number = 1.56;

  /**
   * Default window width.
   */
  public static readonly DEFAULT_WINDOW_WIDTH: number = 320;

  /**
   * Margin of window floating.
   */
  public static readonly WINDOW_FLOATING_MARGIN: number = 5.2;
}