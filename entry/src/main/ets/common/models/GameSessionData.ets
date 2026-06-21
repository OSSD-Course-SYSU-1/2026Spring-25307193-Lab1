import { StrokePoint } from './StrokePoint';

/**
 * GameSessionData - 游戏会话数据模型
 *
 * 用于分布式数据对象的源对象定义。
 * 该对象的所有属性将被分布式数据对象自动追踪，
 * 当画板端修改属性时，所有猜题端通过on('change')自动收到变更通知。
 *
 * 【安全设计】currentWord字段仅画板端本地持有，
 * 不放入分布式数据对象中，防止题目泄露给猜题端。
 */

/** 分布式数据源对象接口 */
export interface DistributedSourceData {
  sessionId: string;
  strokes: object[];
  scores: Record<string, Object>;
  answers: object[];
  gameStatus: string;
  hostDeviceId: string;
  roundNumber: number;
}

export class GameSessionData {
  /**
   * 房间会话ID - 由分布式数据对象的genSessionId()生成
   * 画板端和猜题端通过相同的sessionId加入同一组网
   * 实现笔迹数据的自动跨设备同步
   */
  sessionId: string;

  /**
   * 所有笔迹点的数组
   * 每次新笔触（手指按下到抬起）产生的坐标点数组
   * 通过分布式数据对象从画板端实时同步到所有猜题端
   * 【重要】由于分布式数据对象对复杂类型的修改仅支持根属性替换，
   * 每次添加新笔触时需要使用整体替换strokes数组的方式触发同步。
   */
  strokes: object[];

  /**
   * 玩家得分映射
   * key: 设备networkId或设备名称
   * value: 得分
   */
  scores: Record<string, Object>;

  /**
   * 玩家提交的答案列表
   * 每个元素包含 {playerName, answer, isCorrect, isJudged}
   */
  answers: object[];

  /**
   * 【仅本地】当前题目 - 不放入分布式对象，仅画板端持有
   * 防止题目泄露给猜题端
   */
  currentWord: string;

  /**
   * 游戏状态
   * - 'drawing': 绘画阶段
   * - 'guessing': 猜题阶段（等待玩家答案）
   * - 'roundEnd': 轮次结束
   */
  gameStatus: string;

  /**
   * 画板端的networkId
   */
  hostDeviceId: string;

  /**
   * 当前轮次编号
   */
  roundNumber: number;

  constructor(sessionId: string) {
    this.sessionId = sessionId;
    this.strokes = [];
    this.scores = new Object() as Record<string, Object>;
    this.answers = [];
    this.currentWord = '';
    this.gameStatus = 'drawing';
    this.hostDeviceId = '';
    this.roundNumber = 1;
  }

  /**
   * 构建用于创建分布式数据对象的源对象
   * 【注意】currentWord特意不被包含，防止猜题端获取题目
   */
  toDistributedSource(): DistributedSourceData {
    return {
      sessionId: this.sessionId,
      strokes: this.strokes,
      scores: this.scores,
      answers: this.answers,
      gameStatus: this.gameStatus,
      hostDeviceId: this.hostDeviceId,
      roundNumber: this.roundNumber
    };
  }

  /**
   * 从分布式数据对象恢复数据到GameSessionData
   */
  static fromDistributedObject(dObj: object, localCurrentWord: string): GameSessionData {
    let source = dObj as DistributedSourceData;
    let data = new GameSessionData(source.sessionId);
    data.strokes = source.strokes || [];
    data.scores = source.scores || new Object() as Record<string, Object>;
    data.answers = source.answers || [];
    data.gameStatus = source.gameStatus || 'drawing';
    data.hostDeviceId = source.hostDeviceId || '';
    data.roundNumber = source.roundNumber || 1;
    data.currentWord = localCurrentWord;
    return data;
  }
}
