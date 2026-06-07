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

import Logger from './Logger';

const TAG = '[AIConfig]';

/**
 * AI服务提供商枚举
 */
export enum AIProvider {
  OPENAI = 'openai',
  GEMINI = 'gemini',
  WENXIN = 'wenxin',
  TONGYI = 'tongyi',
  MOCK = 'mock' // 模拟数据模式
}

/**
 * AI模型配置
 */
export interface AIModelConfig {
  provider: AIProvider;
  model: string;
  maxTokens: number;
  temperature: number;
  topP: number;
  frequencyPenalty: number;
  presencePenalty: number;
}

/**
 * AI API请求配置
 */
export interface AIRequestConfig {
  url: string;
  method: string;
  headers: Record<string, string>;
  timeout: number; // 毫秒
  retryCount: number;
  retryDelay: number; // 毫秒
}

/**
 * AI服务配置类
 */
export class AIConfig {
  private static instance?: AIConfig;
  private provider: AIProvider = AIProvider.MOCK; // 默认使用模拟数据
  private modelConfigs: Record<AIProvider, AIModelConfig> = {
    [AIProvider.OPENAI]: {
      provider: AIProvider.OPENAI,
      model: 'gpt-3.5-turbo',
      maxTokens: 500,
      temperature: 0.7,
      topP: 0.9,
      frequencyPenalty: 0.0,
      presencePenalty: 0.0
    },
    [AIProvider.GEMINI]: {
      provider: AIProvider.GEMINI,
      model: 'gemini-pro',
      maxTokens: 500,
      temperature: 0.7,
      topP: 0.9,
      frequencyPenalty: 0.0,
      presencePenalty: 0.0
    },
    [AIProvider.WENXIN]: {
      provider: AIProvider.WENXIN,
      model: 'ERNIE-Bot-turbo',
      maxTokens: 500,
      temperature: 0.7,
      topP: 0.9,
      frequencyPenalty: 0.0,
      presencePenalty: 0.0
    },
    [AIProvider.TONGYI]: {
      provider: AIProvider.TONGYI,
      model: 'qwen-turbo',
      maxTokens: 500,
      temperature: 0.7,
      topP: 0.9,
      frequencyPenalty: 0.0,
      presencePenalty: 0.0
    },
    [AIProvider.MOCK]: {
      provider: AIProvider.MOCK,
      model: 'mock-model',
      maxTokens: 500,
      temperature: 0.7,
      topP: 0.9,
      frequencyPenalty: 0.0,
      presencePenalty: 0.0
    }
  };

  private requestConfigs: Record<AIProvider, AIRequestConfig> = {
    [AIProvider.OPENAI]: {
      url: 'https://api.openai.com/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_API_KEY' // 将在运行时替换
      },
      timeout: 30000,
      retryCount: 3,
      retryDelay: 1000
    },
    [AIProvider.GEMINI]: {
      url: 'https://generativelanguage.googleapis.com/v1/models/{model}:generateContent',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      retryCount: 3,
      retryDelay: 1000
    },
    [AIProvider.WENXIN]: {
      url: 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      timeout: 30000,
      retryCount: 3,
      retryDelay: 1000
    },
    [AIProvider.TONGYI]: {
      url: 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_API_KEY' // 将在运行时替换
      },
      timeout: 30000,
      retryCount: 3,
      retryDelay: 1000
    },
    [AIProvider.MOCK]: {
      url: 'mock://localhost/mock-ai',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 2000, // 模拟延迟
      retryCount: 0,
      retryDelay: 0
    }
  };

  private constructor() {
    // 私有构造函数
  }

  /**
   * 获取AIConfig单例实例
   * @returns AIConfig实例
   */
  static getInstance(): AIConfig {
    if (!AIConfig.instance) {
      AIConfig.instance = new AIConfig();
    }
    return AIConfig.instance;
  }

  /**
   * 设置AI服务提供商
   * @param provider AI服务提供商
   */
  setProvider(provider: AIProvider): void {
    if (Object.values(AIProvider).includes(provider)) {
      this.provider = provider;
      Logger.info(TAG, `AI provider set to: ${provider}`);
    } else {
      Logger.error(TAG, `Invalid AI provider: ${provider}`);
    }
  }

  /**
   * 获取当前AI服务提供商
   * @returns AIProvider
   */
  getProvider(): AIProvider {
    return this.provider;
  }

  /**
   * 获取当前提供商的模型配置
   * @returns AIModelConfig
   */
  getModelConfig(): AIModelConfig {
    return this.modelConfigs[this.provider];
  }

  /**
   * 获取当前提供商的请求配置
   * @returns AIRequestConfig
   */
  getRequestConfig(): AIRequestConfig {
    return this.requestConfigs[this.provider];
  }

  /**
   * 更新模型配置
   * @param provider AI服务提供商
   * @param config 模型配置
   */
  updateModelConfig(provider: AIProvider, config: Partial<AIModelConfig>): void {
    if (this.modelConfigs[provider]) {
      this.modelConfigs[provider] = { ...this.modelConfigs[provider], ...config };
      Logger.info(TAG, `Updated model config for provider: ${provider}`);
    }
  }

  /**
   * 更新请求配置
   * @param provider AI服务提供商
   * @param config 请求配置
   */
  updateRequestConfig(provider: AIProvider, config: Partial<AIRequestConfig>): void {
    if (this.requestConfigs[provider]) {
      this.requestConfigs[provider] = { ...this.requestConfigs[provider], ...config };
      Logger.info(TAG, `Updated request config for provider: ${provider}`);
    }
  }

  /**
   * 设置API密钥到请求头
   * @param apiKey API密钥
   * @returns boolean 是否设置成功
   */
  setApiKey(apiKey: string): boolean {
    if (!apiKey || apiKey.trim().length === 0) {
      Logger.error(TAG, 'API key cannot be empty');
      return false;
    }

    const provider = this.provider;
    const requestConfig = this.requestConfigs[provider];

    switch (provider) {
      case AIProvider.OPENAI:
        requestConfig.headers['Authorization'] = `Bearer ${apiKey}`;
        break;
      case AIProvider.GEMINI:
        // Gemini API密钥通过URL参数传递
        requestConfig.url = requestConfig.url.replace('{model}', this.modelConfigs[provider].model);
        requestConfig.url += `?key=${apiKey}`;
        break;
      case AIProvider.WENXIN:
        // 文心一言API密钥通过URL参数传递
        requestConfig.url += `?access_token=${apiKey}`;
        break;
      case AIProvider.TONGYI:
        requestConfig.headers['Authorization'] = `Bearer ${apiKey}`;
        break;
      case AIProvider.MOCK:
        // 模拟模式不需要API密钥
        break;
      default:
        Logger.error(TAG, `Unsupported provider for API key: ${provider}`);
        return false;
    }

    Logger.info(TAG, `API key set for provider: ${provider}`);
    return true;
  }

  /**
   * 验证当前配置是否有效
   * @returns boolean
   */
  isValid(): boolean {
    const provider = this.provider;
    const requestConfig = this.requestConfigs[provider];

    if (provider === AIProvider.MOCK) {
      return true; // 模拟模式始终有效
    }

    // 检查必要的请求头
    if (provider === AIProvider.OPENAI || provider === AIProvider.TONGYI) {
      const authHeader = requestConfig.headers['Authorization'];
      if (!authHeader || authHeader === 'Bearer YOUR_API_KEY') {
        Logger.warn(TAG, `API key not set for provider: ${provider}`);
        return false;
      }
    }

    // 检查URL
    if (!requestConfig.url || requestConfig.url.includes('YOUR_API_KEY')) {
      Logger.warn(TAG, `Invalid URL for provider: ${provider}`);
      return false;
    }

    return true;
  }

  /**
   * 获取所有支持的AI服务提供商
   * @returns AIProvider[]
   */
  getAllProviders(): AIProvider[] {
    return Object.values(AIProvider);
  }

  /**
   * 获取提供商显示名称
   * @param provider AI服务提供商
   * @returns string 显示名称
   */
  getProviderDisplayName(provider: AIProvider): string {
    const displayNames: Record<AIProvider, string> = {
      [AIProvider.OPENAI]: 'OpenAI GPT',
      [AIProvider.GEMINI]: 'Google Gemini',
      [AIProvider.WENXIN]: '百度文心一言',
      [AIProvider.TONGYI]: '阿里通义千问',
      [AIProvider.MOCK]: '模拟数据'
    };

    return displayNames[provider] || provider;
  }

  /**
   * 获取提供商描述
   * @param provider AI服务提供商
   * @returns string 描述
   */
  getProviderDescription(provider: AIProvider): string {
    const descriptions: Record<AIProvider, string> = {
      [AIProvider.OPENAI]: 'OpenAI的GPT系列模型，提供强大的自然语言处理能力',
      [AIProvider.GEMINI]: 'Google的Gemini模型，支持多模态理解和生成',
      [AIProvider.WENXIN]: '百度的文心一言模型，中文理解能力强',
      [AIProvider.TONGYI]: '阿里的通义千问模型，中文场景优化',
      [AIProvider.MOCK]: '本地模拟数据，无需网络和API密钥'
    };

    return descriptions[provider] || '未知AI服务提供商';
  }

  /**
   * 获取提供商官方网站
   * @param provider AI服务提供商
   * @returns string 官方网站URL
   */
  getProviderWebsite(provider: AIProvider): string {
    const websites: Record<AIProvider, string> = {
      [AIProvider.OPENAI]: 'https://platform.openai.com',
      [AIProvider.GEMINI]: 'https://ai.google.dev',
      [AIProvider.WENXIN]: 'https://yiyan.baidu.com',
      [AIProvider.TONGYI]: 'https://tongyi.aliyun.com',
      [AIProvider.MOCK]: ''
    };

    return websites[provider] || '';
  }

  /**
   * 获取提供商API文档
   * @param provider AI服务提供商
   * @returns string API文档URL
   */
  getProviderApiDocs(provider: AIProvider): string {
    const apiDocs: Record<AIProvider, string> = {
      [AIProvider.OPENAI]: 'https://platform.openai.com/docs/api-reference',
      [AIProvider.GEMINI]: 'https://ai.google.dev/gemini-api/docs',
      [AIProvider.WENXIN]: 'https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html',
      [AIProvider.TONGYI]: 'https://help.aliyun.com/zh/dashscope/developer-reference/api-details',
      [AIProvider.MOCK]: ''
    };

    return apiDocs[provider] || '';
  }

  /**
   * 获取默认提示词模板
   * @returns string 提示词模板
   */
  getDefaultPromptTemplate(): string {
    return `请分析以下视频内容并生成总结：

视频标题：{{videoTitle}}
视频时长：{{videoDuration}}

请生成以下内容的总结：
1. 视频主要内容概述（100-150字）
2. 3-5个关键要点
3. 视频分类（如：科技、教育、娱乐等）
4. 相关标签（3-5个）

请用中文回答，保持专业且易于理解。`;
  }

  /**
   * 构建完整的提示词
   * @param videoTitle 视频标题
   * @param videoDuration 视频时长（可选）
   * @returns string 完整的提示词
   */
  buildPrompt(videoTitle: string, videoDuration?: string): string {
    let prompt = this.getDefaultPromptTemplate();
    prompt = prompt.replace('{{videoTitle}}', videoTitle);
    
    if (videoDuration) {
      prompt = prompt.replace('{{videoDuration}}', videoDuration);
    } else {
      prompt = prompt.replace('视频时长：{{videoDuration}}', '');
    }
    
    return prompt;
  }

  /**
   * 获取提供商特定的请求体模板
   * @param prompt 提示词
   * @returns Record<string, any> 请求体
   */
  getRequestBody(prompt: string): Record<string, any> {
    const modelConfig = this.getModelConfig();
    
    switch (this.provider) {
      case AIProvider.OPENAI:
        return {
          model: modelConfig.model,
          messages: [
            {
              role: 'system',
              content: '你是一个专业的视频内容分析助手，擅长总结视频内容并提取关键信息。'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          max_tokens: modelConfig.maxTokens,
          temperature: modelConfig.temperature,
          top_p: modelConfig.topP,
          frequency_penalty: modelConfig.frequencyPenalty,
          presence_penalty: modelConfig.presencePenalty
        };
      
      case AIProvider.GEMINI:
        return {
          contents: [
            {
              parts: [
                {
                  text: prompt
                }
              ]
            }
          ],
          generationConfig: {
            maxOutputTokens: modelConfig.maxTokens,
            temperature: modelConfig.temperature,
            topP: modelConfig.topP
          }
        };
      
      case AIProvider.WENXIN:
        return {
          messages: [
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: modelConfig.temperature,
          top_p: modelConfig.topP,
          penalty_score: modelConfig.frequencyPenalty
        };
      
      case AIProvider.TONGYI:
        return {
          model: modelConfig.model,
          input: {
            messages: [
              {
                role: 'user',
                content: prompt
              }
            ]
          },
          parameters: {
            max_tokens: modelConfig.maxTokens,
            temperature: modelConfig.temperature,
            top_p: modelConfig.topP,
            repetition_penalty: 1.0 + modelConfig.frequencyPenalty
          }
        };
      
      case AIProvider.MOCK:
        return {
          prompt: prompt,
          mock: true
        };
      
      default:
        return {
          prompt: prompt
        };
    }
  }
}

/**
 * AI配置管理器接口
 */
export interface AIConfigManager {
  setProvider(provider: AIProvider): void;
  getProvider(): AIProvider;
  getModelConfig(): AIModelConfig;
  getRequestConfig(): AIRequestConfig;
  setApiKey(apiKey: string): boolean;
  isValid(): boolean;
  buildPrompt(videoTitle: string, videoDuration?: string): string;
  getRequestBody(prompt: string): Record<string, any>;
}