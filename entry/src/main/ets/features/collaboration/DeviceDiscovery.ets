import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'DeviceDiscovery';
const DOMAIN = 0x0004;

/**
 * DeviceDiscovery - 设备发现与组网工具
 *
 * 使用HarmonyOS分布式软总线实现设备自动发现和组网。
 * 同一华为账号且打开Wi-Fi蓝牙的设备会自动被识别。
 *
 * 【工作原理】
 * 1. 调用distributedDeviceManager.createDeviceManager()创建设备管理实例
 * 2. 使用getAvailableDeviceListSync()获取可信组网内的设备列表
 * 3. 通过设备状态监听感知设备上下线变化
 */
export class DeviceDiscovery {
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private context: common.UIAbilityContext;
  private deviceList: distributedDeviceManager.DeviceBasicInfo[] = [];
  private onDeviceListChanged: ((devices: distributedDeviceManager.DeviceBasicInfo[]) => void) | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 初始化设备管理器
   * 创建分布式设备管理实例并注册设备状态监听
   */
  initDeviceManager(): boolean {
    try {
      this.deviceManager = distributedDeviceManager.createDeviceManager(
        this.context.abilityInfo.bundleName
      );
      hilog.info(DOMAIN, TAG, 'DeviceManager created successfully');

      // 注册设备状态变化监听
      this.deviceManager.on('deviceStateChange', (data) => {
        hilog.info(DOMAIN, TAG,
          `Device state change: ${data.action}, device: ${data.device?.deviceName}`);
        this.refreshDeviceList();
      });

      // 注册设备发现成功监听
      this.deviceManager.on('discoverSuccess', (device) => {
        hilog.info(DOMAIN, TAG, `Device discovered: ${device.device.deviceName}`);
        this.refreshDeviceList();
      });

      // 初始化设备列表
      this.refreshDeviceList();
      return true;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG,
        `Create deviceManager failed: ${error.code}, ${error.message}`);
      return false;
    }
  }

  /**
   * 刷新可用设备列表
   * 通过分布式软总线获取当前组网内的所有可信设备
   */
  refreshDeviceList(): void {
    if (!this.deviceManager) {
      return;
    }
    try {
      let devices = this.deviceManager.getAvailableDeviceListSync();
      this.deviceList = devices || [];
      hilog.info(DOMAIN, TAG, `Available devices count: ${this.deviceList.length}`);

      if (this.onDeviceListChanged) {
        this.onDeviceListChanged([...this.deviceList]);
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `getAvailableDeviceListSync failed: ${error.message}`);
    }
  }

  /**
   * 获取本地设备信息
   */
  getLocalDeviceInfo(): distributedDeviceManager.DeviceBasicInfo | null {
    if (!this.deviceManager) {
      return null;
    }
    try {
      let localInfo = this.deviceManager.getLocalDeviceNetworkId();
      hilog.info(DOMAIN, TAG, `Local networkId: ${localInfo}`);
      // 从设备列表中查找本地设备
      for (let device of this.deviceList) {
        if (device.networkId === localInfo) {
          return device;
        }
      }
      return null;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `getLocalDeviceInfo failed: ${error.message}`);
      return null;
    }
  }

  /**
   * 获取设备列表
   */
  getDeviceList(): distributedDeviceManager.DeviceBasicInfo[] {
    return [...this.deviceList];
  }

  /**
   * 设置设备列表变化回调
   */
  setOnDeviceListChanged(
    callback: (devices: distributedDeviceManager.DeviceBasicInfo[]) => void
  ): void {
    this.onDeviceListChanged = callback;
  }

  /**
   * 启动设备发现
   */
  startDiscovery(): void {
    if (!this.deviceManager) {
      return;
    }
    try {
      this.deviceManager.startDiscovering({
        // 发现所有类型的可信设备
        filterOptions: {}
      });
      hilog.info(DOMAIN, TAG, 'Device discovery started');
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `startDiscovering failed: ${error.message}`);
    }
  }

  /**
   * 停止设备发现
   */
  stopDiscovery(): void {
    if (!this.deviceManager) {
      return;
    }
    try {
      this.deviceManager.stopDiscovering();
      hilog.info(DOMAIN, TAG, 'Device discovery stopped');
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `stopDiscovering failed: ${error.message}`);
    }
  }

  /**
   * 释放资源
   */
  release(): void {
    this.stopDiscovery();
    if (this.deviceManager) {
      this.deviceManager.off('deviceStateChange');
      this.deviceManager.off('discoverSuccess');
    }
    this.deviceManager = null;
    this.onDeviceListChanged = null;
  }
}
