/**
 * GuessingCanvas - 猜题端实时绘画展示组件
 *
 * 【核心功能】
 * - 接收分布式数据对象同步的笔迹数据（strokes数组）
 * - 使用Canvas实时复现画板端绘画过程
 * - 提供redrawStrokes方法，外部传入最新strokes后重绘
 *
 * 【数据流】
 * 分布式数据对象 -> onChange监听 -> strokes变更 -> 重绘画布
 */
@Component
export struct GuessingCanvas {
  /** 画布渲染上下文 */
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  /** 画布宽度 */
  @State canvasWidth: number = 360;
  /** 画布高度 */
  @State canvasHeight: number = 480;
  /** 外部传入的笔迹数据 */
  @Prop @Watch('onStrokesChanged') strokes: object[] = [];

  private isFirstLoad: boolean = true;

  /** strokes变化 → 重绘画布 */
  onStrokesChanged(): void {
    if (this.isFirstLoad) {
      this.isFirstLoad = false;
      return;
    }
    this.redrawStrokes(this.strokes);
  }

  build() {
    Column() {
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#CCCCCC' })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.canvasWidth = newValue.width as number;
          this.canvasHeight = newValue.height as number;
          // 尺寸变化后重绘
          if (!this.isFirstLoad) {
            this.redrawStrokes(this.strokes);
          }
          this.isFirstLoad = false;
        })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 重绘画布 - 根据stroke数据完整重绘
   * 猜题端复现画板端绘画过程
   */
  redrawStrokes(strokes: object[]): void {
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    if (strokes.length === 0) {
      return;
    }

    for (let i = 0; i < strokes.length; i++) {
      let sp = strokes[i] as Record<string, Object>;
      let x = sp['x'] as number;
      let y = sp['y'] as number;
      let color = sp['color'] as string;
      let width = sp['width'] as number;
      let type = sp['type'] as string;

      if (type === 'start') {
        // 绘制起点
        this.canvasContext.beginPath();
        this.canvasContext.arc(x, y, width / 2, 0, 2 * Math.PI);
        this.canvasContext.fillStyle = color;
        this.canvasContext.fill();
      } else if ((type === 'move' || type === 'end') && i > 0) {
        // 绘制连线
        let prev = strokes[i - 1] as Record<string, Object>;
        let prevType = prev['type'] as string;
        if (prevType !== 'end') {
          this.canvasContext.beginPath();
          this.canvasContext.moveTo(prev['x'] as number, prev['y'] as number);
          this.canvasContext.lineTo(x, y);
          this.canvasContext.strokeStyle = color;
          this.canvasContext.lineWidth = width;
          this.canvasContext.lineCap = 'round';
          this.canvasContext.lineJoin = 'round';
          this.canvasContext.stroke();
        }
      }
    }
  }
}
