/**
 * AnswerSubmit - 猜题端答案提交组件
 *
 * 【核心功能】
 * - 文本输入框 + 提交按钮
 * - 显示当前得分
 * - 显示历史提交记录
 *
 * 【交互流程】
 * 1. 玩家在输入框输入猜测答案
 * 2. 点击"提交"按钮
 * 3. 通过回调将答案传递给父组件，由父组件通过分布式数据对象提交到画板端
 */
@Component
export struct AnswerSubmit {
  /** 输入的答案文本 */
  @State answerText: string = '';
  /** 当前玩家得分 */
  @Prop currentScore: number = 0;
  /** 历史提交记录 */
  @Link historyAnswers: object[];

  /** 提交答案回调 */
  onSubmitAnswer?: (answer: string) => void;

  build() {
    Column({ space: 8 }) {
      // 当前得分显示
      Row() {
        Text('我的得分: ')
          .fontSize(14)
          .fontColor('#333333')
        Text(`${this.currentScore}`)
          .fontSize(18)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.Start)

      // 输入框和提交按钮
      Row({ space: 8 }) {
        TextInput({ placeholder: '输入你的猜测...', text: this.answerText })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.answerText = value;
          })

        Button('提交')
          .fontSize(14)
          .width(60)
          .height(40)
          .backgroundColor('#2196F3')
          .borderRadius(8)
          .enabled(this.answerText.trim().length > 0)
          .onClick(() => {
            if (this.answerText.trim().length > 0) {
              if (this.onSubmitAnswer) {
                this.onSubmitAnswer(this.answerText.trim());
              }
              this.answerText = '';
            }
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      // 历史提交记录
      if (this.historyAnswers.length > 0) {
        Text('提交记录:')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .padding({ left: 12 })

        List({ space: 4 }) {
          ForEach(this.historyAnswers, (item: Record<string, Object>, index: number) => {
            ListItem() {
              Row({ space: 8 }) {
                Text(`${(index as number) + 1}. ${item['answer'] as string}`)
                  .fontSize(12)
                  .fontColor('#666666')
                  .layoutWeight(1)

                if (item['isJudged'] as boolean) {
                  Text((item['isCorrect'] as boolean) ? '✓' : '✗')
                    .fontSize(14)
                    .fontColor((item['isCorrect'] as boolean) ? '#4CAF50' : '#FF6B6B')
                    .fontWeight(FontWeight.Bold)
                } else {
                  Text('待判定...')
                    .fontSize(11)
                    .fontColor('#FFA500')
                }
              }
              .width('100%')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            }
          })
        }
        .width('100%')
        .height(100)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .padding(4)
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }
}
