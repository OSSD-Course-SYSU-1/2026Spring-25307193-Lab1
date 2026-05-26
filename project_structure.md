\#MultiVideoApplication 项目结构解析

MultiVideoApplication-master/                        # 项目根目录

│  build-profile.json5                               # 工程级构建配置（签名、产品、模块依赖）

│  hvigorfile.ts                                     # 工程级构建脚本（hvigor 编译任务）

│  LICENSE                                           # 开源许可文件（Apache 2.0）

│  OAT.xml                                           # 华为开源审查配置文件

│  oh-package.json5                                  # 工程级依赖管理（声明所有模块）

│  README.en.md                                      # 英文项目说明文档

│  README.md                                         # 中文项目说明文档

│

├─.hvigor/                                           # hvigor 构建工具缓存目录（自动生成，勿改）

│

├─.idea/                                             # IntelliJ IDEA / DevEco Studio 项目配置

│

├─AppScope/                                          # 应用全局配置目录

│  │  app.json5                                      # 应用配置（包名、版本号、图标、主题等）

│  └─resources/                                      # 全局资源

│      └─base/

│          ├─element/

│          │      string.json                        # 全局字符串资源（如应用名称）

│          └─media/

│                  app\_icon.png                      # 应用图标（前景层）

│                  background.png                    # 应用图标背景层

│                  foreground.png                    # 应用图标前景层

│                  layered\_image.json                # 分层图标描述文件

│

├─common/                                            # 公共能力层（HAR 共享模块）

│  └─base/                                           # 基础能力模块

│      │  build-profile.json5                        # 模块级构建配置

│      │  BuildProfile.ets                           # 构建时生成的配置信息（自动）

│      │  hvigorfile.ts                              # 模块级构建脚本

│      │  Index.ets                                  # 模块对外导出接口（供其他模块 import）

│      │  oh-package.json5                           # 模块依赖管理

│      ├─build/                                      # 编译输出目录（自动生成）

│      └─src/                                        # 源代码

│          └─main/

│              │  module.json5                       # 模块配置文件（HAR 模块描述）

│              └─ets/

│                  ├─constants/                      # 常量定义

│                  │      BreakpointConstants.ets    # 断点/响应式布局常量（屏幕尺寸断点）

│                  │      CommonConstants.ets        # 通用常量（颜色、尺寸、请求地址等）

│                  └─utils/                          # 工具类

│                          AvPlayerUtil.ets          # 视频播放器封装工具（AVPlayer）

│                          BreakpointType.ets        # 断点类型定义（sm/md/lg）

│                          BreakpointVisibilityUtil.ets # 响应式可见性工具

│                          DeviceScreen.ets          # 设备屏幕信息获取

│                          DisplayUtil.ets           # 屏幕显示相关工具（px/vp 转换等）

│                          Logger.ets                # 日志打印工具

│                          SetDecorButtonStyleUtil.ets # 设置窗口装饰按钮样式

│                          WindowUtil.ets            # 窗口管理工具（全屏、沉浸式等）

│

├─features/                                          # 基础特性层（独立业务功能模块）

│  ├─home/                                           # 首页模块（HAR）

│  │  │  build-profile.json5

│  │  │  BuildProfile.ets

│  │  │  hvigorfile.ts

│  │  │  Index.ets                                   # 对外暴露首页组件

│  │  │  oh-package-lock.json5

│  │  │  oh-package.json5

│  │  ├─build/                                       # 编译缓存

│  │  ├─oh\_modules/                                  # 模块依赖的三方库

│  │  └─src/

│  │      └─main/

│  │          │  module.json5

│  │          ├─ets/

│  │          │  ├─constants/

│  │          │  │      HomeConstants.ets            # 首页常量（栏目ID、请求参数等）

│  │          │  ├─model/                           # 数据模型

│  │          │  │      BannerModel.ets              # 轮播图数据模型

│  │          │  │      IconModel.ets                # 图标入口数据模型（如“热门”“会员”）

│  │          │  │      VideoImgModel.ets            # 视频封面数据模型

│  │          │  ├─utils/

│  │          │  │      PreviousVideoUtil.ets        # “往期视频”数据处理工具

│  │          │  ├─view/                            # UI 组件

│  │          │  │      BannerView.ets               # 轮播图组件

│  │          │  │      CommonView.ets               # 通用视图（如加载中、错误页）

│  │          │  │      CommunityContent.ets         # 社区内容板块

│  │          │  │      DailyVideo.ets               # 每日视频推荐组件

│  │          │  │      FeaturedContent.ets          # 精选内容组件

│  │          │  │      Home.ets                     # 首页主入口组件

│  │          │  │      HomeHeader.ets               # 首页顶部导航栏

│  │          │  │      IconView.ets                 # 图标入口组件（一排小图标）

│  │          │  │      NewVideoRelease.ets          # 新片发布组件

│  │          │  │      PreviousVideo.ets            # 往期视频组件（手机/平板）

│  │          │  │      RecommendedVideo.ets         # 为你推荐视频组件

│  │          │  │      TVBannerView.ets             # TV 版轮播图

│  │          │  │      TVHomeContent.ets            # TV 版首页内容

│  │          │  │      TVHomeHeader.ets             # TV 版顶部栏

│  │          │  │      TVPreviousVideo.ets          # TV 版往期视频

│  │          │  │      TVTopBarView.ets             # TV 版顶部状态栏

│  │          │  │      VideoContent.ets             # 视频内容通用容器

│  │          │  │      VideoDialog.ets              # 视频详情弹窗（预览）

│  │          │  └─viewmodel/                       # 视图模型（业务逻辑）

│  │          │          BannerViewModel.ets         # 轮播图数据获取与状态管理

│  │          │          IconViewModel.ets           # 图标入口数据管理

│  │          │          VideoImgViewModel.ets       # 视频封面数据管理

│  │          └─resources/                          # 首页模块资源

│  │              ├─base/

│  │              │  ├─element/

│  │              │  │      color.json               # 颜色值

│  │              │  │      float.json               # 尺寸常量（间距、字号等）

│  │              │  │      string.json              # 字符串（标题、标签）

│  │              │  └─media/                       # 图片资源（banner、图标、视频封面等）

│  │              ├─en\_US/                          # 英文资源

│  │              └─zh\_CN/                          # 中文资源

│  │

│  ├─search/                                         # 搜索模块（结构类似 home）

│  │  │  ...（省略相似文件）

│  │  └─src/main/ets/

│  │      ├─constants/SearchConstants.ets           # 搜索常量

│  │      ├─model/                                  # 搜索数据模型

│  │      ├─view/                                   # 搜索页 UI（SearchView, SearchResult 等）

│  │      └─viewmodel/                              # 搜索业务逻辑

│  │

│  └─videoDetail/                                   # 视频详情模块

│      └─src/main/ets/

│          ├─constants/DetailConstants.ets          # 详情页常量

│          ├─model/                                 # 相关视频、用户模型

│          ├─utils/CurrentOffsetUtil.ets            # 滚动偏移工具（记录播放位置）

│          ├─view/                                  # 详情页 UI

│          │      AllComments.ets                   # 全部评论列表

│          │      FooterEpisodes.ets                # 底部剧集列表（手机）

│          │      RelatedList.ets                   # 相关推荐列表

│          │      SelfComment.ets                   # 评论输入框

│          │      SideEpisodes.ets                  # 侧边剧集列表（平板）

│          │      TVVideoDetail.ets                 # TV 版详情页入口

│          │      TVVideoDetailView.ets             # TV 版详情视图

│          │      TVVideoPlayer.ets                 # TV 版播放器

│          │      VideoDetail.ets                   # 手机/平板详情页入口

│          │      VideoDetailView.ets               # 手机/平板详情视图

│          │      VideoPlayer.ets                   # 手机/平板播放器

│          └─viewmodel/                             # 详情页业务逻辑

│                  RelatedVideoViewModel.ets        # 相关视频数据

│                  UserViewModel.ets                # 用户信息（点赞、收藏）

│

├─hvigor/                                            # hvigor 构建工具配置（全局）

│      hvigor-config.json5                           # hvigor 引擎配置（Node.js 路径等）

│

├─oh\_modules/                                        # 项目依赖的三方库缓存（自动生成）

│

├─products/                                          # 产品定制层（HAP 应用入口）

│  ├─default/                                        # 默认设备入口（手机、折叠屏、平板）

│  │  │  build-profile.json5                         # 模块构建配置

│  │  │  hvigorfile.ts

│  │  │  obfuscation-rules.txt                       # 代码混淆规则

│  │  │  oh-package-lock.json5

│  │  │  oh-package.json5

│  │  ├─build/                                       # 编译输出（hap 包等）

│  │  ├─oh\_modules/                                  # 依赖的模块（common、home 等）

│  │  └─src/

│  │      └─main/

│  │          │  module.json5                        # 模块配置（声明 Ability、权限等）

│  │          ├─ets/

│  │          │  ├─constants/

│  │          │  │      PageConstants.ets            # 页面常量（路由、参数名）

│  │          │  ├─entryability/

│  │          │  │      EntryAbility.ets             # 应用入口 Ability（生命周期、窗口初始化）

│  │          │  ├─model/

│  │          │  │      FooterTabModel.ets           # 底部 Tab 栏数据模型

│  │          │  ├─pages/

│  │          │  │      Index.ets                    # 主页面（包含底部 Tab 导航）

│  │          │  ├─view/

│  │          │  │      VideoView.ets                # 视频播放页容器（集成播放器）

│  │          │  └─viewmodel/

│  │          │          FooterTabViewModel.ets      # 底部 Tab 状态管理

│  │          └─resources/                           # 入口模块资源

│  │              ├─base/

│  │              │  ├─element/（颜色、字符串）

│  │              │  ├─media/（启动图标、背景图）

│  │              │  └─profile/

│  │              │          main\_pages.json         # 页面路由配置（声明所有页面）

│  │              ├─en\_US/                          # 英文资源

│  │              └─zh\_CN/                          # 中文资源

│  │

│  └─tv/                                             # 智慧屏（TV）专用入口

│      │  ...（类似 default，但针对 TV 适配）

│      └─src/main/

│          ├─ets/

│          │  ├─pages/Index.ets                     # TV 版主页面（焦点导航、遥控器适配）

│          │  └─tvability/TvAbility.ets             # TV 版 Ability（不同于手机 EntryAbility）

│          └─resources/（TV 专用布局、尺寸）

│

└─screenshots/                                       # 项目文档截图（多设备预览图）

&#x20;   └─device/

&#x20;           2in1.png                                 # 2合1设备（PC/平板）截图

&#x20;           foldable.png                             # 折叠屏截图

&#x20;           phone.png                                # 手机截图

&#x20;           tablet.png                               # 平板截图

&#x20;           tv.png                                   # 智慧屏截图

&#x20;           ...（中英文各一份）

