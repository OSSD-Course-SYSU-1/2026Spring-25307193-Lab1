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

import { DetailConstants } from '../constants/DetailConstants';

// 临时直接导入，避免模块导出问题
// import { AISummaryUtil, VideoSummary } from '@ohos/commons';

// 定义VideoSummary接口
interface VideoSummary {
  videoId: string;
  title: string;
  summary: string;
  keyPoints: string[];
  duration: string;
  category: string;
  tags: string[];
  generatedTime: string;
}

// 模拟AISummaryUtil类
class LocalAISummaryUtil {
  private static instance?: LocalAISummaryUtil;
  private summaryCache: Map<string, VideoSummary> = new Map();
  
  static getInstance(): LocalAISummaryUtil {
    if (!LocalAISummaryUtil.instance) {
      LocalAISummaryUtil.instance = new LocalAISummaryUtil();
      // 初始化模拟数据
      LocalAISummaryUtil.instance.initMockData();
    }
    return LocalAISummaryUtil.instance;
  }
  
  private initMockData(): void {
    const mockSummaries: VideoSummary[] = [
      {
        videoId: 'video1',
        title: '华为春季旗舰新品发布会',
        summary: '本次华为春季发布会重点介绍了多款新品，包括华为P60系列智能手机、MateBook X Pro笔记本电脑、Watch 4智能手表等。发布会强调了华为在影像技术、折叠屏设计和生态系统方面的创新。',
        keyPoints: [
          '华为P60系列搭载全新影像系统，支持可变光圈技术',
          'MateBook X Pro采用超薄设计，配备3.1K原色全面屏',
          'Watch 4系列支持eSIM独立通话和健康监测功能',
          '鸿蒙生态系统进一步完善，实现多设备协同'
        ],
        duration: '2小时15分钟',
        category: '科技发布会',
        tags: ['华为', '新品发布', '智能手机', '笔记本电脑', '智能手表'],
        generatedTime: '2023-03-23 14:30:00'
      }
    ];
    
    mockSummaries.forEach(summary => {
      this.summaryCache.set(summary.videoId, summary);
    });
  }
  
  getCachedVideoIds(): string[] {
    return Array.from(this.summaryCache.keys());
  }
  
  async getVideoSummary(videoId: string, videoTitle?: string): Promise<VideoSummary | null> {
    // 检查缓存
    const cachedSummary = this.summaryCache.get(videoId);
    if (cachedSummary) {
      return cachedSummary;
    }
    
    // 模拟延迟
    await new Promise<void>(resolve => setTimeout(resolve, 1000));
    
    // 生成模拟总结
    const now = new Date();
    const formattedTime = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')} ${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
    
    const summary: VideoSummary = {
      videoId,
      title: videoTitle || '视频总结',
      summary: '这是一个AI生成的视频内容总结，分析了视频的主要内容和关键信息。',
      keyPoints: [
        '视频主要内容概述',
        '关键信息提取',
        '重要观点总结',
        '实用建议和结论'
      ],
      duration: '30分钟',
      category: '教育',
      tags: ['AI总结', '视频分析', '内容提取'],
      generatedTime: formattedTime
    };
    
    this.summaryCache.set(videoId, summary);
    return summary;
  }
}

const TAG = '[AISummary]';

@Component
export struct AISummary {
  @State summaryData: VideoSummary | null = null;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showFullSummary: boolean = false;
  
  // 从父组件传入的视频信息
  private videoId: string = 'video1'; // 默认视频ID
  private videoTitle: string = '华为春季旗舰新品发布会'; // 默认视频标题
  
  // 参数：视频ID和标题
  @Prop videoIdProp: string = 'video1';
  @Prop videoTitleProp: string = '华为春季旗舰新品发布会';
  
  aboutToAppear(): void {
    // 使用传入的视频ID和标题
    this.videoId = this.videoIdProp;
    this.videoTitle = this.videoTitleProp;
    
    // 组件加载时尝试获取缓存的总结
    this.loadCachedSummary();
  }
  
  /**
   * 加载缓存的AI总结
   */
  private loadCachedSummary(): void {
    const aiSummaryUtil = LocalAISummaryUtil.getInstance();
    const cachedSummary = aiSummaryUtil.getCachedVideoIds().includes(this.videoId);
    
    if (cachedSummary) {
      // 如果有缓存，直接获取
      aiSummaryUtil.getVideoSummary(this.videoId, this.videoTitle).then((summary: VideoSummary | null) => {
        if (summary) {
          this.summaryData = summary;
          this.errorMessage = '';
        }
      });
    }
  }
  
  /**
   * 生成AI总结
   */
  private async generateSummary(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      const aiSummaryUtil = LocalAISummaryUtil.getInstance();
      const summary = await aiSummaryUtil.getVideoSummary(this.videoId, this.videoTitle);
      
      if (summary) {
        this.summaryData = summary;
      } else {
        this.errorMessage = 'AI总结生成失败，请重试';
      }
    } catch (error) {
      this.errorMessage = 'AI总结生成失败，请重试';
      console.error(TAG, `Failed to generate AI summary: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 切换显示完整总结
   */
  private toggleSummary(): void {
    this.showFullSummary = !this.showFullSummary;
  }
  
  build() {
    Column() {
      // 标题区域
      Row() {
        Text(DetailConstants.AI_SUMMARY_TITLE)
          .fontSize('18fp')
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .layoutWeight(1)
        
        // 生成/重新生成按钮
        if (this.summaryData) {
          Button(DetailConstants.AI_SUMMARY_REGENERATE, { type: ButtonType.Capsule })
            .fontSize('12fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .padding({ left: '12vp', right: '12vp', top: '4vp', bottom: '4vp' })
            .onClick(() => {
              this.generateSummary();
            })
        } else {
          Button(DetailConstants.AI_SUMMARY_GENERATE, { type: ButtonType.Capsule })
            .fontSize('12fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .padding({ left: '12vp', right: '12vp', top: '4vp', bottom: '4vp' })
            .onClick(() => {
              this.generateSummary();
            })
        }
      }
      .width('100%')
      .padding({ top: '16vp', bottom: '12vp', left: '24vp', right: '24vp' })
      
      // 内容区域
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width('40vp')
            .height('40vp')
            .color($r('app.color.primary_color'))
          
          Text(DetailConstants.AI_SUMMARY_LOADING)
            .fontSize('14fp')
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: '12vp' })
        }
        .width('100%')
        .padding({ top: '24vp', bottom: '48vp' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.errorMessage) {
        // 错误状态
        Column() {
          Image($r('app.media.ic_public_comments'))
            .width('48vp')
            .height('48vp')
            .objectFit(ImageFit.Contain)
          
          Text(this.errorMessage)
            .fontSize('14fp')
            .fontColor($r('app.color.error_color'))
            .margin({ top: '12vp' })
            .textAlign(TextAlign.Center)
            .maxLines(2)
          
          Button(DetailConstants.AI_SUMMARY_REGENERATE, { type: ButtonType.Capsule })
            .fontSize('12fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .margin({ top: '16vp' })
            .padding({ left: '16vp', right: '16vp', top: '8vp', bottom: '8vp' })
            .onClick(() => {
              this.generateSummary();
            })
        }
        .width('100%')
        .padding({ top: '24vp', bottom: '48vp' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.summaryData) {
        // 显示AI总结内容
        Column() {
          // 总结摘要
          Column() {
            Text(this.summaryData.summary)
              .fontSize('14fp')
              .fontColor(Color.Black)
              .lineHeight('20vp')
              .maxLines(this.showFullSummary ? undefined : 3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding({ bottom: '16vp' })
          
          // 显示更多/收起按钮
          if (this.summaryData.summary.length > 150) {
            Row() {
              Text(this.showFullSummary ? $r('app.string.collapse') : $r('app.string.expand_more'))
                .fontSize('12fp')
                .fontColor($r('app.color.primary_color'))
                .onClick(() => {
                  this.toggleSummary();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding({ bottom: '16vp' })
          }
          
          // 关键要点
          if (this.summaryData.keyPoints && this.summaryData.keyPoints.length > 0) {
            Column() {
              Row() {
                Text(DetailConstants.AI_SUMMARY_KEY_POINTS)
                  .fontSize('14fp')
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.Black)
              }
              .width('100%')
              .padding({ bottom: '8vp' })
              
              Column() {
                ForEach(this.summaryData.keyPoints, (item: string, index: number) => {
                  Row() {
                    Circle({ width: '4vp', height: '4vp' })
                      .fill($r('app.color.primary_color'))
                      .margin({ right: '8vp' })
                    
                    Text(`${index + 1}. ${item}`)
                      .fontSize('13fp')
                      .fontColor($r('app.color.secondary_text_color'))
                      .lineHeight('18vp')
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ top: '4vp', bottom: '4vp' })
                })
              }
            }
            .width('100%')
            .padding({ bottom: '16vp' })
          }
          
          // 元数据信息
          Column() {
            // 分类和时长
            Row() {
              if (this.summaryData.category) {
                Column() {
                  Text(DetailConstants.AI_SUMMARY_CATEGORY)
                    .fontSize('12fp')
                    .fontColor($r('app.color.hint_text_color'))
                  
                  Text(this.summaryData.category)
                    .fontSize('13fp')
                    .fontColor(Color.Black)
                    .margin({ top: '2vp' })
                }
                .layoutWeight(1)
              }
              
              if (this.summaryData.duration) {
                Column() {
                  Text(DetailConstants.AI_SUMMARY_DURATION)
                    .fontSize('12fp')
                    .fontColor($r('app.color.hint_text_color'))
                  
                  Text(this.summaryData.duration)
                    .fontSize('13fp')
                    .fontColor(Color.Black)
                    .margin({ top: '2vp' })
                }
                .layoutWeight(1)
              }
            }
            .width('100%')
            .padding({ bottom: '12vp' })
            
            // 标签
            if (this.summaryData.tags && this.summaryData.tags.length > 0) {
              Column() {
                Text(DetailConstants.AI_SUMMARY_TAGS)
                  .fontSize('12fp')
                  .fontColor($r('app.color.hint_text_color'))
                  .margin({ bottom: '4vp' })
                
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.summaryData.tags, (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize('11fp')
                      .fontColor($r('app.color.primary_color'))
                      .backgroundColor($r('app.color.tag_background_color'))
                      .borderRadius('12vp')
                      .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
                      .margin({ right: '6vp', bottom: '6vp' })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding({ bottom: '12vp' })
            }
            
            // 生成时间
            if (this.summaryData.generatedTime) {
              Row() {
                Text(DetailConstants.AI_SUMMARY_GENERATED_TIME)
                  .fontSize('12fp')
                  .fontColor($r('app.color.hint_text_color'))
                
                Text(this.summaryData.generatedTime)
                  .fontSize('12fp')
                  .fontColor($r('app.color.secondary_text_color'))
                  .margin({ left: '8vp' })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding({ top: '12vp' })
          .borderRadius('8vp')
          .backgroundColor($r('app.color.background_color'))
          .padding({ left: '16vp', right: '16vp', top: '12vp', bottom: '12vp' })
        }
        .width('100%')
      } else {
        // 空状态
        Column() {
          Image($r('app.media.ic_public_comments'))
            .width('64vp')
            .height('64vp')
            .objectFit(ImageFit.Contain)
            .opacity(0.6)
          
          Text(DetailConstants.AI_SUMMARY_EMPTY)
            .fontSize('14fp')
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: '12vp' })
            .textAlign(TextAlign.Center)
            .maxLines(2)
          
          Button(DetailConstants.AI_SUMMARY_GENERATE, { type: ButtonType.Capsule })
            .fontSize('14fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .margin({ top: '16vp' })
            .padding({ left: '24vp', right: '24vp', top: '12vp', bottom: '12vp' })
            .onClick(() => {
              this.generateSummary();
            })
        }
        .width('100%')
        .padding({ top: '32vp', bottom: '48vp' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding({ left: '24vp', right: '24vp', bottom: '24vp' })
    .backgroundColor(Color.White)
    .borderRadius('12vp')
    .shadow({
      radius: DetailConstants.SHADOW_RADIUS,
      color: Color.Grey,
      offsetX: 0,
      offsetY: DetailConstants.SHADOW_OFFSET_Y
    })
    .margin({ top: '16vp', left: '24vp', right: '24vp' })
  }
}

