import { distributedDataObject } from '@kit.ArkData';
import { common, Want, AbilityConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ContinuationManager';
const DOMAIN = 0x0006;

/** 迁移数据结构接口 */
interface MigrationData {
  sessionId: string;
  currentWord: string;
  scoresData: string;
  strokesData: string;
  gameStatus: string;
  roundNumber: number;
}

/** 空迁移数据结构接口（用于接收恢复数据） */
interface EmptyMigrationData {
  sessionId: undefined;
  currentWord: undefined;
  scoresData: undefined;
  strokesData: undefined;
  gameStatus: undefined;
  roundNumber: undefined;
}

/**
 * ContinuationManager - 跨端迁移管理器
 *
 * 负责画板端游戏状态的跨端迁移（接续）。
 *
 * 【迁移流程】
 * 源端（原画板端）：
 *   1. onContinue中调用saveGameStateToWantAndSave()
 *   2. 创建分布式数据对象，将游戏状态持久化保存到目标端
 *   3. 将sessionId通过wantParam传递给目标端
 *   4. 设置wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = true 退出源端
 *
 * 目标端（新画板端）：
 *   1. onCreate/onNewWant中调用restoreGameState()
 *   2. 检测launchReason是否为CONTINUATION
 *   3. 从want.parameters中读取sessionId
 *   4. 创建空的分布式数据对象并加入组网（获取恢复的数据）
 *   5. 监听'status'的'restored'事件获取恢复的游戏数据
 *   6. 刷新UI恢复游戏状态
 *
 * 【数据量控制】
 * 通过wantParam传输的数据需小于100KB，仅传递sessionId和currentWord等关键信息。
 * 大量笔迹数据通过分布式数据对象的save/restore机制传输。
 */
export class ContinuationManager {
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 【源端】保存游戏状态到wantParam并持久化到目标端
   *
   * 在onContinue回调中调用此方法
   *
   * @param wantParam onContinue传入的wantParam
   * @param sessionId 当前房间sessionId
   * @param currentWord 当前题目
   * @param scores 得分表序列化
   * @param strokes 笔迹数据
   * @param gameStatus 游戏状态
   * @param roundNumber 当前轮次
   * @returns 是否同意迁移
   */
  async saveGameStateForContinuation(
    wantParam: Record<string, Object>,
    sessionId: string,
    currentWord: string,
    scores: string,
    strokes: string,
    gameStatus: string,
    roundNumber: number
  ): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, `onContinue: saving game state for migration`);

      // 创建分布式数据对象用于保存迁移数据
      let migrationData: MigrationData = {
        sessionId: sessionId,
        currentWord: currentWord,
        scoresData: scores,
        strokesData: strokes,
        gameStatus: gameStatus,
        roundNumber: roundNumber
      };

      let dObj = distributedDataObject.create(this.context, migrationData);
      let migrationSessionId = distributedDataObject.genSessionId();

      // 将自定义key（避免使用系统占用的sessionId字段）
      wantParam['migrationSessionId'] = migrationSessionId;

      // 激活分布式数据对象
      dObj.setSessionId(migrationSessionId);

      // 持久化保存到目标端设备
      let targetDevice = wantParam['targetDevice'] as string;
      await dObj.save(targetDevice);

      hilog.info(DOMAIN, TAG, `Game state saved for continuation, sessionId: ${migrationSessionId}`);
      return true;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `saveGameStateForContinuation failed: ${error.message}`);
      return false;
    }
  }

  /**
   * 【目标端】从want中恢复游戏状态
   *
   * 在onCreate/onNewWant的CONTINUATION分支中调用
   *
   * @param want 传入的Want对象
   * @param launchReason 启动原因
   * @returns 恢复的游戏状态数据，或null
   */
  restoreGameState(want: Want, launchReason: number): Promise<RestoredGameState | null> {
    return new Promise((resolve) => {
      if (launchReason !== AbilityConstant.LaunchReason.CONTINUATION) {
        resolve(null);
        return;
      }

      if (!want.parameters) {
        hilog.error(DOMAIN, TAG, 'restoreGameState: no parameters in want');
        resolve(null);
        return;
      }

      let migrationSessionId = want.parameters['migrationSessionId'] as string;
      if (!migrationSessionId) {
        hilog.error(DOMAIN, TAG, 'restoreGameState: no migrationSessionId');
        resolve(null);
        return;
      }

      hilog.info(DOMAIN, TAG, `restoreGameState: migrationSessionId = ${migrationSessionId}`);

      // 创建空的分布式数据对象用于接收恢复数据
      let emptyData: EmptyMigrationData = {
        sessionId: undefined,
        currentWord: undefined,
        scoresData: undefined,
        strokesData: undefined,
        gameStatus: undefined,
        roundNumber: undefined
      };
      let dObj = distributedDataObject.create(this.context, emptyData);

      // 注册恢复状态监听
      dObj.on('status', (sessionId: string, networkId: string, status: string) => {
        hilog.info(DOMAIN, TAG, `Migration status: ${status}, sessionId: ${sessionId}`);

        if (status === 'restored') {
          // 数据恢复完成，读取游戏状态
          let restoredState: RestoredGameState = {
            sessionId: (dObj['sessionId'] as string) || '',
            currentWord: (dObj['currentWord'] as string) || '',
            scoresJson: (dObj['scoresData'] as string) || '{}',
            strokesJson: (dObj['strokesData'] as string) || '[]',
            gameStatus: (dObj['gameStatus'] as string) || 'drawing',
            roundNumber: (dObj['roundNumber'] as number) || 1
          };

          hilog.info(DOMAIN, TAG,
            `Game state restored: word=${restoredState.currentWord}, ` +
            `round=${restoredState.roundNumber}`);
          resolve(restoredState);
        }
      });

      // 激活分布式数据对象加入组网
      dObj.setSessionId(migrationSessionId);
    });
  }
}

/**
 * 恢复的游戏状态接口
 */
export interface RestoredGameState {
  sessionId: string;
  currentWord: string;
  scoresJson: string;
  strokesJson: string;
  gameStatus: string;
  roundNumber: number;
}
