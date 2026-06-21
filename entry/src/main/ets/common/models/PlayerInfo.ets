/**
 * PlayerInfo - 玩家信息模型
 *
 * 用于画板端管理和识别不同猜题端的玩家。
 * 通过分布式设备管理获取设备名称作为玩家昵称，
 * 并使用networkId唯一标识玩家。
 */

/** 玩家信息普通对象接口（用于分布式序列化） */
export interface PlainPlayerInfo {
  networkId: string;
  name: string;
  score: number;
  isOnline: boolean;
}

export class PlayerInfo {
  /** 玩家设备networkId（唯一标识） */
  networkId: string;
  /** 玩家昵称（设备名称） */
  name: string;
  /** 当前得分 */
  score: number;
  /** 是否在线 */
  isOnline: boolean;

  constructor(networkId: string, name: string) {
    this.networkId = networkId;
    this.name = name;
    this.score = 0;
    this.isOnline = true;
  }

  /**
   * 将PlayerInfo序列化为普通对象
   */
  toPlainObject(): PlainPlayerInfo {
    return {
      networkId: this.networkId,
      name: this.name,
      score: this.score,
      isOnline: this.isOnline
    };
  }

  /**
   * 从普通对象反序列化
   */
  static fromPlainObject(obj: Record<string, Object>): PlayerInfo {
    let player = new PlayerInfo(
      obj['networkId'] as string,
      obj['name'] as string
    );
    player.score = (obj['score'] as number) || 0;
    player.isOnline = (obj['isOnline'] as boolean) || false;
    return player;
  }
}

/**
 * AnswerRecord - 答案记录模型
 *
 * 猜题端提交的答案，由画板端进行判断（正确/错误）
 */

/** 答案记录普通对象接口（用于分布式序列化） */
export interface PlainAnswerRecord {
  playerId: string;
  playerName: string;
  answer: string;
  isJudged: boolean;
  isCorrect: boolean;
}

export class AnswerRecord {
  /** 提交答案的玩家networkId */
  playerId: string;
  /** 玩家昵称 */
  playerName: string;
  /** 提交的答案文本 */
  answer: string;
  /** 是否已被判定 */
  isJudged: boolean;
  /** 判定结果：true=正确, false=错误 */
  isCorrect: boolean;

  constructor(playerId: string, playerName: string, answer: string) {
    this.playerId = playerId;
    this.playerName = playerName;
    this.answer = answer;
    this.isJudged = false;
    this.isCorrect = false;
  }

  toPlainObject(): PlainAnswerRecord {
    return {
      playerId: this.playerId,
      playerName: this.playerName,
      answer: this.answer,
      isJudged: this.isJudged,
      isCorrect: this.isCorrect
    };
  }

  static fromPlainObject(obj: Record<string, Object>): AnswerRecord {
    let record = new AnswerRecord(
      obj['playerId'] as string,
      obj['playerName'] as string,
      obj['answer'] as string
    );
    record.isJudged = (obj['isJudged'] as boolean) || false;
    record.isCorrect = (obj['isCorrect'] as boolean) || false;
    return record;
  }
}
