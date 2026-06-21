import { StrokePoint } from '../../common/models/StrokePoint';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'DrawingCanvas';
const DOMAIN = 0x0003;

/**
 * DrawingCanvas - 画板端绘画组件
 *
 * 【核心功能】
 * - 使用Canvas + onTouch事件收集触摸坐标点
 * - 实时绘制笔迹预览（本地渲染）
 * - 每次笔触完成（手指抬起）时，将完整笔触数据通过回调传递给分布式层同步
 * - 支持清屏、撤销后从笔迹数据重绘
 */
@Component
export struct DrawingCanvas {
  /** 画布渲染上下文 */
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  /** 当前画笔颜色 */
  @Prop currentColor: string = '#FF0000';
  /** 当前画笔粗细 (2-20px) */
  @Prop currentWidth: number = 6;
  /** 当前笔触的坐标点集合 */
  private currentStroke: StrokePoint[] = [];
  /** 画布宽度 */
  @State canvasWidth: number = 360;
  /** 画布高度 */
  @State canvasHeight: number = 480;

  /** 笔触完成回调 - 将完整笔触传递给父组件进行分布式同步 */
  onStrokeComplete?: (strokePoints: StrokePoint[]) => void;

  /** 清屏信号 - @Watch 监听变化触发清屏 */
  @Prop @Watch('onClearSignalChanged') clearSignal: number = 0;

  /** 当前笔迹数据 - 用于撤销/清屏后重绘 */
  @Prop strokes: object[] = [];

  /** 笔迹版本号 - @Watch 监听变化触发重绘 */
  @Prop @Watch('onStrokesVersionChanged') strokesVersion: number = 0;

  private isFirstDraw: boolean = true;

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'DrawingCanvas aboutToAppear');
  }

  /** 清屏信号变化 → 清除画布 */
  onClearSignalChanged(): void {
    if (this.isFirstDraw) {
      this.isFirstDraw = false;
      return;
    }
    hilog.info(DOMAIN, TAG, 'clearSignal changed, clearing canvas');
    this.clearCanvas();
  }

  /** 笔迹版本号变化 → 从数据重绘（撤销后） */
  onStrokesVersionChanged(): void {
    if (this.isFirstDraw) {
      this.isFirstDraw = false;
      return;
    }
    hilog.info(DOMAIN, TAG, `strokesVersion changed, redrawing ${this.strokes.length} strokes`);
    this.redrawStrokes(this.strokes);
  }

  build() {
    Column() {
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#CCCCCC' })
        // 触摸事件处理 - 收集绘制坐标点
        .onTouch((event: TouchEvent) => {
          if (event.touches.length === 0) {
            return;
          }
          let touch = event.touches[0];
          let x = touch.x;
          let y = touch.y;

          // 画笔粗细（使用固定笔宽）
          let penWidth: number = this.currentWidth;

          switch (event.type) {
            case TouchType.Down:
              // 手指按下 - 开始新笔触
              this.currentStroke = [];
              let startPoint = new StrokePoint(x, y, this.currentColor, penWidth, 'start');
              this.currentStroke.push(startPoint);
              this.drawPoint(x, y, this.currentColor, penWidth);
              break;

            case TouchType.Move:
              // 手指移动 - 添加中间点并连线
              if (this.currentStroke.length > 0) {
                let movePoint = new StrokePoint(x, y, this.currentColor, penWidth, 'move');
                this.currentStroke.push(movePoint);
                // 从上一个点绘制到当前点
                let lastPoint = this.currentStroke[this.currentStroke.length - 2];
                this.drawLine(
                  lastPoint.x, lastPoint.y,
                  x, y,
                  this.currentColor,
                  penWidth
                );
              }
              break;

            case TouchType.Up:
            case TouchType.Cancel:
              // 手指抬起 - 结束笔触
              if (this.currentStroke.length > 0) {
                let endPoint = new StrokePoint(x, y, this.currentColor, penWidth, 'end');
                this.currentStroke.push(endPoint);
                // 绘制最后一小段
                if (this.currentStroke.length >= 2) {
                  let lastPoint = this.currentStroke[this.currentStroke.length - 2];
                  this.drawLine(lastPoint.x, lastPoint.y, x, y, this.currentColor, penWidth);
                } else {
                  this.drawPoint(x, y, this.currentColor, penWidth);
                }
                // 笔触完成，触发回调进行分布式同步
                if (this.onStrokeComplete && this.currentStroke.length > 0) {
                  this.onStrokeComplete([...this.currentStroke]);
                }
              }
              break;
          }
        })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.canvasWidth = newValue.width as number;
          this.canvasHeight = newValue.height as number;
        })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 绘制单个点（用于笔触起始点）
   */
  private drawPoint(x: number, y: number, color: string, width: number): void {
    this.canvasContext.beginPath();
    this.canvasContext.arc(x, y, width / 2, 0, 2 * Math.PI);
    this.canvasContext.fillStyle = color;
    this.canvasContext.fill();
  }

  /**
   * 绘制两点之间的连线
   */
  private drawLine(x1: number, y1: number, x2: number, y2: number, color: string, width: number): void {
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(x1, y1);
    this.canvasContext.lineTo(x2, y2);
    this.canvasContext.strokeStyle = color;
    this.canvasContext.lineWidth = width;
    this.canvasContext.lineCap = 'round';
    this.canvasContext.lineJoin = 'round';
    this.canvasContext.stroke();
  }

  /**
   * 清屏 - 清除画布
   */
  clearCanvas(): void {
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.currentStroke = [];
  }

  /**
   * 重绘画布 - 根据stroke数据完整重绘
   */
  redrawStrokes(strokes: object[]): void {
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    for (let i = 0; i < strokes.length; i++) {
      let sp = strokes[i] as Record<string, Object>;
      let x = sp['x'] as number;
      let y = sp['y'] as number;
      let color = sp['color'] as string;
      let width = sp['width'] as number;
      let type = sp['type'] as string;

      if (type === 'start') {
        this.drawPoint(x, y, color, width);
      } else if (type === 'move' && i > 0) {
        let prev = strokes[i - 1] as Record<string, Object>;
        this.drawLine(
          prev['x'] as number, prev['y'] as number,
          x, y, color, width
        );
      } else if (type === 'end' && i > 0) {
        let prev = strokes[i - 1] as Record<string, Object>;
        this.drawLine(
          prev['x'] as number, prev['y'] as number,
          x, y, color, width
        );
      }
    }
  }
}
