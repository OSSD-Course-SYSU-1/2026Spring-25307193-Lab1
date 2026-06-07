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

import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG = '[AISummaryUtil]';



/**
 * AI视频总结服务类
 * 提供视频内容分析和总结功能
 */
export class AISummaryUtil {
  private static instance?: AISummaryUtil;
  private isProcessing: boolean = false;
  private summaryCache: Map<string, VideoSummary> = new Map();

  private constructor() {
    // 初始化模拟数据
    this.initMockData();
  }

  static getInstance(): AISummaryUtil {
    if (!AISummaryUtil.instance) {
      AISummaryUtil.instance = new AISummaryUtil();
    }
    return AISummaryUtil.instance;
  }

  /**
   * 初始化模拟数据
   */
  private initMockData(): void {
    // 模拟视频总结数据
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
      },
      {
        videoId: 'video2',
        title: 'HarmonyOS开发入门教程',
        summary: '本教程详细介绍了HarmonyOS应用开发的基础知识，包括ArkTS语言特性、UI组件使用、状态管理和数据持久化等核心概念。适合初学者快速上手HarmonyOS开发。',
        keyPoints: [
          'ArkTS是基于TypeScript的声明式UI开发框架',
          'HarmonyOS支持一次开发多端部署',
          '状态管理使用@State、@Prop、@Link等装饰器',
          '分布式能力实现多设备协同'
        ],
        duration: '45分钟',
        category: '编程教程',
        tags: ['HarmonyOS', 'ArkTS', '应用开发', '教程'],
        generatedTime: '2023-04-15 10:15:00'
      },
      {
        videoId: 'video3',
        title: '智慧屏使用技巧分享',
        summary: '视频展示了华为智慧屏的各项实用功能和使用技巧，包括多屏协同、语音控制、家庭影院模式、儿童模式等，帮助用户更好地利用智慧屏提升家庭娱乐体验。',
        keyPoints: [
          '支持手机、平板、电脑等多设备投屏',
          '语音助手可控制智能家居设备',
          '4K超高清画质搭配HarmonyOS分布式音频',
          '儿童模式提供内容过滤和时间管理'
        ],
        duration: '28分钟',
        category: '产品使用',
        tags: ['智慧屏', '家庭娱乐', '多屏协同', '智能家居'],
        generatedTime: '2023-05-10 16:45:00'
      }
    ];

    // 将模拟数据添加到缓存
    mockSummaries.forEach(summary => {
      this.summaryCache.set(summary.videoId, summary);
    });
  }

  /**
   * 获取视频总结
   * @param videoId 视频ID
   * @param videoTitle 视频标题（可选，用于生成新总结）
   * @returns Promise<VideoSummary | null>
   */
  async getVideoSummary(videoId: string, videoTitle?: string): Promise<VideoSummary | null> {
    Logger.info(TAG, `Getting AI summary for video: ${videoId}`);
    
    // 检查缓存
    const cachedSummary = this.summaryCache.get(videoId);
    if (cachedSummary) {
      Logger.info(TAG, `Found cached summary for video: ${videoId}`);
      return cachedSummary;
    }

    // 如果没有缓存，生成新的总结（模拟）
    if (this.isProcessing) {
      Logger.warn(TAG, `AI summary generation is already in progress for video: ${videoId}`);
      return null;
    }

    this.isProcessing = true;
    
    try {
      // 模拟AI处理延迟
      await this.delay(2000);
      
      // 生成模拟总结
      const summary = this.generateMockSummary(videoId, videoTitle);
      this.summaryCache.set(videoId, summary);
      
      Logger.info(TAG, `Generated new AI summary for video: ${videoId}`);
      return summary;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to generate AI summary, errCode = ${err.code}, errMessage = ${err.message}`);
      return null;
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 生成模拟视频总结
   * @param videoId 视频ID
   * @param videoTitle 视频标题
   * @returns VideoSummary
   */
  private generateMockSummary(videoId: string, videoTitle?: string): VideoSummary {
    const now = new Date();
    const formattedTime = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')} ${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
    
    // 根据视频ID生成不同的总结内容
    const summaries: Array<{
      title: string;
      summary: string;
      keyPoints: string[];
      duration: string;
      category: string;
      tags: string[];
    }> = [
      {
        title: videoTitle || '华为产品发布会',
        summary: '本视频详细介绍了华为最新产品的发布情况，涵盖了智能手机、笔记本电脑、智能手表等多个品类。重点展示了产品的外观设计、技术创新和用户体验改进。',
        keyPoints: [
          '全新设计语言，采用高级材质和工艺',
          '影像系统全面升级，支持更多拍摄模式',
          '性能提升显著，续航能力增强',
          '生态系统更加完善，设备协同更流畅'
        ],
        duration: '1小时30分钟',
        category: '产品发布会',
        tags: ['华为', '新品', '科技', '创新']
      },
      {
        title: videoTitle || '技术教程视频',
        summary: '这是一个技术教程视频，详细讲解了某个技术概念或工具的使用方法。内容结构清晰，步骤详细，适合初学者学习参考。',
        keyPoints: [
          '基础概念讲解透彻易懂',
          '实际操作演示详细',
          '常见问题解决方案',
          '最佳实践建议'
        ],
        duration: '35分钟',
        category: '教育教程',
        tags: ['教程', '学习', '技术', '开发']
      },
      {
        title: videoTitle || '产品评测视频',
        summary: '本视频对某款产品进行了全面评测，包括外观设计、性能测试、使用体验和性价比分析。提供了客观的购买建议和使用技巧。',
        keyPoints: [
          '外观设计和做工评价',
          '性能测试数据和结果',
          '实际使用体验分享',
          '优缺点分析和购买建议'
        ],
        duration: '25分钟',
        category: '产品评测',
        tags: ['评测', '体验', '对比', '推荐']
      }
    ];

    // 根据视频ID选择不同的总结模板
    const index = parseInt(videoId.replace(/\D/g, '')) || 0;
    const template = summaries[index % summaries.length];
    
    return {
      videoId,
      title: template.title,
      summary: template.summary,
      keyPoints: template.keyPoints,
      duration: template.duration,
      category: template.category,
      tags: template.tags,
      generatedTime: formattedTime
    };
  }

  /**
   * 模拟延迟
   * @param ms 毫秒数
   * @returns Promise<void>
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 清除指定视频的总结缓存
   * @param videoId 视频ID
   */
  clearCache(videoId: string): void {
    this.summaryCache.delete(videoId);
    Logger.info(TAG, `Cleared cache for video: ${videoId}`);
  }

  /**
   * 清除所有缓存
   */
  clearAllCache(): void {
    this.summaryCache.clear();
    Logger.info(TAG, 'Cleared all AI summary cache');
  }

  /**
   * 检查是否正在处理
   * @returns boolean
   */
  isProcessingSummary(): boolean {
    return this.isProcessing;
  }

  /**
   * 获取缓存中的视频ID列表
   * @returns string[]
   */
  getCachedVideoIds(): string[] {
    return Array.from(this.summaryCache.keys());
  }
}

/**
 * 视频总结数据结构
 */
export interface VideoSummary {
  videoId: string;
  title: string;
  summary: string;
  keyPoints: string[];
  duration: string;
  category: string;
  tags: string[];
  generatedTime: string;
}

/**
 * AI总结生成状态
 */
export enum SummaryStatus {
  IDLE = 'idle',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  ERROR = 'error'
}

/**
 * AI总结请求参数
 */
export interface SummaryRequest {
  videoId: string;
  videoTitle?: string;
  videoDuration?: number;
  language?: string;
  maxLength?: number;
}

/**
 * AI总结响应
 */
export interface SummaryResponse {
  success: boolean;
  summary?: VideoSummary;
  error?: string;
  status: SummaryStatus;
}