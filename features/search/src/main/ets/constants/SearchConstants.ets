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

export class SearchConstants {
  /**
   * hot search.
   */
  public static readonly HOT_ACTION: ResourceStr[] =
    [$r('app.string.title_content'), $r('app.string.title_content'), $r('app.string.title_content'),
      $r('app.string.title_content'), $r('app.string.title_content'), $r('app.string.title_content')]
  /**
   * History action button.
   */
  public static readonly SEARCH_ACTION: ResourceStr[] = [$r('app.string.clear'), $r('app.string.delete')]
  /**
   * History list.
   */
  public static readonly SEARCH_HISTORY: ResourceStr[] = [$r('app.string.content'), $r('app.string.content')]
  /**
   * History list for tv.
   */
  public static readonly SEARCH_HISTORY_AND_DISCOVERY: ResourceStr[] =
    [$r('app.string.history_del'), $r('app.string.content'), $r('app.string.content'), $r('app.string.content'),
      $r('app.string.history_search'), $r('app.string.history_record'), $r('app.string.history_record')]
  /**
   * Searching for a recommendation list in large devices.
   */
  public static readonly SEARCH_DISCOVERY_LARGE: ResourceStr[] =
    [$r('app.string.search0'), $r('app.string.search0'), $r('app.string.search0'), $r('app.string.search0'),
      $r('app.string.search0'), $r('app.string.search0'), $r('app.string.search0'), $r('app.string.search0'),
      $r('app.string.search0')];
  /**
   * Tabs list.
   */
  public static readonly SEARCH_TABS: ResourceStr[] =
    [$r('app.string.top'), $r('app.string.theater'), $r('app.string.movie'), $r('app.string.variety'),
      $r('app.string.anime'), $r('app.string.children'), $r('app.string.records')];
  /**
   * Search List for hua.
   */
  public static readonly HUA_LIST: ResourceStr[] =
    [ $r('app.string.tv'), $r('app.string.tv'),  $r('app.string.tv'), $r('app.string.conference'),
      $r('app.string.tv'),  $r('app.string.tv')];
  public static readonly HUA_LIST_FOR_HUA: ResourceStr[] =
    [ $r('app.string.conference'),
      $r('app.string.tv'),  $r('app.string.tv')];
  /**
   * Search result tab List.
   */
  public static readonly SEARCH_RESULT_TAB_LIST: ResourceStr[] =
    [$r('app.string.search_all'), $r('app.string.filmer'), $r('app.string.search_video'), $r('app.string.user')];
  /**
   * Search video img title list.
   */
  public static readonly SEARCH_IMG_IMG_TITLES: ResourceStr[] =
    [$r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'),
      $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'),
      $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'),
      $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural')];
  /**
   * Search result img title list.
   */
  public static readonly SEARCH_RESULT_IMG_TITLES: ResourceStr[] =
    [$r('app.string.product_launch'), $r('app.string.product_launch'), $r('app.string.product_launch'), $r('app.string.product_launch'),
      $r('app.string.product_launch')];
  /**
   * Search video img content list.
   */
  public static readonly SEARCH_IMG_IMG_CONTENTS: ResourceStr[] =
    [$r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe')];
  /**
   * Search result title list.
   */
  public static readonly SEARCH_RESULT_TITLES: ResourceStr[] = [$r('app.string.flagship'), $r('app.string.flagship'),
    $r('app.string.flagship')];
  /**
   * Search result content list.
   */
  public static readonly SEARCH_RESULT_CONTENTS: ResourceStr[] =
    [$r('app.string.press'), $r('app.string.press'), $r('app.string.press')];
  /**
   * Search result more info list.
   */
  public static readonly SEARCH_RESULT_MORE: ResourceStr[] =
    [$r('app.string.search_plays'), $r('app.string.search_plays'), $r('app.string.search_plays')];
  /**
   * Search sub title list.
   */
  public static readonly SEARCH_SUB_TITLES: ResourceStr[] = [$r('app.string.history_search'), $r('app.string.content'), $r('app.string.find')];
  /**
   * Search recommend list lanes.
   */
  public static readonly SEARCH_LIST_LANES: number[] = [3, 3, 2, 1, 1];
  /**
   * Hot trending list spaces.
   */
  public static readonly HOT_TRENDING_LIST_SPACES: string[] = ['16vp', '16vp', '24vp', '36vp', '36vp'];
  /**
   * Search recommend divider padding.
   */
  public static readonly SEARCH_RECOMMEND_DIVIDER_PADDING: string = '16vp';
  /**
   * Search index.
   */
  public static readonly SEARCH_INDEX: number[] = [2, 3];
  /**
   * Search placeholder.
   */
  public static readonly SEARCH_PLACEHOLDER: ResourceStr = $r('app.string.search1');
  /**
   * Type tabs divider stroke width.
   */
  public static readonly TYPE_TABS_DIVIDER_STROKE_WIDTH: string = '2vp';
  /**
   * Search result title.
   */
  public static readonly SEARCH_RESULT_TITLE: ResourceStr = $r('app.string.conference');
  /**
   * Search result button text list.
   */
  public static readonly SEARCH_RESULT_BUTTON_TEXTS: ResourceStr[] =
    [$r('app.string.search_player'), $r('app.string.search_cache')];
  /**
   * Search input list.
   */
  public static readonly SEARCH_INPUT_LIST: ResourceStr[] = ['华', '华为发布会', 'H'];
  /**
   * Page name for video.
   */
  public static readonly PAGE_NAME_FOR_VIDEO: string = 'videoDetail';
}