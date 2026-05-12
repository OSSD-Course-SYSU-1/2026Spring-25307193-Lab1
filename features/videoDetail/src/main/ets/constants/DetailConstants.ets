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

export class DetailConstants {
  /**
   * Maximum height of self comment bar.
   */
  public static readonly SELF_COMMENT_MAX_HEIGHT: number = 64;
  /**
   * Scroll offset threshold to hide self comment bar.
   */
  public static readonly SELF_COMMENT_SCROLL_HIDE_THRESHOLD: number = 100;
  /**
   * Initial comment image height.
   */
  public static readonly INITIAL_COMMENT_IMAGE_HEIGHT: string = '204vp';
  /**
   * Initial comment image width.
   */
  public static readonly INITIAL_COMMENT_IMAGE_WIDTH: string = '299vp';
  /**
   * XSmall comment image height.
   */
  public static readonly XSMALL_COMMENT_IMAGE_HEIGHT: string = '227vp';
  /**
   * XSmall comment image width.
   */
  public static readonly XSMALL_COMMENT_IMAGE_WIDTH: string = '227vp';
  /**
   * Small comment image height.
   */
  public static readonly SMALL_COMMENT_IMAGE_HEIGHT: string = '227vp';
  /**
   * Small comment image width.
   */
  public static readonly SMALL_COMMENT_IMAGE_WIDTH: string = '227vp';
  /**
   * Medium comment image height.
   */
  public static readonly MEDIUM_COMMENT_IMAGE_HEIGHT: string = '254vp';
  /**
   * Medium comment image width.
   */
  public static readonly MEDIUM_COMMENT_IMAGE_WIDTH: string = '254vp';
  /**
   * Initial related video height.
   */
  public static readonly INITIAL_RELATED_VIDEO_HEIGHT: number = 169;
  /**
   * Initial related video height.
   */
  public static readonly INITIAL_VIDEO_HEIGHT: number = 100;
  /**
   * Comment image min height number.
   */
  public static readonly COMMENT_IMAGE_MIN_HEIGHT_NUMBER: number = 204;
  /**
   * Comment image max height number.
   */
  public static readonly COMMENT_IMAGE_MAX_HEIGHT_NUMBER: number = 236;
  /**
   * Comment image min width number.
   */
  public static readonly COMMENT_IMAGE_MIN_WIDTH_NUMBER: number = 299;
  /**
   * Comment image max width number.
   */
  public static readonly COMMENT_IMAGE_MAX_WIDTH_NUMBER: number = 346;
  /**
   * Side bar min width number.
   */
  public static readonly SIDE_BAR_MIN_WIDTH_NUMBER: number = 400;
  /**
   * Side bar width ratio.
   */
  public static readonly SIDE_BAR_WIDTH_RATIO: number = 0.4;
  /**
   * Offset for scrolling to top.
   */
  public static readonly SCROLL_TO_TOP: string = '{"xOffset":0,"yOffset":0}';
  /**
   * Sub title list.
   */
  public static readonly SUB_TITLES: ResourceStr[] =
    [$r('app.string.comments'), $r('app.string.related'), $r('app.string.more'), $r('app.string.introduction'),
      $r('app.string.anthology'), $r('app.string.Peripheral')];
  /**
   * Length unit.
   */
  public static readonly LENGTH_UNIT: string = 'vp';
  /**
   * Icon list.
   */
  public static readonly ICON_LIST: Resource[] = [$r('app.media.heart'), $r('app.media.ellipsis_message'),
    $r('app.media.hand_thumbsup'), $r('app.media.arrow_down'), $r('app.media.arrowshape_turn_up_right')];
  /**
   * Shadow radius.
   */
  public static readonly SHADOW_RADIUS: number = 50;
  /**
   * Shadow offset y.
   */
  public static readonly SHADOW_OFFSET_Y: number = 10;
  /**
   * Related video title list.
   */
  public static readonly RELATED_VIDEO_TITLES: ResourceStr[] =
    [$r('app.string.released'), $r('app.string.released'), $r('app.string.released'),
      $r('app.string.released'), $r('app.string.released'), $r('app.string.released'), $r('app.string.released')];
  /**
   * Peripheral video title list.
   */
  public static readonly PERIPHERAL_VIDEO_TITLE: ResourceStr[] = [$r('app.string.series'), $r('app.string.series'),
    $r('app.string.series'), $r('app.string.series'), $r('app.string.series')];
  /**
   * User info name list.
   */
  public static readonly USER_INFO_NAMES: string[] = ['m******', 'H******', 'BEI***'];
  /**
   * User info comment list.
   */
  public static readonly USER_INFO_COMMENTS: ResourceStr[] = [
    $r('app.string.feel'),
    $r('app.string.love'),
    $r('app.string.design')
  ];
  /**
   * User info date.
   */
  public static readonly USER_INFO_DATE: ResourceStr = $r('app.string.July');
  /**
   * Placeholder of comment text input.
   */
  public static readonly COMMENT_PLACEHOLDER: ResourceStr = $r('app.string.comment');
  /**
   * Min video percent.
   */
  public static readonly MIN_VIDEO_PERCENT: number = 53;
  /**
   * Max video percent.
   */
  public static readonly MAX_VIDEO_PERCENT: number = 100;
  /**
   * Ten.
   */
  public static readonly TEN: number = 10;
  /**
   * Related list height.
   */
  public static readonly RELATED_LIST_HEIGHT: number = 169;
  /**
   * Player text list.
   */
  public static readonly PLAYER_TEXT_LIST: ResourceStr[] = [$r('app.string.selections'), $r('app.string.just'),
    $r('app.string.super'), $r('app.string.speed')];
  /**
   * Episode list lanes list.
   */
  public static readonly EPISODE_LIST_LANES: number[] = [8, 5];
  /**
   * Episodes.
   */
  public static readonly PLAYER_EPISODE: string[] =
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
      '21', '22', '23', '24'];
  /**
   * Initial time.
   */
  public static readonly INITIAL_TIME: string = '00:00:00';
  /**
   * Playing state of avPlayer.
   */
  public static readonly AV_PLAYER_PLAYING_STATE: string = 'playing';
  /**
   * Page name for video.
   */
  public static readonly PAGE_NAME_FOR_VIDEO: string = 'videoDetail';
}