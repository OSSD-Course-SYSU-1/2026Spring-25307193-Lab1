import { common, Want } from '@kit.AbilityKit';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DeviceDiscovery } from './DeviceDiscovery';

const TAG = 'RoomManager';
const DOMAIN = 0x0005;

/**
 * RoomManager - 房间管理服务
 *
 * 管理游戏房间的创建、加入、设备连接等核心功能。
 * 画板端创建房间，猜题端通过DeviceDiscovery发现画板端并加入。
 *
 * 使用startAbilityByCall建立跨设备服务连接，
 * 传递sessionId，让猜题端加入分布式数据对象组网。
 */
export class RoomManager {
  private context: common.UIAbilityContext;
  private deviceDiscovery: DeviceDiscovery;
  private sessionId: string = '';
  /** 画板端设备信息 */
  private hostDeviceId: string = '';

  /** 玩家列表变化回调 */
  private onPlayersChanged: ((devices: distributedDeviceManager.DeviceBasicInfo[]) => void) | null = null;
  /** 猜题端加入回调 */
  private onJoinRoom: ((sessionId: string, hostDeviceId: string) => void) | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.deviceDiscovery = new DeviceDiscovery(context);
  }

  /**
   * 初始化房间管理
   */
  init(): void {
    this.deviceDiscovery.initDeviceManager();
    this.deviceDiscovery.setOnDeviceListChanged((devices) => {
      if (this.onPlayersChanged) {
        // 排除本地设备
        let localId = '';
        let localInfo = this.deviceDiscovery.getLocalDeviceInfo();
        if (localInfo) {
          localId = localInfo.networkId || '';
        }
        let remoteDevices = devices.filter(d => d.networkId !== localId);
        this.onPlayersChanged(remoteDevices);
      }
    });
    // 开始发现设备
    this.deviceDiscovery.startDiscovery();
  }

  /**
   * 【画板端】创建房间
   * 生成sessionId并存储
   */
  createRoom(sessionId: string): void {
    this.sessionId = sessionId;
    let localInfo = this.deviceDiscovery.getLocalDeviceInfo();
    if (localInfo) {
      this.hostDeviceId = localInfo.networkId || '';
    }
    hilog.info(DOMAIN, TAG, `Room created, sessionId: ${this.sessionId}`);
  }

  /**
   * 【猜题端】加入房间
   * 通过发现的设备列表选择画板端设备
   */
  joinRoom(hostDeviceInfo: distributedDeviceManager.DeviceBasicInfo, sessionId: string): void {
    this.sessionId = sessionId;
    this.hostDeviceId = hostDeviceInfo.networkId || '';
    hilog.info(DOMAIN, TAG,
      `Joining room, host: ${hostDeviceInfo.deviceName}, sessionId: ${sessionId}`);

    if (this.onJoinRoom) {
      this.onJoinRoom(sessionId, hostDeviceInfo.networkId || '');
    }
  }

  /**
   * 【画板端】通过startAbilityByCall拉起猜题端应用
   * 并传递sessionId让猜题端加入组网
   */
  async inviteDevice(deviceId: string, sessionId: string): Promise<void> {
    try {
      let want: Want = {
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: this.context.abilityInfo.name,
        deviceId: deviceId,
        parameters: {
          'gameSessionId': sessionId,
          'hostDeviceId': this.hostDeviceId,
          'role': 'guesser'
        }
      };

      await this.context.startAbilityByCall(want);
      hilog.info(DOMAIN, TAG, `Invited device: ${deviceId}`);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG,
        `startAbilityByCall failed: ${error.code}, ${error.message}`);
    }
  }

  /**
   * 获取可用设备列表（排除本地设备）
   */
  getAvailableDevices(): distributedDeviceManager.DeviceBasicInfo[] {
    let allDevices = this.deviceDiscovery.getDeviceList();
    let localId = '';
    let localInfo = this.deviceDiscovery.getLocalDeviceInfo();
    if (localInfo) {
      localId = localInfo.networkId || '';
    }
    return allDevices.filter(d => d.networkId !== localId);
  }

  /**
   * 获取画板端设备ID
   */
  getHostDeviceId(): string {
    return this.hostDeviceId;
  }

  /**
   * 获取sessionId
   */
  getSessionId(): string {
    return this.sessionId;
  }

  /**
   * 获取本地设备名称
   */
  getLocalDeviceName(): string {
    let localInfo = this.deviceDiscovery.getLocalDeviceInfo();
    return localInfo?.deviceName || '未知设备';
  }

  /**
   * 获取本地networkId
   */
  getLocalNetworkId(): string {
    let localInfo = this.deviceDiscovery.getLocalDeviceInfo();
    return localInfo?.networkId || '';
  }

  /**
   * 设置玩家列表变化回调
   */
  setOnPlayersChanged(callback: (devices: distributedDeviceManager.DeviceBasicInfo[]) => void): void {
    this.onPlayersChanged = callback;
  }

  /**
   * 设置猜题端加入房间回调
   */
  setOnJoinRoom(callback: (sessionId: string, hostDeviceId: string) => void): void {
    this.onJoinRoom = callback;
  }

  /**
   * 释放资源
   */
  release(): void {
    this.deviceDiscovery.release();
  }
}
