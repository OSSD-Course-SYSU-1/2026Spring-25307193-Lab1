# AI视频总结功能 - 真实AI服务接入指南

## 📋 概述

本文档详细指导如何将多设备长视频应用中的AI视频总结功能从模拟数据模式迁移到真实AI服务。当前项目已实现完整的AI总结UI界面和模拟数据逻辑，本指南将帮助您连接真实的AI服务提供商（如OpenAI、Google Gemini、百度文心一言、阿里通义千问等）。

## 🎯 迁移目标

- ✅ **从模拟数据到真实API**：替换现有的模拟数据生成逻辑为真实AI服务调用
- ✅ **安全存储API密钥**：使用HarmonyOS安全存储机制保护敏感信息
- ✅ **多AI服务商支持**：支持主流AI服务提供商，可轻松切换
- ✅ **完整的错误处理**：处理网络错误、API限制、认证失败等情况
- ✅ **性能优化**：保持现有的缓存机制，减少不必要的API调用

## 📁 新增文件说明

### 1. **SecurityUtil.ets** - 安全存储工具类
**位置**: `common/base/src/main/ets/utils/SecurityUtil.ets`

**功能**:
- 安全存储和管理API密钥等敏感信息
- 支持多AI服务提供商密钥管理
- 使用HarmonyOS的`@ohos.data.preferences`进行安全存储
- 提供API密钥格式验证和配置管理

**核心方法**:
```typescript
// 设置API密钥
await SecurityUtil.getInstance().setApiKey('openai', 'your-api-key-here');

// 获取API密钥
const apiKey = await SecurityUtil.getInstance().getApiKey('openai');

// 检查API密钥状态
const hasKey = await SecurityUtil.getInstance().hasApiKey('openai');
```

### 2. **AIConfig.ets** - AI配置管理类
**位置**: `common/base/src/main/ets/utils/AIConfig.ets`

**功能**:
- 管理AI服务提供商配置（OpenAI、Gemini、文心一言、通义千问）
- 提供模型参数配置（temperature、maxTokens等）
- 构建API请求体和提示词
- 支持模拟数据模式（用于开发和测试）

**核心方法**:
```typescript
// 设置AI服务提供商
AIConfig.getInstance().setProvider(AIProvider.OPENAI);

// 设置API密钥
AIConfig.getInstance().setApiKey('your-api-key-here');

// 构建提示词
const prompt = AIConfig.getInstance().buildPrompt('视频标题', '2小时15分钟');

// 获取请求体
const requestBody = AIConfig.getInstance().getRequestBody(prompt);
```

## 🔧 迁移步骤

### 步骤1: 添加网络权限

在`module.json5`文件中添加网络权限：

**对于default模块** (`products/default/src/main/module.json5`):
```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.GET_NETWORK_INFO"
      }
    ]
  }
}
```

**对于tv模块** (`products/tv/src/main/module.json5`):
```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.GET_NETWORK_INFO"
      }
    ]
  }
}
```

### 步骤2: 更新依赖配置

在`oh-package.json5`中添加必要的依赖（如果尚未添加）：
```json
{
  "dependencies": {
    "@ohos/data.preferences": "1.0.0",
    "@ohos.net.http": "1.0.0",
    "@ohos.net.connection": "1.0.0"
  }
}
```

### 步骤3: 修改AISummaryUtil.ets

将现有的模拟数据生成逻辑替换为真实的API调用。主要修改`generateMockSummary`方法为`generateRealSummary`：

**关键修改点**:
1. 导入新的工具类
2. 添加HTTP请求逻辑
3. 实现错误处理和重试机制
4. 保持现有的缓存机制

**示例代码片段**:
```typescript
import { AIConfig, AIProvider } from './AIConfig';
import { SecurityUtil } from './SecurityUtil';
import http from '@ohos.net.http';

private async callAIAPI(prompt: string): Promise<string> {
  const aiConfig = AIConfig.getInstance();
  const requestConfig = aiConfig.getRequestConfig();
  const requestBody = aiConfig.getRequestBody(prompt);
  
  try {
    const httpRequest = http.createHttp();
    const response = await httpRequest.request(
      requestConfig.url,
      {
        method: http.RequestMethod.POST,
        header: requestConfig.headers,
        extraData: JSON.stringify(requestBody),
        connectTimeout: requestConfig.timeout,
        readTimeout: requestConfig.timeout
      }
    );
    
    if (response.responseCode === 200) {
      return this.parseAIResponse(response.result as string);
    } else {
      throw new Error(`API request failed with status: ${response.responseCode}`);
    }
  } catch (error) {
    Logger.error(TAG, `AI API call failed: ${error}`);
    throw error;
  }
}
```

### 步骤4: 创建API密钥配置界面

创建一个简单的设置界面，让用户输入和管理API密钥：

**创建文件**: `features/settings/src/main/ets/view/AISettings.ets`

**功能**:
- 选择AI服务提供商
- 输入和保存API密钥
- 测试API连接
- 查看当前配置状态

### 步骤5: 更新AISummary组件

修改`AISummary.ets`组件，添加API密钥状态检查和用户引导：

**添加功能**:
1. 检查API密钥是否已配置
2. 如果未配置，显示配置引导
3. 添加重试机制和错误处理
4. 显示API调用状态

## 🔐 API密钥获取指南

### OpenAI
1. 访问 [OpenAI平台](https://platform.openai.com)
2. 注册/登录账户
3. 进入"API Keys"页面
4. 点击"Create new secret key"
5. 复制生成的API密钥（以`sk-`开头）

**费用**: 按使用量计费，具体参考[定价页面](https://openai.com/pricing)

### Google Gemini
1. 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 使用Google账户登录
3. 创建API密钥
4. 复制生成的API密钥

**费用**: 免费额度充足，超出后按使用量计费

### 百度文心一言
1. 访问 [百度智能云](https://cloud.baidu.com/product/wenxinworkshop)
2. 注册/登录百度账号
3. 创建应用并获取API Key和Secret Key
4. 使用API Key和Secret Key获取Access Token

**费用**: 有免费额度，超出后按调用次数计费

### 阿里通义千问
1. 访问 [阿里云百炼](https://bailian.console.aliyun.com)
2. 注册/登录阿里云账号
3. 创建API密钥
4. 复制生成的API密钥

**费用**: 新用户有免费额度，具体参考[定价页面](https://help.aliyun.com/zh/dashscope/pricing)

## 🧪 测试和调试

### 测试步骤1: 验证网络权限
```bash
# 构建应用并检查权限
hvigorw assembleRelease
```

### 测试步骤2: 测试API密钥存储
```typescript
// 在应用的入口点测试SecurityUtil
async function testSecurityUtil() {
  const securityUtil = SecurityUtil.getInstance();
  await securityUtil.initialize();
  
  // 测试存储和读取
  await securityUtil.setApiKey('openai', 'test-key-123');
  const storedKey = await securityUtil.getApiKey('openai');
  console.log('Stored key:', storedKey); // 应该输出'test-key-123'
}
```

### 测试步骤3: 测试API连接
```typescript
// 创建测试函数验证API连接
async function testAIConnection() {
  const aiConfig = AIConfig.getInstance();
  aiConfig.setProvider(AIProvider.OPENAI);
  
  // 设置测试API密钥
  const securityUtil = SecurityUtil.getInstance();
  await securityUtil.setApiKey('openai', 'your-test-api-key');
  
  const aiSummaryUtil = AISummaryUtil.getInstance();
  const summary = await aiSummaryUtil.getVideoSummary('test-video', '测试视频标题');
  
  if (summary) {
    console.log('API连接测试成功:', summary);
  } else {
    console.error('API连接测试失败');
  }
}
```

### 测试步骤4: 模拟模式测试
在开发阶段，可以使用模拟模式进行测试：
```typescript
// 切换到模拟模式
const aiConfig = AIConfig.getInstance();
aiConfig.setProvider(AIProvider.MOCK);

// 测试AI总结功能
const aiSummaryUtil = AISummaryUtil.getInstance();
const summary = await aiSummaryUtil.getVideoSummary('video1', '测试视频');
```

## 🔄 错误处理和监控

### 常见错误及解决方案

#### 1. 网络连接错误
**症状**: `ERR_CONNECTION_TIMED_OUT` 或 `ERR_NETWORK_CHANGED`
**解决方案**:
- 检查设备网络连接
- 验证网络权限配置
- 增加请求超时时间
- 实现自动重试机制

#### 2. API认证错误
**症状**: `401 Unauthorized` 或 `403 Forbidden`
**解决方案**:
- 验证API密钥是否正确
- 检查API密钥是否已过期
- 确认API服务是否启用
- 检查请求头中的认证信息

#### 3. 配额限制错误
**症状**: `429 Too Many Requests`
**解决方案**:
- 实现请求频率限制
- 添加请求队列
- 使用指数退避重试策略
- 提示用户升级API套餐

#### 4. 响应解析错误
**症状**: `JSON parse error` 或 `Unexpected response format`
**解决方案**:
- 添加响应格式验证
- 实现容错解析逻辑
- 记录原始响应用于调试
- 提供用户友好的错误信息

### 监控指标
1. **API调用成功率**: 监控成功/失败比例
2. **响应时间**: 记录API调用耗时
3. **缓存命中率**: 监控缓存使用效率
4. **错误类型分布**: 分析各类错误发生频率

## 🚀 性能优化建议

### 1. 缓存策略优化
```typescript
// 实现智能缓存过期策略
private async getVideoSummaryWithCache(videoId: string, videoTitle?: string): Promise<VideoSummary | null> {
  // 检查缓存
  const cachedSummary = this.summaryCache.get(videoId);
  if (cachedSummary) {
    // 检查缓存是否过期（例如24小时）
    const cacheTime = new Date(cachedSummary.generatedTime).getTime();
    const currentTime = new Date().getTime();
    const cacheAge = currentTime - cacheTime;
    
    if (cacheAge < 24 * 60 * 60 * 1000) { // 24小时
      return cachedSummary;
    }
  }
  
  // 缓存过期或不存在，调用API
  return await this.generateRealSummary(videoId, videoTitle);
}
```

### 2. 请求批处理
对于批量视频总结需求，可以实现请求批处理：
```typescript
async getBatchVideoSummaries(videoIds: string[]): Promise<Map<string, VideoSummary>> {
  const results = new Map<string, VideoSummary>();
  
  // 分批处理，避免一次性请求过多
  const batchSize = 5;
  for (let i = 0; i < videoIds.length; i += batchSize) {
    const batch = videoIds.slice(i, i + batchSize);
    const batchPromises = batch.map(id => this.getVideoSummary(id));
    const batchResults = await Promise.all(batchPromises);
    
    batchResults.forEach((summary, index) => {
      if (summary) {
        results.set(batch[index], summary);
      }
    });
    
    // 批次间延迟，避免触发API限制
    await this.delay(1000);
  }
  
  return results;
}
```

### 3. 离线模式支持
```typescript
// 检查网络状态
import network from '@ohos.net.connection';

async isNetworkAvailable(): Promise<boolean> {
  try {
    const netHandle = connection.getDefaultNet();
    const netCapabilities = await netHandle.getNetCapabilities();
    return netCapabilities !== null;
  } catch (error) {
    return false;
  }
}

// 智能选择模式
async getVideoSummarySmart(videoId: string, videoTitle?: string): Promise<VideoSummary | null> {
  const isOnline = await this.isNetworkAvailable();
  
  if (!isOnline) {
    // 离线模式：只返回缓存数据
    const cachedSummary = this.summaryCache.get(videoId);
    if (cachedSummary) {
      return cachedSummary;
    } else {
      throw new Error('网络不可用且无缓存数据');
    }
  }
  
  // 在线模式：正常调用API
  return await this.getVideoSummary(videoId, videoTitle);
}
```

## 📱 多设备适配注意事项

### 手机/平板/电脑设备
- **网络状态检测**: 实时检测Wi-Fi/移动数据状态
- **数据使用优化**: 在移动网络下使用压缩数据格式
- **离线缓存**: 优先使用缓存数据，减少流量消耗

### 智慧屏设备
- **大屏UI优化**: 调整字体大小和布局间距
- **遥控器导航**: 支持方向键和确认键操作
- **后台处理**: 利用智慧屏更强的处理能力进行本地缓存管理

## 🔧 开发环境配置

### 1. 开发阶段配置
在开发阶段，建议使用模拟模式或测试API密钥：
```typescript
// 开发环境配置
const isDevelopment = true; // 根据构建环境设置

if (isDevelopment) {
  // 使用模拟模式或测试密钥
  AIConfig.getInstance().setProvider(AIProvider.MOCK);
  // 或使用测试API密钥
  await SecurityUtil.getInstance().setApiKey('openai', 'test-sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
}
```

### 2. 生产环境配置
在生产环境，通过安全的方式配置API密钥：
- 使用环境变量或配置文件
- 实现动态密钥更新机制
- 定期轮换API密钥
- 监控API使用量和费用

### 3. 构建配置
在`build-profile.json5`中添加环境变量配置：
```json
{
  "app": {
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compileSdkVersion": 10,
        "compatibleSdkVersion": 10,
        "runtimeOS": "HarmonyOS",
        "buildMode": "debug",
        "env": {
          "AI_API_MODE": "mock" // 或 "production"
        }
      }
    ]
  }
}
```

## 🐛 故障排除

### 常见问题1: 网络权限问题
**问题**: 应用无法访问网络，API调用失败
**解决方案**:
1. 检查`module.json5`中的权限配置
2. 确认设备网络连接正常
3. 验证防火墙或代理设置
4. 重启应用或设备

### 常见问题2: API密钥无效
**问题**: API返回401或403错误
**解决方案**:
1. 验证API密钥格式是否正确
2. 检查API密钥是否已过期
3. 确认API服务是否已启用
4. 验证账户余额或配额

### 常见问题3: 响应解析失败
**问题**: JSON解析错误或响应格式不符预期
**解决方案**:
1. 检查API响应格式是否符合文档
2. 添加响应验证逻辑
3. 记录原始响应用于调试
4. 更新API SDK或适配器

### 常见问题4: 性能问题
**问题**: API响应缓慢或应用卡顿
**解决方案**:
1. 优化缓存策略
2. 实现请求队列和限流
3. 使用更轻量的模型
4. 添加加载状态和进度提示

## 📞 支持与反馈

### 获取帮助
1. **查看日志**: 使用`Logger`类记录详细日志
2. **调试模式**: 启用调试模式获取更多信息
3. **社区支持**: 访问HarmonyOS开发者社区
4. **官方文档**: 参考AI服务提供商官方文档

### 提交问题
遇到问题时，请提供以下信息：
1. 错误日志和堆栈跟踪
2. 复现步骤
3. 设备信息和系统版本
4. 网络环境描述
5. API密钥类型和配置

### 贡献指南
欢迎提交改进建议和代码贡献：
1. Fork项目仓库
2. 创建功能分支
3. 提交更改
4. 创建Pull Request
5. 添加测试用例和文档更新

## 📄 许可证

本项目基于Apache License 2.0许可证开源。AI服务提供商可能有其自己的使用条款和条件，请在使用前仔细阅读相关服务协议。

## 🔄 更新日志

### v1.0.0 (2024-06-03)
- 初始版本：从模拟AI迁移到真实AI服务的完整指南
- 支持OpenAI、Google Gemini、百度文心一言、阿里通义千问
- 提供安全存储、错误处理、性能优化等完整解决方案

---

**最后更新**: 2024年6月3日  
**维护者**: 多设备长视频应用开发团队  
**文档版本**: 1.0.0

> **注意**: 本指南假设您已具备基本的HarmonyOS开发经验。如果您在实施过程中遇到问题，请参考相关AI服务提供商的官方文档或寻求社区帮助。