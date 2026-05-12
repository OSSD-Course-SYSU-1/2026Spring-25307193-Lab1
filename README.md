# 多设备长视频界面

## 项目简介

本示例基于一多能力，实现了一次开发、多端部署的长视频应用界面，覆盖直板机、折叠屏、平板、电脑及智慧屏等多种设备形态。同时，采用三层架构组织代码工程，结合自适应布局与响应式布局，构建了从首页、搜索到视频详情的完整长视频体验。

## 效果预览

直板机运行效果图如下：

![](screenshots/device/phone.png)

折叠屏运行效果图如下：

![](screenshots/device/foldable.png)

平板运行效果图如下：

![](screenshots/device/tablet.png)

电脑运行效果图如下：

![](screenshots/device/2in1.png)

智慧屏运行效果图如下：

![](screenshots/device/tv.png)


## 使用说明

1. 在手机、平板、电脑上安装名称为**default**的hap包，在智慧屏上安装名称为**tv**的hap包。安装完成后打开应用，即可在不同设备上看到通过自适应和响应式布局呈现的差异化长视频界面。

2. 在首页推荐视频区域，支持长按第一张图片预览视频。在电脑上，鼠标右键点击推荐视频区域可弹出菜单，鼠标悬停时图片放大。在md、lg和xl横向断点下，支持双指捏合缩放推荐视频区域。

3. 在首页往期回顾区域，在手机、平板、电脑设备上点击播放/继续播放可跳转到视频详情页，在智慧屏上点击视频封面图片可跳转到视频详情页。

4. 顶部Tab区域可切换不同内容区块。在手机、平板、电脑设备上，切换到社区Tab可查看首页的沉浸式设计；在lg和xl断点下切换到视频Tab，可查看Banner图的创新排版。在智慧屏设备上的首页Tab，可查看为大屏优化的Banner图样式。

5. 在手机、平板、电脑设备上，点击顶部搜索框进入搜索页：输入关键字“华”后可看到智能提示列表；点击智能提示中的“华为发布会”进入搜索结果页，点击结果中的播放按钮跳转到视频详情页。在智慧屏设备上，输入关键字“H”后可看到搜索结果视频列表，点击列表中的视频封面图片跳转到视频详情页。

6. 在手机、平板、电脑设备上，视频详情页默认播放当前视频，支持播放/暂停、拖动进度条跳转、进入/退出全屏播放，全屏状态下可打开/关闭选集工具栏，评论区根据断点进行上下布局或左右分区。在智慧屏设备上，视频详情页默认展示选集信息，点击任意一集后进入视频播放页面，视频默认全屏播放，支持播放/暂停、拖动进度条跳转、打开/关闭选集工具栏。

7. 在手机、平板、电脑设备上，当评论区上下布局时，上滑视频会先隐藏相关列表区域，视频再等比缩小让出空间给评论区；当评论区左右分区时，上滑视频会等比缩小并优先展示简介区内容。

## 工程目录

```
├──commons                                                     // 公共能力层
│  └──base
│     └──src
│        └──main
│           └──ets
│              ├──constants
│              │  ├──BreakpointConstants.ets                   // 断点相关常量
│              │  └──CommonConstants.ets                       // 公共静态常量
│              └──utils
│                 ├──AvPlayerUtil.ets                          // AVPlayer播放封装工具
│                 ├──BreakpointType.ets                        // 断点类型工具
│                 ├──DeviceScreen.ets                          // 设备屏幕信息工具
│                 ├──DisplayUtil.ets                           // 设备显示信息工具
│                 ├──Logger.ets                                // 日志工具类
│                 └──WindowUtil.ets                            // 窗口工具类
├──features                                                    // 基础特性层
│  ├──home                                                     // 长视频首页模块
│  │  └──src
│  │     └──main
│  │        ├──ets                           
│  │        │  ├──constants
│  │        │  │  └──HomeConstants.ets                         // 首页相关常量
│  │        │  ├──model
│  │        │  │  ├──BannerModel.ets                           // Banner数据及相关处理
│  │        │  │  ├──IconModel.ets                             // 图标数据及相关处理
│  │        │  │  └──VideoImgModel.ets                         // 视频封面数据及相关处理
│  │        │  ├──utils
│  │        │  │  └──PreviousVideoUtil.ets                     // 上次播放工具
│  │        │  ├──view
│  │        │  │  ├──BannerView.ets                            // Banner区域
│  │        │  │  ├──CommonView.ets                            // 通用视图
│  │        │  │  ├──CommunityContent.ets                      // 社区内容
│  │        │  │  ├──DailyVideo.ets                            // 每日视频
│  │        │  │  ├──FeaturedContent.ets                       // 精选内容
│  │        │  │  ├──Home.ets                                  // 首页主界面
│  │        │  │  ├──HomeHeader.ets                            // 顶部搜索框与Tab
│  │        │  │  ├──IconView.ets                              // 图标视图
│  │        │  │  ├──NewVideoRelease.ets                       // 新片发布
│  │        │  │  ├──PreviousVideo.ets                         // 上次播放
│  │        │  │  ├──RecommendedVideo.ets                      // 推荐视频
│  │        │  │  ├──TVBannerView.ets                          // 智慧屏Banner视图
│  │        │  │  ├──TVHomeContent.ets                         // 智慧屏首页下方内容信息
│  │        │  │  ├──TVHomeHeader.ets                          // 智慧屏首页顶部导航信息
│  │        │  │  ├──TVPreviousVideo.ets                       // 智慧屏上次播放信息
│  │        │  │  ├──TVTopBarView.ets                          // 智慧屏顶部栏
│  │        │  │  ├──VideoContent.ets                          // 视频内容
│  │        │  │  └──VideoDialog.ets                           // 视频弹窗
│  │        │  └──viewmodel
│  │        │     ├──BannerViewModel.ets                       // Banner UI和数据交互管理
│  │        │     ├──IconViewModel.ets                         // 图标 UI和数据交互管理
│  │        │     └──VideoImgViewModel.ets                     // 视频封面 UI和数据交互管理
│  │        └──resources                                       // 首页模块资源
│  ├──search                                                   // 搜索模块
│  │  └──src
│  │     └──main
│  │        ├──ets
│  │        │  ├──constants
│  │        │  │  └──SearchConstants.ets                       // 搜索相关常量
│  │        │  ├──model
│  │        │  │  ├──SearchKeyboardModel.ets                   // 键盘数据及相关处理
│  │        │  │  └──SearchVideoImgModel.ets                   // 视频数据及相关处理
│  │        │  ├──view
│  │        │  │  ├──SearchContent.ets                         // 搜索内容
│  │        │  │  ├──SearchForHua.ets                          // 搜索发现
│  │        │  │  ├──SearchHeader.ets                          // 搜索头部
│  │        │  │  ├──SearchResult.ets                          // 搜索结果列表
│  │        │  │  ├──SearchView.ets                            // 搜索主界面
│  │        │  │  ├──TVSearchTabs.ets                          // 智慧屏搜索Tab
│  │        │  │  ├──TVSearchVideos.ets                        // 智慧屏搜索视频列表
│  │        │  │  └──TVSearchView.ets                          // 智慧屏搜索主界面
│  │        │  └──viewmodel
│  │        │     ├──SearchKeyboardViewModel.ets               // 键盘UI和数据交互管理
│  │        │     └──SearchVideoImgViewModel.ets               // 搜索结果UI和数据交互管理
│  │        └──resources                                       // 搜索模块资源
│  └──videoDetail                                              // 视频详情与播放模块
│     └──src
│        └──main
│           ├──ets
│           │  ├──constants
│           │  │  └──DetailConstants.ets                       // 视频相关常量
│           │  ├──model
│           │  │  ├──RelatedVideoModel.ets                     // 相关视频数据及相关处理
│           │  │  └──UserModel.ets                             // 用户数据及相关处理
│           │  ├──utils
│           │  │  └──CurrentOffsetUtil.ets                     // 滚动偏移工具
│           │  ├──view
│           │  │  ├──AllComments.ets                           // 评论列表
│           │  │  ├──FooterEpisodes.ets                        // 底部选集
│           │  │  ├──RelatedList.ets                           // 相关视频列表
│           │  │  ├──SelfComment.ets                           // 评论输入栏
│           │  │  ├──SideEpisodes.ets                          // 侧边选集
│           │  │  ├──TVVideoDetail.ets                         // 智慧屏视频详情页
│           │  │  ├──TVVideoDetailView.ets                     // 智慧屏视频详情布局
│           │  │  ├──TVVideoPlayer.ets                         // 智慧屏视频播放
│           │  │  ├──VideoDetail.ets                           // 视频详情页
│           │  │  ├──VideoDetailView.ets                       // 视频详情布局
│           │  │  └──VideoPlayer.ets                           // 视频播放
│           │  └──viewmodel
│           │     ├──RelatedVideoViewModel.ets                 // 相关视频UI和数据交互管理
│           │     └──UserViewModel.ets                         // 用户UI和数据交互管理
│           └──resources                                       // 视频详情模块资源
└──products                                                    // 产品定制层
   ├──default                                                  // 默认（手机/平板/电脑）产品
   │  └──src
   │     └──main
   │        ├──ets
   │        │  ├──constants
   │        │  │  └──PageConstants.ets                         // 默认产品页面路由常量
   │        │  ├──entryability 
   │        │  │  └──EntryAbility.ets                          // 默认产品入口
   │        │  ├──model
   │        │  │  └──FooterTabModel.ets                        // 底部Tab数据及相关处理
   │        │  ├──pages
   │        │  │  └──Index.ets                                 // 默认产品首页
   │        │  ├──view
   │        │  │  └──VideoView.ets                             // 首页页面布局
   │        │  └──viewmodel
   │        │     └──FooterTabViewModel.ets                    // 底部Tab UI和数据交互管理
   │        └──resources                                       // 默认产品资源
   └──tv                                                       // 智慧屏产品
      └──src
         └──main
            ├──ets
            │  ├──constants
            │  │  └──PageConstants.ets                         // 智慧屏产品页面路由常量
            │  ├──tvability
            │  │  └──TvAbility.ets                             // 智慧屏产品入口
            │  └──pages
            │     └──Index.ets                                 // 智慧屏产品首页
            └──resources                                       // 智慧屏产品资源
```

## 具体实现

1. 将工程目录按照products、features、common的三层架构进行组织。由于智慧屏设备和手机、平板、电脑设备的UI结构和交互逻辑差异较大，因此在products层创建了两个hap包作为不同设备的应用入口：名称为**default**的hap包，作为手机、平板和电脑设备的应用入口；名称为**tv**的hap包，作为智慧屏设备的应用入口。在features层实现首页（home）、搜索（search）、视频详情（videoDetail）三个业务模块，供products层统一调用；在common层存放通用工具类和公共静态常量。

2. 首页（home）模块：
    - **在顶部导航与Tab区域**
        - 在手机、平板、电脑设备上：将搜索框与顶部Tab结合，通过一多断点调整Tab样式和布局，让其不同屏幕尺寸上分别呈现一行或两行的布局。代码位置：[features/home/src/main/ets/view/HomeHeader.ets](./features/home/src/main/ets/view/HomeHeader.ets)。
        - 在智慧屏设备上：通过顶部导航统一控制首页和搜索页等页面的切换。代码位置：[features/home/src/main/ets/view/TVHomeHeader.ets](./features/home/src/main/ets/view/TVHomeHeader.ets)。
    - **Banner区域**
        - 在手机、平板、电脑设备上：使用Swiper组件加载banner列表，通过一多断点控制banner图的aspectRatio等属性，实现基于屏幕尺寸的自适应banner。代码位置：[features/home/src/main/ets/view/BannerView.ets](./features/home/src/main/ets/view/BannerView.ets)。
        - 在智慧屏设备上：同样基于Swiper组件加载banner列表，但结合滑动手势PanGesture，实现了为智慧屏优化的banner图样式。代码位置：[TVBannerView.ets](features/home/src/main/ets/view/TVBannerView.ets)。
    - **视频推荐、新片发布区域**
        - 在手机、平板、电脑设备上：视频推荐和新片发布区域，均使用网格布局Grid组件，在不同断点下将父组件分为不同列数，来实现自适应布局的占比能力。代码位置：[features/home/src/main/ets/view/RecommendedVideo.ets](./features/home/src/main/ets/view/RecommendedVideo.ets)、[features/home/src/main/ets/view/NewVideoRelease.ets](./features/home/src/main/ets/view/NewVideoRelease.ets)。
        - 在智慧屏设备上：在视频推荐和新片发布区域，与手机、平板、电脑设备进行复用，并根据智慧屏的断点布局。代码位置：[features/home/src/main/ets/view/RecommendedVideo.ets](./features/home/src/main/ets/view/RecommendedVideo.ets)、[features/home/src/main/ets/view/NewVideoRelease.ets](./features/home/src/main/ets/view/NewVideoRelease.ets)。
    - **每日佳片、往期回顾区域**
        - 在手机、平板、电脑设备上：每日佳片和往期回顾区域使用栅格断点系统，根据断点变化改变组件内相应的属性实现布局效果。使用GirdRow组件和GridCol组件设置主图和子图在不同断点下的栅格列数，并根据不同断点设置图片的高度。代码位置：[features/home/src/main/ets/view/DailyVideo.ets](./features/home/src/main/ets/view/DailyVideo.ets)、[features/home/src/main/ets/view/PreviousVideo.ets](./features/home/src/main/ets/view/PreviousVideo.ets)。
        - 在智慧屏设备上：在每日佳片区域，与手机、平板、电脑设备进行复用，并根据智慧屏的断点布局。在往期回顾区域，由于与其它设备的UI结构差异较大，因此单独进行设计和开发。代码位置：[features/home/src/main/ets/view/DailyVideo.ets](./features/home/src/main/ets/view/DailyVideo.ets)、[features/home/src/main/ets/view/TVPreviousVideo.ets](./features/home/src/main/ets/view/TVPreviousVideo.ets)。

3. 搜索（search）模块：
    - 在手机、平板、电脑设备上：搜索发现、热搜、智能提示区域，均使用List组件，设置在不同断点下的lanes属性来实现。搜索结果区域使用GirdRow组件和GridCol组件设置不同断点下的栅格列数，并根据不同断点设置图片的高度。代码位置：[features/search/src/main/ets/view/SearchContent.ets](./features/search/src/main/ets/view/SearchContent.ets)、[features/search/src/main/ets/view/SearchByKeyword.ets](./features/search/src/main/ets/view/SearchByKeyword.ets)、[features/search/src/main/ets/view/SearchResult.ets](./features/search/src/main/ets/view/SearchResult.ets)。
    - 在智慧屏设备上：自定义输入键盘区域，使用Grid组件实现。搜索历史、推荐、热搜和搜索结果使用list组件实现。代码位置：[features/search/src/main/ets/view/TVSearchView.ets](./features/search/src/main/ets/view/TVSearchView.ets)、[features/search/src/main/ets/view/TVSearchVideos.ets](./features/search/src/main/ets/view/TVSearchVideos.ets)、[features/search/src/main/ets/view/TVSearchTabs.ets](./features/search/src/main/ets/view/TVSearchTabs.ets)。

4. 视频详情（videoDetail）模块：
    - **播放功能**
        - 在手机、平板、电脑和智慧屏设备上：视频播放功能使用AVPlayer和XComponent实现，播放的全流程包含：创建AVPlayer，设置播放资源，播放控制（播放/暂停/跳转/停止），重置，销毁资源。代码位置：[features/videoDetail/src/main/ets/view/VideoPlayer.ets](./features/videoDetail/src/main/ets/view/VideoPlayer.ets)、[features/videoDetail/src/main/ets/view/TVVideoPlayer.ets](./features/videoDetail/src/main/ets/view/TVVideoPlayer.ets)、[common/base/src/main/ets/utils/AvPlayerUtil.ets](./common/base/src/main/ets/utils/AvPlayerUtil.ets)。
    - **评论区**
        - 在手机、平板、电脑设备上：通过一多断点控制显示在视频下方或右侧边栏，右侧边栏结合SideBarContainer组件和一多断点控制显示的位置，同时侧边栏宽度可通过拖拽调节。评论区中的图片，通过一多断点和宽高、比例等属性控制其等比放大或缩小，实现自适应布局的缩放能力。代码位置：[features/videoDetail/src/main/ets/view/AllComments.ets](./features/videoDetail/src/main/ets/view/AllComments.ets)、[features/videoDetail/src/main/ets/view/SelfComment.ets](./features/videoDetail/src/main/ets/view/SelfComment.ets)、[features/videoDetail/src/main/ets/view/VideoDetail.ets](./features/videoDetail/src/main/ets/view/VideoDetail.ets)、[features/videoDetail/src/main/ets/view/RelatedList.ets](./features/videoDetail/src/main/ets/view/RelatedList.ets)。
    - **全屏和选集**
        - 在手机、平板、电脑和智慧屏设备上：通过setPreferredOrientation()接口和一多断点控制在页面路由、窗口尺寸、折叠状态、是否全屏变化时的屏幕旋转策略。通过一多断点控制选集组件在全屏播放状态下显示在视频下方或视频右侧。代码位置：[features/videoDetail/src/main/ets/view/FooterEpisodes.ets](./features/videoDetail/src/main/ets/view/FooterEpisodes.ets)、[features/videoDetail/src/main/ets/view/SideEpisodes.ets](./features/videoDetail/src/main/ets/view/SideEpisodes.ets)、[features/videoDetail/src/main/ets/view/TVVideoDetailView.ets](./features/videoDetail/src/main/ets/view/TVVideoDetailView.ets)。
        - 在智慧屏设备上：在全屏播放状态下，可通过点击选集按钮进行选集播放。代码位置：[features/videoDetail/src/main/ets/view/TVVideoDetailView.ets](./features/videoDetail/src/main/ets/view/TVVideoDetailView.ets)。

## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：直板机、双折叠（Mate X系列）、三折叠、阔折叠、平板、电脑、智慧屏。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 6.0.2 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 6.0.2 Release SDK及以上。