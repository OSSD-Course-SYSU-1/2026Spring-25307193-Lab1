/**
 * StrokePoint - 笔迹点数据模型
 *
 * 描述绘画过程中每个坐标点的信息。
 * 每个完整的笔触（从手指按下到抬起）由多个StrokePoint组成。
 * 通过分布式数据对象实时同步给所有猜题端，用于复现绘画过程。
 */

/** 笔迹点的普通对象接口（用于分布式序列化） */
export interface PlainStrokePoint {
  x: number;
  y: number;
  color: string;
  width: number;
  type: string;
}

export class StrokePoint {
  /** X坐标 */
  x: number;
  /** Y坐标 */
  y: number;
  /** 画笔颜色 */
  color: string;
  /** 画笔粗细 (2-20px) */
  width: number;
  /**
   * 点类型:
   * - 'start': 笔触开始（手指按下）
   * - 'move': 笔触移动中
   * - 'end': 笔触结束（手指抬起）
   */
  type: string;

  constructor(x: number, y: number, color: string, width: number, type: string) {
    this.x = x;
    this.y = y;
    this.color = color;
    this.width = width;
    this.type = type;
  }

  /**
   * 将StrokePoint序列化为普通对象，用于放入分布式数据对象进行跨设备同步
   * 分布式数据对象仅支持基本类型和数组，不支持类实例的直接传输
   */
  static toPlainObject(sp: StrokePoint): PlainStrokePoint {
    return {
      x: sp.x,
      y: sp.y,
      color: sp.color,
      width: sp.width,
      type: sp.type
    };
  }

  /**
   * 从普通对象反序列化为StrokePoint
   */
  static fromPlainObject(obj: Record<string, Object>): StrokePoint {
    return new StrokePoint(
      obj['x'] as number,
      obj['y'] as number,
      obj['color'] as string,
      obj['width'] as number,
      obj['type'] as string
    );
  }
}
