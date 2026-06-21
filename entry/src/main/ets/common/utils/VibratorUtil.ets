import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'VibratorUtil';
const DOMAIN = 0x0002;

/**
 * VibratorUtil - 震动工具类
 *
 * 使用canIUse检测设备是否支持震动功能（SysCap兼容性检测）。
 * 当猜题端答对时，如果设备支持震动则震动100ms提示；
 * 不支持则静默处理，确保在不支持震动的设备上也能正常运行。
 */
export class VibratorUtil {

  /**
   * 检查设备是否支持震动
   * 使用canIUse检测SystemCapability，实现SysCap兼容性判断
   */
  static isVibratorSupported(): boolean {
    return canIUse('SystemCapability.Sensors.MiscDevice.Vibrator');
  }

  /**
   * 震动100ms - 答对时的反馈
   * 如果设备不支持震动则静默处理
   */
  static vibrateCorrect(): void {
    if (!VibratorUtil.isVibratorSupported()) {
      hilog.info(DOMAIN, TAG, 'Vibrator not supported on this device, skip vibrate');
      return;
    }

    try {
      vibrator.startVibration({
        type: 'time',
        duration: 100  // 震动100ms
      }, {
        id: 0,
        usage: 'alarm'
      }, (error: BusinessError) => {
        if (error) {
          hilog.error(DOMAIN, TAG, `Vibrate failed: ${error.message}`);
        } else {
          hilog.info(DOMAIN, TAG, 'Vibrate success 100ms');
        }
        // 震动结束后停止
        vibrator.stopVibration();
      });
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Vibrate exception: ${error.message}`);
    }
  }
}
