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
 * Constants for home feature including UI strings, layout values, and AVPlayer states.
 */
export class HomeConstants {
  /**
   * Top tab topics.
   */
  public static readonly TOP_TOPIC_LIST: ResourceStr[] =
    [$r('app.string.sift'), $r('app.string.home_video'), $r('app.string.community'), $r('app.string.news'),
      $r('app.string.shop'), $r('app.string.science'), $r('app.string.finance'), $r('app.string.history'),
      $r('app.string.affairs')];
  /**
   * Icon list.
   */
  public static readonly ICON_LIST: ResourceStr[] =
    [$r('app.string.home_all'), $r('app.string.heat_list'), $r('app.string.free'), $r('app.string.sutra'),
      $r('app.string.prefecture'), $r('app.string.kids_only'), $r('app.string.zone'), $r('app.string.Premium_products'),
      $r('app.string.Fitness')];
  /**
   * Banner text 1.
   */
  public static readonly BANNER_TEXT_1: ResourceStr[] = ['HUAWEI ', 'Mate Book ', $r('app.string.new')];
  /**
   * Banner text 2.
   */
  public static readonly BANNER_TEXT_2: ResourceStr[] = ['HUAWEI ', '', $r('app.string.new')];
  /**
   * Banner text 3.
   */
  public static readonly BANNER_TEXT_3: ResourceStr[] = ['HUAWEI P60 ', '', $r('app.string.new')];
  /**
   * Banner text 4.
   */
  public static readonly BANNER_TEXT_4: ResourceStr[] = ['HUAWEI P50', '', $r('app.string.new')];
  /**
   * Video grid rate list.
   */
  public static readonly VIDEO_GRID_RATES: string[] =
    ['7.8', '8.0', '7.9', '8.4', '7.8', '8.0', '7.9', '8.4', '7.6', '8.0'];
  /**
   * Video grid name list.
   */
  public static readonly VIDEO_GRID_NAMES: ResourceStr[] =
    [$r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'),
      $r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'),
      $r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'),
      $r('app.string.home_cultural')];
  /**
   * Video grid content list.
   */
  public static readonly VIDEO_GRID_CONTENTS: ResourceStr[] =
    [$r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe'),
      $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe'),
      $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe'),
      $r('app.string.home_europe')];
  /**
   * New video grid rate list.
   */
  public static readonly NEW_VIDEO_RATES: string[] = ['', '', '7.9', '7.9', '7.9', '7.9', '7.9'];
  /**
   * New video name list.
   */
  public static readonly NEW_VIDEO_NAMES: ResourceStr[] =
    [$r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely'),
      $r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely')];
  /**
   * New video content list.
   */
  public static readonly NEW_VIDEO_CONTENTS: ResourceStr[] =
    [$r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape'),
      $r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape')];
  /**
   * Main daily video rate.
   */
  public static readonly MAIN_DAILY_VIDEO_RATE: string = '8.4';
  /**
   * Main daily video name.
   */
  public static readonly MAIN_DAILY_VIDEO_NAME: ResourceStr = $r('app.string.explore');
  /**
   * Main daily video content.
   */
  public static readonly MAIN_DAILY_VIDEO_CONTENT: ResourceStr = $r('app.string.source');
  /**
   * Main daily video more info.
   */
  public static readonly MAIN_DAILY_VIDEO_MORE: ResourceStr = $r('app.string.source');
  /**
   * Daily video rate list.
   */
  public static readonly DAILY_VIDEO_RATES: string[] = ['8.4', '8.4', '8.4', '8.4'];
  /**
   * Daily video name list.
   */
  public static readonly DAILY_VIDEO_NAMES: ResourceStr[] =
    [$r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely')];
  /**
   * Daily video name list.
   */
  public static readonly DAILY_VIDEO_CONTENTS: ResourceStr[] = [$r('app.string.source'), $r('app.string.source'),
    $r('app.string.source'), $r('app.string.source')];
  /**
   * Previous video name list one.
   */
  public static readonly PREVIOUS_VIDEO_NAMES_ONE: ResourceStr[] = [$r('app.string.life'), $r('app.string.life'),
    $r('app.string.life')];
  /**
   * Previous video content list one.
   */
  public static readonly PREVIOUS_VIDEO_CONTENTS_ONE: ResourceStr[] =
    [$r('app.string.film'), $r('app.string.film'), $r('app.string.film')];
  /**
   * Previous video more info list one.
   */
  public static readonly PREVIOUS_VIDEO_MORE_ONE: ResourceStr[] =
    [$r('app.string.home_plays'), $r('app.string.home_plays'), $r('app.string.home_plays')];
  /**
   * Previous video name list two.
   */
  public static readonly PREVIOUS_VIDEO_NAMES_TWO: ResourceStr[] =
    [$r('app.string.life'), $r('app.string.life'), $r('app.string.life'),
      $r('app.string.life'), $r('app.string.life'), $r('app.string.life')];
  /**
   * Previous video content list two.
   */
  public static readonly PREVIOUS_VIDEO_CONTENTS_TWO: ResourceStr[] =
    [$r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe'),
      $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe')];
  /**
   * Home sub title list.
   */
  public static readonly HOME_SUB_TITLES: ResourceStr[] =
    [$r('app.string.release'), $r('app.string.tablet'), $r('app.string.back')];
  /**
   * New video rows template.
   */
  public static readonly NEW_VIDEO_ROWS_TEMPLATE: string = '1fr';
  /**
   * Main daily video button text.
   */
  public static readonly HOME_BUTTON_TEXT: ResourceStr[] =
    [$r('app.string.follow'), $r('app.string.play_on'), $r('app.string.home_player'), $r('app.string.home_cache')];
  /**
   * Search placeholder.
   */
  public static readonly SEARCH_PLACEHOLDER: ResourceStr = $r('app.string.search');
  /**
   * Video dialog option list.
   */
  public static readonly VIDEO_DIALOG_OPTIONS: ResourceStr[] = [$r('app.string.binge_watch'), $r('app.string.Collect'), $r('app.string.like')];
  /**
   * Product video file name for preview.
   */
  public static readonly PRODUCT_VIDEO_NAME: string = 'product.mp4';
  /**
   * Height unit.
   */
  public static readonly HEIGHT_UNIT: string = 'vp';
  /**
   * Two.
   */
  public static readonly TWO: number = 2;
  /**
   * Five.
   */
  public static readonly FIVE: number = 5;
  /**
   * Six.
   */
  public static readonly SIX: number = 6;
  /**
   * Seven.
   */
  public static readonly SEVEN: number = 7;
  /**
   * Eight.
   */
  public static readonly EIGHT: number = 8;
  /**
   * Three.
   */
  public static readonly THREE: number = 3;
  /**
   * Four.
   */
  public static readonly FOUR: number = 4;
  /**
   * Half of icon image size for icon list spacing calculation (icon_img_size 40vp / 2).
   */
  public static readonly ICON_IMG_HALF_SIZE: number = 20;
  /**
   * Numerator of banner grid width ratio (4/11).
   */
  public static readonly BANNER_GRID_WIDTH_RATIO_NUMERATOR: number = 4;
  /**
   * Denominator of banner grid width ratio (4/11).
   */
  public static readonly BANNER_GRID_WIDTH_RATIO_DENOMINATOR: number = 11;
  /**
   * Banner image aspect ratio for large breakpoint.
   */
  public static readonly BANNER_IMG_ASPECT_RATIO_LG: number = 1.5;
  /**
   * Banner image aspect ratio for extra large breakpoint.
   */
  public static readonly BANNER_IMG_ASPECT_RATIO_XL: number = 1.8;
  /**
   * Double gap between banner images in grid (12 * 2).
   */
  public static readonly BANNER_GRID_GAP_DOUBLE: number = 24;
  /**
   * Daily video grid column count (main + sub section).
   */
  public static readonly DAILY_VIDEO_GRID_COLUMN_COUNT: number = 2;
  /**
   * Daily video grid column count for small breakpoint (single column).
   */
  public static readonly DAILY_VIDEO_GRID_COLUMN_COUNT_SM: number = 1;
  /**
   * Video grid row count for height calculation.
   */
  public static readonly VIDEO_GRID_ROW_COUNT: number = 2;
  /**
   * Number of gaps between two columns in video grid.
   */
  public static readonly VIDEO_GRID_GAP_COUNT_TWO_COLUMNS: number = 1;
  /**
   * Number of gaps between three columns in video grid.
   */
  public static readonly VIDEO_GRID_GAP_COUNT_THREE_COLUMNS: number = 2;
  /**
   * Number of gaps between four columns in video grid.
   */
  public static readonly VIDEO_GRID_GAP_COUNT_FOUR_COLUMNS: number = 3;
  /**
   * Number of gaps between five columns in video grid.
   */
  public static readonly VIDEO_GRID_GAP_COUNT_FIVE_COLUMNS: number = 4;
  /**
   * Previous one row aspect ratio.
   */
  public static readonly PREVIOUS_ONE_ROW_RATIO: number = 1.56;
  /**
   * Video grid column list.
   */
  public static readonly VIDEO_GRID_COLUMNS: string[] =
    ['1fr 1fr', '1fr 1fr 1fr', '1fr 1fr 1fr 1fr', '1fr 1fr 1fr 1fr 1fr',
      '1fr 1fr 1fr 1fr 1fr 1fr 1fr'];
  /**
   * Video dialog height list.
   */
  public static readonly VIDEO_DIALOG_HEIGHTS: number[] = [161, 268, 347];
  /**
   * Video dialog aspect ratio.
   */
  public static readonly VIDEO_DIALOG_ASPECT_RATIO: number = 1.74;
  /**
   * Home header background change height.
   */
  public static readonly BACKGROUND_CHANGE_HEIGHT: number[] = [27, 34, 56, 0];
  /**
   * Video grid item space.
   */
  public static readonly VIDEO_GRID_ITEM_SPACE: number = 12;
  /**
   * Video grid margin.
   */
  public static readonly VIDEO_GRID_MARGIN: number[] = [32, 48, 64, 80];
  /**
   * Lg sidebar width.
   */
  public static readonly LG_SIDEBAR_WIDTH: number = 96;
  /**
   * Lg sidebar width.
   */
  public static readonly XL_SIDEBAR_WIDTH: number = 260;
  /**
   * Video grid description height.
   */
  public static readonly VIDEO_GRID_DESCRIPTION_HEIGHT: number = 120;
  /**
   * New video aspect ratio.
   */
  public static readonly NEW_VIDEO_ASPECT_RATIO: number = 0.72;
  /**
   * New video description height.
   */
  public static readonly NEW_VIDEO_DESCRIPTION_HEIGHT: number = 71;
  /**
   * Daily video description height.
   */
  public static readonly DAILY_VIDEO_DESCRIPTION_HEIGHT: number[] = [103, 88, 115, 62];
  /**
   * Previous two ratio list.
   */
  public static readonly PREVIOUS_TWO_RATIOS: number[] = [0.76, 0.89, 0.86, 0.74, 0.8, 0.9, 0.83];
  /**
   * Home header height for sm.
   */
  public static readonly HOME_HEADER_HEIGHT_SM: number = 112;
  /**
   * Window undefined top.
   */
  public static readonly WINDOW_UNDEFINED_TOP: number = 39;
  /**
   * Window undefined left.
   */
  public static readonly WINDOW_UNDEFINED_LEFT: number = 5;
  /**
   * Banner text 1 left position for md.
   */
  public static readonly BANNER_TEXT_1_LEFT_MD: string = '8%';
  /**
   * Banner text 2 left position for md.
   */
  public static readonly BANNER_TEXT_2_LEFT_MD: string = '8%';
  /**
   * Banner text 2 left position for lg.
   */
  public static readonly BANNER_TEXT_2_LEFT_LG: string = '5%';
  /**
   * Banner text 1 top position for sm.
   */
  public static readonly BANNER_TEXT_1_TOP_SM: string[] = ['15%', '2vp'];
  /**
   * Banner text 1 top position for md.
   */
  public static readonly BANNER_TEXT_1_TOP_MD: string[] = ['8%', '4vp'];
  /**
   * Banner text 1 top position for lg.
   */
  public static readonly BANNER_TEXT_1_TOP_LG: string[] = ['5%', '2vp'];
  /**
   * Banner text 2 top position for sm.
   */
  public static readonly BANNER_TEXT_2_TOP_SM: string[] = ['15%', '2vp'];
  /**
   * Banner text 2 top position for md.
   */
  public static readonly BANNER_TEXT_2_TOP_MD: string[] = ['10%', '4vp'];
  /**
   * Banner text 2 top position for lg.
   */
  public static readonly BANNER_TEXT_2_TOP_LG: string[] = ['10%', '8vp'];
  /**
   * Direction list.
   */
  public static readonly DIRECTION_LIST: string[] = ['BottomTabs', 'TopTabs', 'Banner', 'IconList', 'RecommendedVideo',
    'NewRelease', 'DailyVideoOne', 'DailyVideoTwo', 'PreviousVideo'];
  /**
   * Item width of IconView.
   */
  public static readonly ICONVIEW_ITEM_WIDTH: number[] = [40, 43, 45, 56];
  /**
   * Top bar height for normal breakpoint.
   */
  public static readonly TOP_BAR_HEIGHT: number = 64;
  /**
   * Bottom tab bar height.
   */
  public static readonly BOTTOM_TAB_BAR_HEIGHT: number = 76;
  /**
   * Bottom tab bar height for small.
   */
  public static readonly BOTTOM_TAB_BAR_HEIGHT_SM: number = 56;
  /**
   * Scroll offset threshold (px) at which top/bottom bar becomes fully hidden.
   */
  public static readonly SCROLL_BAR_HIDE_THRESHOLD: number = 100;
  /**
   * Duration (ms) for bar restore animation when scroll direction reverses.
   */
  public static readonly BAR_RESTORE_ANIMATION_DURATION: number = 300;
  /**
   * Decor button icon size.
   */
  public static readonly DECOR_BUTTON_ICON_SIZE: number = 24;
  /**
   * Decor window height.
   */
  public static readonly DECOR_WINDOW_HEIGHT: number = 64;
  /**
   * TV Banner Image count
   * */
  public static readonly TV_BANNER_IMAGE_COUNT: number = 5;
  /**
   * TV banner card default height (center position).
   */
  public static readonly TV_BANNER_CARD_HEIGHT_CENTER: number = 300;
  /**
   * TV banner card default width.
   */
  public static readonly TV_BANNER_CARD_WIDTH: number = 256;
  /**
   * TV banner card target heights for each position [left2, left1, center, right1, right2].
   */
  public static readonly TV_BANNER_CARD_TARGET_HEIGHTS: number[] = [216, 254, 300, 254, 216];
  /**
   * TV banner margin top.
   */
  public static readonly TV_BANNER_MARGIN_TOP: string = '124vp';
  /**
   * TV banner card horizontal translate offset for side positions.
   */
  public static readonly TV_BANNER_CARD_TRANSLATE_X_OFFSET: number = 140;
  /**
   * TV banner center card z-index.
   */
  public static readonly TV_BANNER_CENTER_Z_INDEX: number = 4;
  /**
   * TV banner side card z-index.
   */
  public static readonly TV_BANNER_SIDE_Z_INDEX: number = 3;
  /**
   * TV banner default z-index.
   */
  public static readonly TV_BANNER_DEFAULT_Z_INDEX: number = 1;
  /**
   * TV banner border radius 5%.
   */
  public static readonly TV_BANNER_BORDER_RADIUS_FIVE_PERCENT: string = '5%';
  /**
   * TV banner border radius 2%.
   */
  public static readonly TV_BANNER_BORDER_RADIUS_TWO_PERCENT: string = '2%';
  /**
   * TV Banner scale param two
   * */
  public static readonly TV_BANNER_IMAGE_SCALE_1: ScaleOptions = { x: 0.6, y: 0.7 };
  /**
   * TV Banner scale param one
   * */
  public static readonly TV_BANNER_IMAGE_SCALE_2: ScaleOptions = { x: 0.7, y: 0.8 };
  /**
   * TV Banner scale param three
   * */
  public static readonly TV_BANNER_IMAGE_SCALE_3: ScaleOptions = { x: 2.2, y: 1 };
  /**
   * VP unit.
   */
  public static readonly VP_UNIT: string = 'vp';
  /**
   * Page name for video.
   */
  public static readonly PAGE_NAME_FOR_VIDEO: string = 'videoDetail';
  /**
   * Page name for navigation.
   */
  public static readonly PAGE_NAME_FOR_SEARCH: string = 'searchView';
}