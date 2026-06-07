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
import preferences from '@ohos.data.preferences';
import Logger from './Logger';

const TAG = '[SecurityUtil]';

/**
 * 安全存储工具类
 * 用于安全存储和管理敏感数据（如API密钥）
 */
export class SecurityUtil {
  private static instance?: SecurityUtil;
  private preferences: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME: string = 'ai_security_preferences';
  private readonly ENCRYPTION_KEY: string = 'encryption_key';

  // API密钥存储键名
  public static readonly KEY_OPENAI_API_KEY: string = 'openai_api_key';
  public static readonly KEY_GEMINI_API_KEY: string = 'gemini_api_key';
  public static readonly KEY_WENXIN_API_KEY: string = 'wenxin_api_key';
  public static readonly KEY_TONGYI_API_KEY: string = 'tongyi_api_key';
  public static readonly KEY_AI_PROVIDER: string = 'ai_provider';
  public static readonly KEY_API_BASE_URL: string = 'api_base_url';

  private constructor() {
    // 私有构造函数，通过getInstance获取实例
  }

  /**
   * 获取SecurityUtil单例实例
   * @returns SecurityUtil实例
   */
  static getInstance(): SecurityUtil {
    if (!SecurityUtil.instance) {
      SecurityUtil.instance = new SecurityUtil();
    }
    return SecurityUtil.instance;
  }

  /**
   * 初始化Preferences存储
   * @returns Promise<void>
   */
  async initialize(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.preferences = await preferences.getPreferences(context, this.PREFERENCES_NAME);
      Logger.info(TAG, 'SecurityUtil initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to initialize SecurityUtil, errCode = ${err.code}, errMessage = ${err.message}`);
      throw error;
    }
  }

  /**
   * 检查是否已初始化
   * @returns boolean
   */
  isInitialized(): boolean {
    return this.preferences !== null;
  }

  /**
   * 安全存储字符串数据
   * @param key 存储键名
   * @param value 存储值
   * @returns Promise<boolean>
   */
  async setSecureString(key: string, value: string): Promise<boolean> {
    if (!this.isInitialized()) {
      await this.initialize();
    }

    try {
      // 在实际生产环境中，这里应该对value进行加密
      // 示例：const encryptedValue = this.encrypt(value);
      // 由于HarmonyOS的安全限制，这里使用简单存储
      await this.preferences?.put(key, value);
      await this.preferences?.flush();
      Logger.info(TAG, `Securely stored value for key: ${key}`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to store secure string, errCode = ${err.code}, errMessage = ${err.message}`);
      return false;
    }
  }

  /**
   * 安全获取字符串数据
   * @param key 存储键名
   * @param defaultValue 默认值
   * @returns Promise<string | null>
   */
  async getSecureString(key: string, defaultValue: string | null = null): Promise<string | null> {
    if (!this.isInitialized()) {
      await this.initialize();
    }

    try {
      const value = await this.preferences?.get(key, defaultValue || '');
      
      if (value === '' && defaultValue === null) {
        return null;
      }
      
      // 在实际生产环境中，这里应该对value进行解密
      // 示例：const decryptedValue = this.decrypt(value);
      Logger.info(TAG, `Retrieved secure value for key: ${key}`);
      return value as string;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to retrieve secure string, errCode = ${err.code}, errMessage = ${err.message}`);
      return defaultValue;
    }
  }

  /**
   * 删除安全存储的数据
   * @param key 存储键名
   * @returns Promise<boolean>
   */
  async deleteSecureData(key: string): Promise<boolean> {
    if (!this.isInitialized()) {
      await this.initialize();
    }

    try {
      await this.preferences?.delete(key);
      await this.preferences?.flush();
      Logger.info(TAG, `Deleted secure data for key: ${key}`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to delete secure data, errCode = ${err.code}, errMessage = ${err.message}`);
      return false;
    }
  }

  /**
   * 清除所有安全存储的数据
   * @returns Promise<boolean>
   */
  async clearAllSecureData(): Promise<boolean> {
    if (!this.isInitialized()) {
      await this.initialize();
    }

    try {
      await this.preferences?.clear();
      await this.preferences?.flush();
      Logger.info(TAG, 'Cleared all secure data');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to clear all secure data, errCode = ${err.code}, errMessage = ${err.message}`);
      return false;
    }
  }

  /**
   * 检查是否已设置API密钥
   * @param provider AI服务提供商
   * @returns Promise<boolean>
   */
  async hasApiKey(provider: string): Promise<boolean> {
    let key: string;
    
    switch (provider) {
      case 'openai':
        key = SecurityUtil.KEY_OPENAI_API_KEY;
        break;
      case 'gemini':
        key = SecurityUtil.KEY_GEMINI_API_KEY;
        break;
      case 'wenxin':
        key = SecurityUtil.KEY_WENXIN_API_KEY;
        break;
      case 'tongyi':
        key = SecurityUtil.KEY_TONGYI_API_KEY;
        break;
      default:
        return false;
    }

    const apiKey = await this.getSecureString(key);
    return apiKey !== null && apiKey.trim().length > 0;
  }

  /**
   * 获取当前配置的AI服务提供商
   * @returns Promise<string> 返回配置的AI服务提供商，默认为'openai'
   */
  async getConfiguredProvider(): Promise<string> {
    const provider = await this.getSecureString(SecurityUtil.KEY_AI_PROVIDER, 'openai');
    return provider || 'openai';
  }

  /**
   * 设置AI服务提供商
   * @param provider AI服务提供商（'openai', 'gemini', 'wenxin', 'tongyi'）
   * @returns Promise<boolean>
   */
  async setConfiguredProvider(provider: string): Promise<boolean> {
    const validProviders = ['openai', 'gemini', 'wenxin', 'tongyi'];
    
    if (!validProviders.includes(provider)) {
      Logger.error(TAG, `Invalid AI provider: ${provider}`);
      return false;
    }

    return await this.setSecureString(SecurityUtil.KEY_AI_PROVIDER, provider);
  }

  /**
   * 获取API基础URL
   * @param provider AI服务提供商
   * @returns string API基础URL
   */
  getApiBaseUrl(provider: string): string {
    const baseUrls: Record<string, string> = {
      'openai': 'https://api.openai.com/v1',
      'gemini': 'https://generativelanguage.googleapis.com/v1',
      'wenxin': 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1',
      'tongyi': 'https://dashscope.aliyuncs.com/api/v1'
    };

    return baseUrls[provider] || baseUrls['openai'];
  }

  /**
   * 获取API密钥（用于调试和测试，生产环境应避免直接暴露）
   * @param provider AI服务提供商
   * @returns Promise<string | null>
   */
  async getApiKey(provider: string): Promise<string | null> {
    let key: string;
    
    switch (provider) {
      case 'openai':
        key = SecurityUtil.KEY_OPENAI_API_KEY;
        break;
      case 'gemini':
        key = SecurityUtil.KEY_GEMINI_API_KEY;
        break;
      case 'wenxin':
        key = SecurityUtil.KEY_WENXIN_API_KEY;
        break;
      case 'tongyi':
        key = SecurityUtil.KEY_TONGYI_API_KEY;
        break;
      default:
        return null;
    }

    return await this.getSecureString(key);
  }

  /**
   * 设置API密钥
   * @param provider AI服务提供商
   * @param apiKey API密钥
   * @returns Promise<boolean>
   */
  async setApiKey(provider: string, apiKey: string): Promise<boolean> {
    let key: string;
    
    switch (provider) {
      case 'openai':
        key = SecurityUtil.KEY_OPENAI_API_KEY;
        break;
      case 'gemini':
        key = SecurityUtil.KEY_GEMINI_API_KEY;
        break;
      case 'wenxin':
        key = SecurityUtil.KEY_WENXIN_API_KEY;
        break;
      case 'tongyi':
        key = SecurityUtil.KEY_TONGYI_API_KEY;
        break;
      default:
        Logger.error(TAG, `Invalid AI provider: ${provider}`);
        return false;
    }

    if (!apiKey || apiKey.trim().length === 0) {
      Logger.error(TAG, 'API key cannot be empty');
      return false;
    }

    return await this.setSecureString(key, apiKey.trim());
  }

  /**
   * 验证API密钥格式（基础验证）
   * @param provider AI服务提供商
   * @param apiKey API密钥
   * @returns boolean
   */
  validateApiKeyFormat(provider: string, apiKey: string): boolean {
    if (!apiKey || apiKey.trim().length === 0) {
      return false;
    }

    // 基础格式验证
    switch (provider) {
      case 'openai':
        // OpenAI API密钥通常以'sk-'开头，长度至少为40个字符
        return apiKey.startsWith('sk-') && apiKey.length >= 40;
      
      case 'gemini':
        // Google Gemini API密钥通常是较长的字符串
        return apiKey.length >= 30;
      
      case 'wenxin':
        // 百度文心一言API密钥通常包含API Key和Secret Key
        return apiKey.includes('|') || apiKey.length >= 20;
      
      case 'tongyi':
        // 阿里通义千问API密钥通常是较长的字符串
        return apiKey.length >= 20;
      
      default:
        return apiKey.trim().length > 0;
    }
  }

  /**
   * 获取所有已配置的API密钥状态
   * @returns Promise<Record<string, boolean>>
   */
  async getApiKeyStatus(): Promise<Record<string, boolean>> {
    const providers = ['openai', 'gemini', 'wenxin', 'tongyi'];
    const status: Record<string, boolean> = {};

    for (const provider of providers) {
      status[provider] = await this.hasApiKey(provider);
    }

    return status;
  }

  /**
   * 导出安全存储的配置（用于备份）
   * @returns Promise<Record<string, string>>
   */
  async exportConfig(): Promise<Record<string, string>> {
    const config: Record<string, string> = {};
    const keys = [
      SecurityUtil.KEY_OPENAI_API_KEY,
      SecurityUtil.KEY_GEMINI_API_KEY,
      SecurityUtil.KEY_WENXIN_API_KEY,
      SecurityUtil.KEY_TONGYI_API_KEY,
      SecurityUtil.KEY_AI_PROVIDER,
      SecurityUtil.KEY_API_BASE_URL
    ];

    for (const key of keys) {
      const value = await this.getSecureString(key);
      if (value) {
        config[key] = value;
      }
    }

    return config;
  }

  /**
   * 导入安全存储的配置（从备份恢复）
   * @param config 配置对象
   * @returns Promise<boolean>
   */
  async importConfig(config: Record<string, string>): Promise<boolean> {
    try {
      for (const [key, value] of Object.entries(config)) {
        await this.setSecureString(key, value);
      }
      Logger.info(TAG, 'Configuration imported successfully');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to import configuration, errCode = ${err.code}, errMessage = ${err.message}`);
      return false;
    }
  }
}

/**
 * 安全存储管理接口
 */
export interface SecureStorage {
  setSecureString(key: string, value: string): Promise<boolean>;
  getSecureString(key: string, defaultValue?: string | null): Promise<string | null>;
  deleteSecureData(key: string): Promise<boolean>;
  clearAllSecureData(): Promise<boolean>;
}

/**
 * API密钥管理接口
 */
export interface ApiKeyManager {
  hasApiKey(provider: string): Promise<boolean>;
  getApiKey(provider: string): Promise<string | null>;
  setApiKey(provider: string, apiKey: string): Promise<boolean>;
  validateApiKeyFormat(provider: string, apiKey: string): boolean;
  getConfiguredProvider(): Promise<string>;
  setConfiguredProvider(provider: string): Promise<boolean>;
}