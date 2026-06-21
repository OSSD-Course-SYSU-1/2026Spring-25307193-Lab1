/**
 * ScoreBoard - 得分展示组件
 *
 * 【双端共用】
 * - 画板端：显示所有玩家的得分排名
 * - 猜题端：显示自己的得分和全局排名
 *
 * 数据来源：分布式数据对象中的scores字段
 */
@Component
export struct ScoreBoard {
  /** 得分数据 */
  @Prop scoresData: Record<string, Object> = {};
  /** 当前玩家ID（猜题端用于高亮自己） */
  @Prop currentPlayerId: string = '';

  build() {
    Column() {
      Text('得分榜')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      if (Object.keys(this.scoresData).length === 0) {
        Text('暂无得分数据')
          .fontSize(12)
          .fontColor('#999999')
      } else {
        // 将得分数据转换为数组并排序
        List({ space: 4 }) {
          ForEach(
            this.getSortedScores(),
            (item: ScoreItem) => {
              ListItem() {
                Row({ space: 8 }) {
                  // 排名
                  Text(`${item.rank}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.rank <= 3 ? '#FFA500' : '#666666')
                    .width(24)
                    .textAlign(TextAlign.Center)

                  // 玩家名称
                  Text(item.name)
                    .fontSize(13)
                    .fontColor('#333333')
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 得分
                  Text(`${item.score}分`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#4CAF50')
                }
                .width('100%')
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .backgroundColor(
                  item.networkId === this.currentPlayerId ? '#E3F2FD' : '#FFFFFF'
                )
                .borderRadius(4)
              }
            }
          )
        }
        .width('100%')
        .height(150)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .padding(4)
      }
    }
    .width('100%')
    .padding(8)
  }

  /**
   * 获取排序后的得分列表
   */
  private getSortedScores(): ScoreItem[] {
    let items: ScoreItem[] = [];
    let keys = Object.keys(this.scoresData);
    for (let key of keys) {
      let data = this.scoresData[key] as Record<string, Object>;
      if (data) {
        items.push({
          networkId: key,
          name: (data['name'] as string) || '未知玩家',
          score: (data['score'] as number) || 0,
          rank: 0
        });
      }
    }
    // 按得分降序排列
    items.sort((a, b) => b.score - a.score);
    // 设置排名
    for (let i = 0; i < items.length; i++) {
      items[i].rank = i + 1;
    }
    return items;
  }
}

/**
 * 得分项接口
 */
interface ScoreItem {
  networkId: string;
  name: string;
  score: number;
  rank: number;
}
