/**
 * DrawingToolbar - 画板端工具按钮组件
 *
 * 【工具功能】
 * - 画笔颜色选择（红、黑、蓝）
 * - 画笔粗细滑动条（2-20px）
 * - 清屏按钮
 * - 撤销按钮（撤销操作也会同步给所有猜题端）
 * - 下一题按钮（随机从词库抽取新题）
 *
 * 【响应式布局】
 * - 手机（sm/md）：横向排列在画布下方
 * - 平板/折叠屏展开（lg）：竖向排列在画布右侧
 */
@Component
export struct DrawingToolbar {
  /** 当前选中的颜色 */
  @Link currentColor: string;
  /** 当前画笔粗细 */
  @Link currentWidth: number;
  /** 当前断点标识 */
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';

  /** 颜色选择回调 */
  onColorChange?: (color: string) => void;
  /** 粗细变更回调 */
  onWidthChange?: (width: number) => void;
  /** 清屏回调 - 触发清屏并同步 */
  onClear?: () => void;
  /** 撤销回调 - 触发撤销并同步 */
  onUndo?: () => void;
  /** 下一题回调 */
  onNextWord?: () => void;

  /** 可选颜色列表 */
  private colors: string[] = ['#FF0000', '#000000', '#0000FF'];
  private colorNames: string[] = ['红', '黑', '蓝'];

  build() {
    // 【响应式布局】根据断点判断是横向（手机）还是竖向（平板）排列
    if (this.currentBreakpoint === 'lg') {
      // 平板/折叠屏展开态：竖向排列在右侧
      Column({ space: 8 }) {
        this.buildColorButtons()
        this.buildWidthSlider()
        this.buildActionButtons()
      }
      .padding(12)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .width(80)
      .height('100%')
    } else {
      // 手机：横向排列在底部
      Row({ space: 6 }) {
        this.buildColorButtons()
        this.buildWidthSlider()
        this.buildActionButtons()
      }
      .padding(8)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
    }
  }

  /**
   * 构建颜色选择按钮组
   */
  @Builder
  buildColorButtons() {
    if (this.currentBreakpoint === 'lg') {
      Column({ space: 6 }) {
        ForEach(this.colors, (color: string, index: number) => {
          Button() {
            Circle({ width: 24, height: 24 })
              .fill(color)
          }
          .width(44)
          .height(44)
          .backgroundColor(this.currentColor === color ? '#E0E0E0' : '#FFFFFF')
          .border({
            width: this.currentColor === color ? 2 : 1,
            color: this.currentColor === color ? color : '#CCCCCC'
          })
          .borderRadius(22)
          .onClick(() => {
            this.currentColor = color;
            if (this.onColorChange) {
              this.onColorChange(color);
            }
          })
        })
      }
    } else {
      Row({ space: 6 }) {
        ForEach(this.colors, (color: string, index: number) => {
          Button() {
            Circle({ width: 20, height: 20 })
              .fill(color)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.currentColor === color ? '#E0E0E0' : '#FFFFFF')
          .border({
            width: this.currentColor === color ? 2 : 1,
            color: this.currentColor === color ? color : '#CCCCCC'
          })
          .borderRadius(18)
          .onClick(() => {
            this.currentColor = color;
            if (this.onColorChange) {
              this.onColorChange(color);
            }
          })
        })
      }
    }
  }

  /**
   * 构建画笔粗细滑动条
   */
  @Builder
  buildWidthSlider() {
    Column({ space: 4 }) {
      Text(`${this.currentWidth}px`)
        .fontSize(10)
        .fontColor('#666666')
      Slider({
        value: this.currentWidth,
        min: 2,
        max: 20,
        step: 1,
        style: SliderStyle.OutSet
      })
        .width(this.currentBreakpoint === 'lg' ? 60 : 80)
        .height(20)
        .onChange((value: number) => {
          this.currentWidth = value;
          if (this.onWidthChange) {
            this.onWidthChange(value);
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建操作按钮组（清屏、撤销、下一题）
   */
  @Builder
  buildActionButtons() {
    if (this.currentBreakpoint === 'lg') {
      Column({ space: 8 }) {
        Button('清屏')
          .fontSize(11)
          .width(56)
          .height(32)
          .backgroundColor('#FF6B6B')
          .borderRadius(8)
          .onClick(() => {
            if (this.onClear) {
              this.onClear();
            }
          })

        Button('撤销')
          .fontSize(11)
          .width(56)
          .height(32)
          .backgroundColor('#FFA500')
          .borderRadius(8)
          .onClick(() => {
            if (this.onUndo) {
              this.onUndo();
            }
          })

        Button('下一题')
          .fontSize(11)
          .width(56)
          .height(32)
          .backgroundColor('#4CAF50')
          .borderRadius(8)
          .onClick(() => {
            if (this.onNextWord) {
              this.onNextWord();
            }
          })
      }
    } else {
      Row({ space: 6 }) {
        Button('清屏')
          .fontSize(10)
          .height(32)
          .backgroundColor('#FF6B6B')
          .borderRadius(8)
          .onClick(() => {
            if (this.onClear) {
              this.onClear();
            }
          })

        Button('撤销')
          .fontSize(10)
          .height(32)
          .backgroundColor('#FFA500')
          .borderRadius(8)
          .onClick(() => {
            if (this.onUndo) {
              this.onUndo();
            }
          })

        Button('下一题')
          .fontSize(10)
          .height(32)
          .backgroundColor('#4CAF50')
          .borderRadius(8)
          .onClick(() => {
            if (this.onNextWord) {
              this.onNextWord();
            }
          })
      }
    }
  }
}
