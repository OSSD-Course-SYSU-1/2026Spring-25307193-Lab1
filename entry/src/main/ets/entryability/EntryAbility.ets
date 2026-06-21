import { AbilityConstant, UIAbility, Want, common, wantConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { distributedDataObject } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContinuationManager, RestoredGameState } from '../features/collaboration/ContinuationManager';

const TAG = 'EntryAbility';
const DOMAIN = 0x0007;

/**
 * EntryAbility - 应用主入口
 *
 * 【核心能力】
 * 1. 跨端迁移（Continuation）：实现画板端游戏无缝迁移到另一设备
 *    - onContinue: 源端保存游戏状态（题目、得分、笔迹、房间号等）
 *    - onCreate/onNewWant: 目标端恢复游戏状态
 * 2. 分布式组网：初始化游戏房间和分布式数据对象
 * 3. 角色判断：通过want参数判断当前设备是画板端还是猜题端
 *
 * 【迁移数据流】
 * 源端 onContinue:
 *   -> wantParam保存sessionId、currentWord、scores、strokes、gameStatus
 *   -> 创建分布式数据对象保存到目标端
 *   -> 返回AGREE同意迁移
 *
 * 目标端 onCreate/onNewWant:
 *   -> 检测LaunchReason.CONTINUATION
 *   -> 读取want.parameters恢复游戏状态
 *   -> 重新创建分布式数据对象加入原有会话
 *   -> 刷新UI恢复所有游戏状态
 */
export default class EntryAbility extends UIAbility {
  private continuationManager: ContinuationManager | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, `onCreate, launchReason: ${launchParam.launchReason}`);

    this.continuationManager = new ContinuationManager(this.context);

    // 【跨端迁移恢复】检测是否为接续启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, TAG, 'Launch reason: CONTINUATION - restoring game state');
      this.handleContinuationRestore(want);
    }

    // 设置接续状态为ACTIVE，确保可迁移
    try {
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        hilog.info(DOMAIN, TAG, `setMissionContinueState ACTIVE result: ${JSON.stringify(result)}`);
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, `setMissionContinueState error: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 【跨端迁移 - 源端】当用户发起接续时调用
   *
   * 在onContinue中保存游戏状态：
   * 1. 从AppStorage获取当前游戏状态
   * 2. 将小数据通过wantParam传递（<100KB）
   * 3. 大数据通过分布式数据对象save到目标端
   * 4. 返回AGREE同意迁移
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, `onContinue triggered, targetDevice: ${wantParam.targetDevice}`);

    try {
      // 从AppStorage获取当前游戏状态
      let sessionId = AppStorage.get<string>('gameSessionId') || '';
      let currentWord = AppStorage.get<string>('currentWord') || '';
      let scoresJson = AppStorage.get<string>('scoresJson') || '{}';
      let strokesJson = AppStorage.get<string>('strokesJson') || '[]';
      let gameStatus = AppStorage.get<string>('gameStatus') || 'drawing';
      let roundNumber = AppStorage.get<number>('roundNumber') || 1;

      // 通过wantParam传递关键数据（<100KB限制）
      wantParam['contSessionId'] = sessionId;
      wantParam['contCurrentWord'] = currentWord;
      wantParam['contScoresJson'] = scoresJson;
      wantParam['contStrokesJson'] = strokesJson;
      wantParam['contGameStatus'] = gameStatus;
      wantParam['contRoundNumber'] = roundNumber;
      wantParam['contRole'] = 'host'; // 迁移后仍是画板端

      hilog.info(DOMAIN, TAG,
        `onContinue: saved sessionId=${sessionId}, word=${currentWord}`);

      // 如果笔迹数据较大，使用分布式数据对象迁移大数据
      if (strokesJson.length > 1000 && this.continuationManager) {
        this.continuationManager.saveGameStateForContinuation(
          wantParam, sessionId, currentWord,
          scoresJson, strokesJson, gameStatus, roundNumber
        );
      }

      // 同意迁移，设置源端退出
      wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = true;

      return AbilityConstant.OnContinueResult.AGREE;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `onContinue error: ${JSON.stringify(err)}`);
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  /**
   * onNewWant - 热启动时被调用（单实例模式）
   *
   * 同样需要处理接续恢复和猜题端加入
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, `onNewWant, launchReason: ${launchParam.launchReason}`);

    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.handleContinuationRestore(want);
    }
  }

  /**
   * 处理跨端迁移恢复
   * 从want.parameters中读取迁移数据，恢复游戏状态
   */
  private handleContinuationRestore(want: Want): void {
    if (!want.parameters) {
      hilog.error(DOMAIN, TAG, 'No parameters in continuation want');
      return;
    }

    // 检查是否有大数据的迁移（通过分布式数据对象）
    let migrationSessionId = want.parameters['migrationSessionId'] as string;

    if (migrationSessionId && this.continuationManager) {
      // 有大数据迁移，通过分布式数据对象恢复
      this.continuationManager.restoreGameState(want, AbilityConstant.LaunchReason.CONTINUATION).then((state: RestoredGameState | null) => {
        if (state) {
          this.applyRestoredState(state);
        } else {
          // 降级方案：使用wantParam中的小数据
          this.restoreFromWantParams(want);
        }
      });
    } else {
      // 直接使用wantParam中的小数据恢复
      this.restoreFromWantParams(want);
    }
  }

  /**
   * 从want参数恢复游戏状态（小数据方案）
   */
  private restoreFromWantParams(want: Want): void {
    if (!want.parameters) {
      return;
    }

    let sessionId = (want.parameters['contSessionId'] as string) || '';
    let currentWord = (want.parameters['contCurrentWord'] as string) || '';
    let scoresJson = (want.parameters['contScoresJson'] as string) || '{}';
    let strokesJson = (want.parameters['contStrokesJson'] as string) || '[]';
    let gameStatus = (want.parameters['contGameStatus'] as string) || 'drawing';
    let roundNumber = (want.parameters['contRoundNumber'] as number) || 1;
    let role = (want.parameters['contRole'] as string) || 'host';

    let state: RestoredGameState = {
      sessionId: sessionId,
      currentWord: currentWord,
      scoresJson: scoresJson,
      strokesJson: strokesJson,
      gameStatus: gameStatus,
      roundNumber: roundNumber
    };

    this.applyRestoredState(state, role);
  }

  /**
   * 应用恢复的游戏状态到AppStorage
   */
  private applyRestoredState(state: RestoredGameState, role?: string): void {
    hilog.info(DOMAIN, TAG,
      `Applying restored state: word=${state.currentWord}, round=${state.roundNumber}`);

    AppStorage.setOrCreate<string>('gameSessionId', state.sessionId);
    AppStorage.setOrCreate<string>('currentWord', state.currentWord);
    AppStorage.setOrCreate<string>('scoresJson', state.scoresJson);
    AppStorage.setOrCreate<string>('strokesJson', state.strokesJson);
    AppStorage.setOrCreate<string>('gameStatus', state.gameStatus);
    AppStorage.setOrCreate<number>('roundNumber', state.roundNumber);
    AppStorage.setOrCreate<string>('userRole', role || 'host');
    AppStorage.setOrCreate<boolean>('isContinuationRestored', true);
  }

  /**
   * onWindowStageCreate - 创建窗口阶段
   * 加载主页面Index.ets
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');

    // 初始化AppStorage默认值
    let params = this.context?.config;
    let wantParams = this.launchWant?.parameters;

    // 检查是否是猜题端被拉起（通过startAbilityByCall）
    if (wantParams && wantParams['role'] === 'guesser') {
      let sessionId = (wantParams['gameSessionId'] as string) || '';
      let hostDeviceId = (wantParams['hostDeviceId'] as string) || '';
      AppStorage.setOrCreate<string>('gameSessionId', sessionId);
      AppStorage.setOrCreate<string>('hostDeviceId', hostDeviceId);
      AppStorage.setOrCreate<string>('userRole', 'guesser');
    } else if (!AppStorage.get<boolean>('isContinuationRestored')) {
      // 默认为主页，由用户在Index页面选择角色
      AppStorage.setOrCreate<string>('userRole', '');
    }

    // 初始化默认值
    if (!AppStorage.get<string>('currentWord')) {
      AppStorage.setOrCreate<string>('currentWord', '');
    }
    if (!AppStorage.get<string>('scoresJson')) {
      AppStorage.setOrCreate<string>('scoresJson', '{}');
    }
    if (!AppStorage.get<string>('strokesJson')) {
      AppStorage.setOrCreate<string>('strokesJson', '[]');
    }
    if (!AppStorage.get<string>('gameStatus')) {
      AppStorage.setOrCreate<string>('gameStatus', 'idle');
    }
    if (!AppStorage.get<number>('roundNumber')) {
      AppStorage.setOrCreate<number>('roundNumber', 1);
    }
    if (!AppStorage.get<string>('currentBreakpoint')) {
      AppStorage.setOrCreate<string>('currentBreakpoint', 'sm');
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `loadContent failed: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent success');
    });
  }

  /**
   * onWindowStageRestore - 迁移后窗口恢复
   * 迁移场景不会执行onWindowStageCreate，需要在此处理初始化
   */
  onWindowStageRestore(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageRestore');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `loadContent in restore failed: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent in restore success');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onDestroy');
    this.continuationManager = null;
  }
}
