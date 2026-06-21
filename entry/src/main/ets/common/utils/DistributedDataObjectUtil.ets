import { distributedDataObject } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { GameSessionData, DistributedSourceData } from '../models/GameSessionData';
import { StrokePoint, PlainStrokePoint } from '../models/StrokePoint';
import { AnswerRecord, PlainAnswerRecord } from '../models/PlayerInfo';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'DistributedDataObjectUtil';
const DOMAIN = 0x0001;

/** 本地存储数据结构接口 */
interface LocalStoreData {
  strokes: object[];
  scores: Record<string, Object>;
  answers: object[];
  gameStatus: string;
  hostDeviceId: string;
  roundNumber: number;
}

/** 猜题端加入组网时的源数据接口 */
interface GuestSourceData {
  sessionId: undefined;
  strokes: undefined;
  scores: undefined;
  answers: undefined;
  gameStatus: undefined;
  hostDeviceId: undefined;
  roundNumber: undefined;
}

/** 得分条目接口 */
interface ScoreEntry {
  networkId: string;
  name: string;
  score: number;
}

/** 创建得分条目的辅助函数 */
function createScoreEntry(playerId: string, playerName: string, points: number): Record<string, Object> {
  let entry = new Object() as Record<string, Object>;
  entry['networkId'] = playerId;
  entry['name'] = playerName;
  entry['score'] = points;
  return entry;
}

/**
 * DistributedDataObjectUtil - 分布式数据对象封装工具
 */
export class DistributedDataObjectUtil {
  private dataObject: distributedDataObject.DataObject | null = null;
  private sessionId: string = '';
  private context: common.UIAbilityContext;
  private localCurrentWord: string = '';
  private isLocalMode: boolean = false;

  /** 静态空得分对象 */
  private static EMPTY_SCORES: Record<string, Object> = new Object() as Record<string, Object>;

  /** 本地内存存储 */
  private localStore: LocalStoreData = {
    strokes: [],
    scores: DistributedDataObjectUtil.EMPTY_SCORES,
    answers: [],
    gameStatus: 'drawing',
    hostDeviceId: '',
    roundNumber: 1
  };

  get isLocal(): boolean {
    return this.isLocalMode;
  }

  private onChangeCallback: ((sessionId: string, fields: Array<string>) => void) | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async createAsHost(gameData: GameSessionData): Promise<string> {
    try {
      this.sessionId = distributedDataObject.genSessionId();
      hilog.info(DOMAIN, TAG, `Generated sessionId: ${this.sessionId}`);

      let source = gameData.toDistributedSource();
      source.sessionId = this.sessionId;
      this.dataObject = distributedDataObject.create(this.context, source);

      await this.dataObject.setSessionId(this.sessionId);
      hilog.info(DOMAIN, TAG, `Host dataObject setSessionId success`);

      this.setupChangeListener();

      this.isLocalMode = false;
      return this.sessionId;
    } catch (err) {
      let error = err as BusinessError;
      hilog.warn(DOMAIN, TAG,
        `[模拟器兼容] 分布式初始化失败，降级为本地内存模式: code=${error.code}`);
      return this.fallbackToLocalMode(gameData);
    }
  }

  private fallbackToLocalMode(gameData: GameSessionData): string {
    this.isLocalMode = true;
    this.sessionId = 'local_' + Date.now().toString();
    let source = gameData.toDistributedSource();
    this.localStore.strokes = source.strokes || [];
    this.localStore.scores = source.scores || DistributedDataObjectUtil.EMPTY_SCORES;
    this.localStore.answers = source.answers || [];
    this.localStore.gameStatus = source.gameStatus || 'drawing';
    this.localStore.hostDeviceId = source.hostDeviceId || '';
    this.localStore.roundNumber = source.roundNumber || 1;
    hilog.info(DOMAIN, TAG, `本地模式启动，localSessionId: ${this.sessionId}`);
    return this.sessionId;
  }

  async joinAsGuest(sessionId: string): Promise<boolean> {
    try {
      this.sessionId = sessionId;
      hilog.info(DOMAIN, TAG, `Guest joining sessionId: ${this.sessionId}`);

      let source: GuestSourceData = {
        sessionId: undefined,
        strokes: undefined,
        scores: undefined,
        answers: undefined,
        gameStatus: undefined,
        hostDeviceId: undefined,
        roundNumber: undefined
      };
      this.dataObject = distributedDataObject.create(this.context, source);

      this.setupChangeListener();

      await this.dataObject.setSessionId(this.sessionId);
      hilog.info(DOMAIN, TAG, `Guest dataObject setSessionId success`);

      this.isLocalMode = false;
      return true;
    } catch (err) {
      let error = err as BusinessError;
      hilog.warn(DOMAIN, TAG,
        `[模拟器兼容] 猜题端加入失败，降级为本地模式: code=${error.code}`);
      this.isLocalMode = true;
      this.sessionId = sessionId || 'local_guest_' + Date.now().toString();
      return true;
    }
  }

  private setupChangeListener(): void {
    if (!this.dataObject) {
      return;
    }
    this.dataObject.on('change', (sessionId: string, fields: Array<string>) => {
      hilog.info(DOMAIN, TAG, `DataObject changed, sessionId:${sessionId}, fields:${JSON.stringify(fields)}`);
      if (this.onChangeCallback) {
        this.onChangeCallback(sessionId, fields);
      }
    });

    this.dataObject.on('status', (sessionId: string, networkId: string, status: string) => {
      hilog.info(DOMAIN, TAG, `Status changed: sessionId=${sessionId}, networkId=${networkId}, status=${status}`);
    });
  }

  setOnChangeCallback(callback: (sessionId: string, fields: Array<string>) => void): void {
    this.onChangeCallback = callback;
  }

  // ==================== 笔迹操作 ====================

  addStrokes(strokePoints: StrokePoint[]): void {
    let plainStrokes: PlainStrokePoint[] = strokePoints.map(sp => StrokePoint.toPlainObject(sp));

    if (this.isLocalMode) {
      let current = this.localStore.strokes || [];
      this.localStore.strokes = current.concat(plainStrokes as object[]);
      this.triggerLocalChange(['strokes']);
      return;
    }

    if (!this.dataObject) {
      return;
    }
    let currentStrokes: object[] = (this.dataObject['strokes'] as object[]) || [];
    this.dataObject['strokes'] = currentStrokes.concat(plainStrokes as object[]);
  }

  getStrokes(): object[] {
    if (this.isLocalMode) {
      return this.localStore.strokes || [];
    }
    if (!this.dataObject) {
      return [];
    }
    return (this.dataObject['strokes'] as object[]) || [];
  }

  clearStrokes(): void {
    if (this.isLocalMode) {
      this.localStore.strokes = [];
      this.triggerLocalChange(['strokes']);
      return;
    }
    if (!this.dataObject) {
      return;
    }
    this.dataObject['strokes'] = [];
  }

  /**
   * 撤销最后一笔 - 按完整笔触（从 start 到 end）整笔移除
   * strokes 数组中每个笔触以 'start' 开头、'end' 结尾，
   * 一组 [start, move, ..., end] 构成一笔。
   */
  undoLastStroke(): void {
    if (this.isLocalMode) {
      let strokes: object[] = this.localStore.strokes || [];
      if (!this.removeLastCompleteStroke(strokes)) {
        return;
      }
      this.localStore.strokes = strokes;
      this.triggerLocalChange(['strokes']);
      return;
    }
    if (!this.dataObject) {
      return;
    }
    let strokes: object[] = (this.dataObject['strokes'] as object[]) || [];
    if (!this.removeLastCompleteStroke(strokes)) {
      return;
    }
    // 使用扩展运算符创建新数组引用，确保分布式数据对象检测到变更
    this.dataObject['strokes'] = [...strokes];
  }

  /**
   * 从 strokes 数组中移除最后一个完整笔触
   * @returns 是否成功移除
   */
  private removeLastCompleteStroke(strokes: object[]): boolean {
    if (strokes.length === 0) {
      return false;
    }
    // 从末尾向前找最后一个 'end'
    let endIdx: number = -1;
    for (let i = strokes.length - 1; i >= 0; i--) {
      if ((strokes[i] as Record<string, Object>)['type'] === 'end') {
        endIdx = i;
        break;
      }
    }
    if (endIdx === -1) {
      return false; // 没有完整笔触
    }
    // 从 endIdx 向前找对应的 'start'
    let startIdx: number = -1;
    for (let i = endIdx; i >= 0; i--) {
      if ((strokes[i] as Record<string, Object>)['type'] === 'start') {
        startIdx = i;
        break;
      }
    }
    if (startIdx === -1) {
      return false; // 数据异常
    }
    // 移除 [startIdx, end] 之间的所有点
    strokes.splice(startIdx, strokes.length - startIdx);
    return true;
  }

  // ==================== 答案操作 ====================

  submitAnswer(answerRecord: AnswerRecord): void {
    if (this.isLocalMode) {
      let currentAnswers: object[] = this.localStore.answers || [];
      currentAnswers.push(answerRecord.toPlainObject() as object);
      this.localStore.answers = currentAnswers;
      this.triggerLocalChange(['answers']);
      return;
    }
    if (!this.dataObject) {
      return;
    }
    let currentAnswers: object[] = (this.dataObject['answers'] as object[]) || [];
    currentAnswers.push(answerRecord.toPlainObject() as object);
    // 确保新数组引用触发分布式同步
    this.dataObject['answers'] = [...currentAnswers];
  }

  updateAnswerJudgment(answerIndex: number, isCorrect: boolean): void {
    if (this.isLocalMode) {
      let currentAnswers: object[] = this.localStore.answers || [];
      if (answerIndex >= 0 && answerIndex < currentAnswers.length) {
        let answerObj = currentAnswers[answerIndex] as Record<string, Object>;
        answerObj['isJudged'] = true;
        answerObj['isCorrect'] = isCorrect;
        this.localStore.answers = currentAnswers;
        if (isCorrect) {
          this.addScore(answerObj['playerId'] as string,
            answerObj['playerName'] as string, 10);
        }
        this.triggerLocalChange(['answers', 'scores']);
      }
      return;
    }
    if (!this.dataObject) {
      return;
    }
    let currentAnswers: object[] = (this.dataObject['answers'] as object[]) || [];
    if (answerIndex >= 0 && answerIndex < currentAnswers.length) {
      let answerObj = currentAnswers[answerIndex] as Record<string, Object>;
      answerObj['isJudged'] = true;
      answerObj['isCorrect'] = isCorrect;
      // 使用扩展运算符创建新数组引用，确保分布式数据对象检测到嵌套变更
      this.dataObject['answers'] = [...currentAnswers];
      if (isCorrect) {
        this.addScore(answerObj['playerId'] as string, answerObj['playerName'] as string, 10);
      }
    }
  }

  getAnswers(): object[] {
    if (this.isLocalMode) {
      return this.localStore.answers || [];
    }
    if (!this.dataObject) {
      return [];
    }
    return (this.dataObject['answers'] as object[]) || [];
  }

  clearAnswers(): void {
    if (this.isLocalMode) {
      this.localStore.answers = [];
      this.triggerLocalChange(['answers']);
      return;
    }
    if (!this.dataObject) {
      return;
    }
    this.dataObject['answers'] = [];
  }

  // ==================== 得分操作 ====================

  private addScore(playerId: string, playerName: string, points: number): void {
    if (this.isLocalMode) {
      let currentScores: Record<string, Object> =
        this.localStore.scores || DistributedDataObjectUtil.EMPTY_SCORES;
      if (currentScores[playerId]) {
        let existing = currentScores[playerId] as Record<string, Object>;
        existing['score'] = ((existing['score'] as number) || 0) + points;
      } else {
        currentScores[playerId] = createScoreEntry(playerId, playerName, points);
      }
      this.localStore.scores = currentScores;
      return;
    }
    if (!this.dataObject) {
      return;
    }
    let currentScores: Record<string, Object> =
      (this.dataObject['scores'] as Record<string, Object>) || DistributedDataObjectUtil.EMPTY_SCORES;
    if (currentScores[playerId]) {
      let existing = currentScores[playerId] as Record<string, Object>;
      existing['score'] = ((existing['score'] as number) || 0) + points;
    } else {
      currentScores[playerId] = createScoreEntry(playerId, playerName, points);
    }
    this.dataObject['scores'] = currentScores;
  }

  getScores(): Record<string, Object> {
    if (this.isLocalMode) {
      return this.localStore.scores || DistributedDataObjectUtil.EMPTY_SCORES;
    }
    if (!this.dataObject) {
      return DistributedDataObjectUtil.EMPTY_SCORES;
    }
    return (this.dataObject['scores'] as Record<string, Object>) || DistributedDataObjectUtil.EMPTY_SCORES;
  }

  // ==================== 游戏状态操作 ====================

  setGameStatus(status: string): void {
    if (this.isLocalMode) {
      this.localStore.gameStatus = status;
      this.triggerLocalChange(['gameStatus']);
      return;
    }
    if (!this.dataObject) {
      return;
    }
    this.dataObject['gameStatus'] = status;
  }

  getGameStatus(): string {
    if (this.isLocalMode) {
      return this.localStore.gameStatus || 'drawing';
    }
    if (!this.dataObject) {
      return 'drawing';
    }
    return (this.dataObject['gameStatus'] as string) || 'drawing';
  }

  setHostDeviceId(deviceId: string): void {
    if (this.isLocalMode) {
      this.localStore.hostDeviceId = deviceId;
      return;
    }
    if (!this.dataObject) {
      return;
    }
    this.dataObject['hostDeviceId'] = deviceId;
  }

  incrementRound(): void {
    if (this.isLocalMode) {
      let currentRound = this.localStore.roundNumber || 1;
      this.localStore.roundNumber = currentRound + 1;
      return;
    }
    if (!this.dataObject) {
      return;
    }
    let currentRound = (this.dataObject['roundNumber'] as number) || 1;
    this.dataObject['roundNumber'] = currentRound + 1;
  }

  // ==================== 本地模式变化通知 ====================

  private triggerLocalChange(fields: Array<string>): void {
    if (this.onChangeCallback) {
      this.onChangeCallback(this.sessionId, fields);
    }
  }

  // ==================== 会话管理 ====================

  setLocalCurrentWord(word: string): void {
    this.localCurrentWord = word;
  }

  getLocalCurrentWord(): string {
    return this.localCurrentWord;
  }

  getSessionId(): string {
    return this.sessionId;
  }

  async leaveSession(): Promise<void> {
    try {
      if (this.dataObject) {
        await this.dataObject.setSessionId('');
        hilog.info(DOMAIN, TAG, 'Left distributed session');
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `leaveSession failed: ${error.message}`);
    }
  }

  destroy(): void {
    this.leaveSession();
    this.dataObject = null;
    this.onChangeCallback = null;
  }
}
