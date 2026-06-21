/**
 * Index - 游戏主页面（角色选择 + 游戏界面）
 *
 * 使用响应式布局（断点系统）适配手机（竖屏）、折叠屏（展开态）、平板（横屏）。
 * 角色分为：
 * - 画板端（host）：负责出题、绘画、判断对错、计分
 * - 猜题端（guesser）：观看绘画、提交答案
 *
 * 【分布式能力使用】
 * 1. 分布式数据对象：实时同步绘画笔迹、得分、答案
 * 2. 设备发现：自动发现组网内设备
 * 3. 跨端迁移：画板端支持无缝迁移到另一设备
 */
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DistributedDataObjectUtil } from '../common/utils/DistributedDataObjectUtil';
import { VibratorUtil } from '../common/utils/VibratorUtil';
import { StrokePoint } from '../common/models/StrokePoint';
import { GameSessionData } from '../common/models/GameSessionData';
import { AnswerRecord } from '../common/models/PlayerInfo';
import { RoomManager } from '../features/collaboration/RoomManager';
import { DrawingCanvas } from '../features/drawing/DrawingCanvas';
import { DrawingToolbar } from '../features/drawing/DrawingToolbar';
import { GuessingCanvas } from '../features/guessing/GuessingCanvas';
import { AnswerSubmit } from '../features/guessing/AnswerSubmit';
import { ScoreBoard } from '../features/guessing/ScoreBoard';

const TAG = 'Index';
const DOMAIN = 0x0008;

/** 预置词库（至少10个词） */
const WORD_BANK: string[] = [
  '熊猫', '飞机', '手机', '太阳', '自行车',
  '冰淇淋', '电脑', '足球', '房子', '花朵',
  '月亮', '火箭', '猫咪', '吉他', '雨伞'
];

@Entry
@Component
struct Index {
  /** 当前角色: ''=未选择, 'host'=画板端, 'guesser'=猜题端 */
  @StorageLink('userRole') userRole: string = '';
  /** 当前断点: sm/md/lg */
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';

  /** 分布式数据对象工具 */
  private ddoUtil: DistributedDataObjectUtil | null = null;
  /** 房间管理器 */
  private roomManager: RoomManager | null = null;

  /** 游戏状态 */
  @State gameState: string = 'idle';
  /** 当前题目（仅画板端显示） */
  @State currentWord: string = '';
  /** 画笔颜色 */
  @State penColor: string = '#FF0000';
  /** 画笔粗细 */
  @State penWidth: number = 6;
  /** 笔迹数据 */
  @State strokes: object[] = [];
  /** 得分数据 */
  @State scoresData: Record<string, Object> = {};
  /** 答案列表 */
  @State answers: object[] = [];
  /** 猜题端得分 */
  @State myScore: number = 0;
  /** 分数版本号（触发重绘） */
  @State scoreUpdateVersion: number = 0;
  /** 本地设备名称 */
  @State localDeviceName: string = '';
  /** 本地networkId */
  @State localNetworkId: string = '';
  /** 清屏信号 */
  @State clearSignal: number = 0;
  /** 笔迹版本号（撤销后触发重绘） */
  @State strokesVersion: number = 0;
  /** 设备列表 */
  @State availableDevices: object[] = [];
  @State showDeviceList: boolean = false;
  /** 是否正在初始化 */
  @State isInitializing: boolean = true;
  /** 当前房间号（画板端创建后显示，猜题端据此加入） */
  @StorageProp('gameSessionId') gameSessionId: string = '';
  /** 设备列表中选中的设备ID */
  @State selectedDeviceId: string = '';

  /** 迁移恢复标记 */
  @StorageProp('isContinuationRestored') isContinuationRestored: boolean = false;

  aboutToAppear(): void {
    try {
      this.registerBreakpointObserver();
    } catch (e) {
      hilog.warn(DOMAIN, TAG, 'breakpoint observer failed, using default');
      AppStorage.setOrCreate<string>('currentBreakpoint', 'sm');
    }

    try {
      let context = getContext(this) as common.UIAbilityContext;
      this.roomManager = new RoomManager(context);

      // 初始化设备发现（分布式软总线组网）
      this.roomManager.init();

      // 监听发现的设备列表变化
      this.roomManager.setOnPlayersChanged((devices: object[]) => {
        this.availableDevices = devices;
        hilog.info(DOMAIN, TAG, `Available devices updated: ${devices.length}`);
      });

      // 初始化本地设备名
      this.localDeviceName = this.roomManager.getLocalDeviceName();
      this.localNetworkId = this.roomManager.getLocalNetworkId();
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'RoomManager init failed (simulator expected), using fallback');
      this.localDeviceName = 'LocalDevice';
      this.localNetworkId = 'local_' + Date.now().toString();
    }

    // 检查是否通过迁移恢复
    let storedRole = AppStorage.get<string>('userRole');
    if (this.isContinuationRestored && storedRole) {
      this.userRole = storedRole;
      this.isInitializing = false;
      this.initializeGame();
    } else if (storedRole === 'guesser' && AppStorage.get<string>('gameSessionId')) {
      this.userRole = 'guesser';
      this.isInitializing = false;
      this.initializeGame();
    }
  }

  aboutToDisappear(): void {
    if (this.ddoUtil) {
      this.ddoUtil.destroy();
    }
    if (this.roomManager) {
      this.roomManager.release();
    }
  }

  /**
   * 注册断点监听器（响应式布局）
   * 通过监听窗口尺寸变化动态切换 sm/md/lg 断点，
   * 实现手机 / 折叠屏 / 平板的自适应布局切换。
   */
  private registerBreakpointObserver(): void {
    // 模拟器/部分设备上窗口API不可用，使用AppStorage默认值'sm'
    // 真机上EntryAbility中已预设 currentBreakpoint = 'sm'
    // 用户可通过真机窗口事件更新断点
    try {
      let context = getContext(this) as common.UIAbilityContext;
      window.getLastWindow(context, (err, mainWindow) => {
        if (err || !mainWindow) {
          hilog.warn(DOMAIN, TAG, 'getLastWindow failed, using default breakpoint');
          return;
        }
        mainWindow.on('windowSizeChange', (size: window.Size) => {
          let w: number = size.width;
          let bp: string;
          if (w < 600) {
            bp = 'sm';
          } else if (w < 840) {
            bp = 'md';
          } else {
            bp = 'lg';
          }
          AppStorage.setOrCreate<string>('currentBreakpoint', bp);
          hilog.info(DOMAIN, TAG, `Breakpoint changed: ${bp} (width=${w})`);
        });
        // 初始化时触发一次
        let props = mainWindow.getWindowProperties();
        let initW: number = props.windowRect.width;
        let initBp: string;
        if (initW < 600) {
          initBp = 'sm';
        } else if (initW < 840) {
          initBp = 'md';
        } else {
          initBp = 'lg';
        }
        AppStorage.setOrCreate<string>('currentBreakpoint', initBp);
      });
    } catch (e) {
      hilog.warn(DOMAIN, TAG, 'registerBreakpointObserver failed, using default');
    }
  }

  /**
   * 初始化游戏
   */
  private initializeGame(): void {
    let context = getContext(this) as common.UIAbilityContext;
    this.ddoUtil = new DistributedDataObjectUtil(context);

    if (this.userRole === 'host') {
      this.initAsHost();
    } else if (this.userRole === 'guesser') {
      this.initAsGuesser();
    }
  }

  /**
   * 【画板端】初始化
   */
  private async initAsHost(): Promise<void> {
    let gameData = new GameSessionData('');
    gameData.hostDeviceId = this.localNetworkId;
    gameData.gameStatus = 'drawing';

    if (this.ddoUtil) {
      let sessionId = await this.ddoUtil.createAsHost(gameData);
      if (sessionId) {
        AppStorage.setOrCreate<string>('gameSessionId', sessionId);
        this.ddoUtil.setHostDeviceId(this.localNetworkId);

        this.pickRandomWord();

        this.ddoUtil.setOnChangeCallback((sid: string, fields: Array<string>) => {
          this.onDistributedDataChanged(fields);
        });

        this.gameState = 'drawing';
        hilog.info(DOMAIN, TAG, `Host initialized, sessionId: ${sessionId}`);
      }
    }
    if (this.roomManager) {
      this.roomManager.createRoom(AppStorage.get<string>('gameSessionId') || '');
    }
  }

  /**
   * 【猜题端】初始化 - 使用已有sessionId加入分布式组网
   */
  private async initAsGuesser(): Promise<void> {
    let storedSessionId = AppStorage.get<string>('gameSessionId') || '';

    if (this.ddoUtil && storedSessionId) {
      let success = await this.ddoUtil.joinAsGuest(storedSessionId);
      if (success) {
        this.ddoUtil.setOnChangeCallback((sid: string, fields: Array<string>) => {
          this.onDistributedDataChanged(fields);
        });

        setTimeout(() => {
          this.syncLocalStateFromDDO();
        }, 500);

        hilog.info(DOMAIN, TAG, `Guesser joined session: ${storedSessionId}`);
      }
    }
  }

  /**
   * 分布式数据变更处理
   */
  private onDistributedDataChanged(fields: Array<string>): void {
    if (!this.ddoUtil) {
      return;
    }

    hilog.info(DOMAIN, TAG, `Data changed fields: ${JSON.stringify(fields)}`);

    if (fields.includes('strokes')) {
      this.strokes = [...this.ddoUtil.getStrokes()];
    }

    if (fields.includes('scores')) {
      this.scoresData = this.ddoUtil.getScores();
      if (this.userRole === 'guesser') {
        let keys = Object.keys(this.scoresData);
        for (let i = 0; i < keys.length; i++) {
          let key = keys[i];
          let data = this.scoresData[key] as Record<string, Object>;
          if (key === this.localNetworkId) {
            this.myScore = (data['score'] as number) || 0;
          }
        }
      }
      this.scoreUpdateVersion++;
    }

    if (fields.includes('answers')) {
      this.answers = [...this.ddoUtil.getAnswers()];
      if (this.userRole === 'guesser') {
        this.checkAnswerResult();
      }
    }

    if (fields.includes('gameStatus')) {
      this.gameState = this.ddoUtil.getGameStatus();
      if (this.userRole === 'guesser' && this.gameState === 'drawing') {
        this.strokes = [];
      }
    }
  }

  /**
   * 从分布式数据对象同步本地状态
   */
  private syncLocalStateFromDDO(): void {
    if (!this.ddoUtil) {
      return;
    }
    this.strokes = [...this.ddoUtil.getStrokes()];
    this.scoresData = this.ddoUtil.getScores();
    this.answers = [...this.ddoUtil.getAnswers()];
    this.gameState = this.ddoUtil.getGameStatus();

    if (this.userRole === 'guesser') {
      let scores = this.ddoUtil.getScores();
      let myData = scores[this.localNetworkId] as Record<string, Object>;
      if (myData) {
        this.myScore = (myData['score'] as number) || 0;
      }
    }
  }

  // ==================== 画板端操作 ====================

  private onStrokeComplete(strokePoints: StrokePoint[]): void {
    if (!this.ddoUtil || this.userRole !== 'host') {
      return;
    }
    this.ddoUtil.addStrokes(strokePoints);
    this.strokes = [...this.ddoUtil.getStrokes()];
  }

  private onClear(): void {
    if (!this.ddoUtil) {
      return;
    }
    this.ddoUtil.clearStrokes();
    this.strokes = [];
    this.clearSignal++;
    this.strokesVersion++;
  }

  private onUndo(): void {
    if (!this.ddoUtil) {
      return;
    }
    this.ddoUtil.undoLastStroke();
    this.strokes = [...this.ddoUtil.getStrokes()];
    this.strokesVersion++;
  }

  private onNextWord(): void {
    this.pickRandomWord();
    this.onClear();
    this.gameState = 'drawing';
    if (this.ddoUtil) {
      this.ddoUtil.setGameStatus('drawing');
      this.ddoUtil.clearStrokes();
      this.ddoUtil.incrementRound();
      this.ddoUtil.clearAnswers();
    }
    this.strokes = [];
    this.answers = [];
  }

  private pickRandomWord(): void {
    let index = Math.floor(Math.random() * WORD_BANK.length);
    this.currentWord = WORD_BANK[index];
    AppStorage.setOrCreate<string>('currentWord', this.currentWord);
    if (this.ddoUtil) {
      this.ddoUtil.setLocalCurrentWord(this.currentWord);
    }
    hilog.info(DOMAIN, TAG, `New word picked: ${this.currentWord}`);
  }

  private onJudgeCorrect(answerIndex: number): void {
    if (!this.ddoUtil) {
      return;
    }
    this.ddoUtil.updateAnswerJudgment(answerIndex, true);
    this.answers = [...this.ddoUtil.getAnswers()];
    this.scoresData = this.ddoUtil.getScores();
    this.scoreUpdateVersion++;
  }

  private onJudgeWrong(answerIndex: number): void {
    if (!this.ddoUtil) {
      return;
    }
    this.ddoUtil.updateAnswerJudgment(answerIndex, false);
    this.answers = [...this.ddoUtil.getAnswers()];
  }

  // ==================== 猜题端操作 ====================

  private onSubmitGuess(answer: string): void {
    if (!this.ddoUtil || this.userRole !== 'guesser') {
      return;
    }
    let record = new AnswerRecord(this.localNetworkId, this.localDeviceName, answer);
    this.ddoUtil.submitAnswer(record);
    this.answers = [...this.ddoUtil.getAnswers()];
  }

  private checkAnswerResult(): void {
    if (!this.ddoUtil) {
      return;
    }
    let allAnswers = this.ddoUtil.getAnswers();
    for (let i = allAnswers.length - 1; i >= 0; i--) {
      let answer = allAnswers[i] as Record<string, Object>;
      if (answer['playerId'] === this.localNetworkId &&
        answer['isJudged'] === true &&
        answer['isCorrect'] === true) {
        VibratorUtil.vibrateCorrect();
        break;
      }
    }
  }

  // ==================== UI构建 ====================

  build() {
    if (this.userRole === '') {
      this.RoleSelectionPage()
    } else if (this.currentBreakpoint === 'lg') {
      this.TabletLayout()
    } else {
      this.PhoneLayout()
    }
  }

  @Builder
  RoleSelectionPage() {
    Column() {
      Text('你画我猜')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 60, bottom: 40 })

      Text('请选择你的角色')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 40 })

      GridRow({
        columns: { sm: 2, md: 2, lg: 2 },
        gutter: { x: 16, y: 16 },
        breakpoints: { value: ['320vp', '600vp', '840vp'], reference: BreakpointsReference.WindowSize }
      }) {
        GridCol({ span: { sm: 2, md: 1, lg: 1 } }) {
          Column() {
            Text('\uD83C\uDFA8')
              .fontSize(48)
            Text('画板端（主持人）')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 12 })
            Text('负责出题、绘画\n判断对错、计分')
              .fontSize(13)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .backgroundColor('#E3F2FD')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.userRole = 'host';
            AppStorage.setOrCreate<string>('userRole', 'host');
            this.initializeGame();
          })
        }

        GridCol({ span: { sm: 2, md: 1, lg: 1 } }) {
          Column() {
            Text('\uD83E\uDD14')
              .fontSize(48)
            Text('猜题端（玩家）')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 12 })
            Text('观看绘画过程\n提交答案猜词')
              .fontSize(13)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .backgroundColor('#FFF3E0')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.userRole = 'guesser';
            AppStorage.setOrCreate<string>('userRole', 'guesser');
            this.showDeviceList = true;
          })
        }
      }
      .width('90%')
      .padding({ top: 20 })

      if (this.showDeviceList && this.userRole === 'guesser') {
        this.DeviceSelectionDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  DeviceSelectionDialog() {
    Column() {
      Text('加入游戏房间')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.availableDevices.length > 0) {
        Text('附近设备:')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        List({ space: 8 }) {
          ForEach(this.availableDevices, (device: Record<string, Object>, index: number) => {
            ListItem() {
              Row({ space: 8 }) {
                Text('\uD83D\uDCF1')
                  .fontSize(20)
                Column({ space: 2 }) {
                  Text((device['deviceName'] as string) || '未知设备')
                    .fontSize(14)
                    .fontColor('#333333')
                  Text((device['deviceType'] as string) || '')
                    .fontSize(11)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(
                this.selectedDeviceId === (device['networkId'] as string) ? '#E3F2FD' : '#F5F5F5'
              )
              .borderRadius(8)
              .onClick(() => {
                this.selectedDeviceId = (device['networkId'] as string) || '';
              })
            }
          }, (device: Record<string, Object>, index: number) =>
            (device['networkId'] as string) || index.toString())
        }
        .width('100%')
        .height(120)
        .margin({ bottom: 12 })

        Divider().strokeWidth(1).color('#E0E0E0').margin({ bottom: 12 })
      }

      Text('请输入画板端的SessionId')
        .fontSize(13)
        .fontColor('#666666')
        .margin({ bottom: 12 })

      TextInput({ placeholder: '输入画板端的SessionId' })
        .width('100%')
        .height(40)
        .fontSize(14)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => {
          AppStorage.setOrCreate<string>('gameSessionId', value);
        })
        .margin({ bottom: 16 })

      Button('加入房间')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#4CAF50')
        .borderRadius(22)
        .onClick(() => {
          this.showDeviceList = false;
          this.initializeGame();
        })

      Button('取消')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#F5F5F5')
        .fontColor('#666666')
        .borderRadius(22)
        .margin({ top: 8 })
        .onClick(() => {
          this.showDeviceList = false;
          this.userRole = '';
          AppStorage.setOrCreate<string>('userRole', '');
        })
    }
    .width('80%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 20, color: '#00000020' })
    .constraintSize({ maxHeight: '80%' })
  }

  @Builder
  PhoneLayout() {
    Column() {
      this.TopInfoBar();

      if (this.userRole === 'host') {
        Column() {
          DrawingCanvas({
            currentColor: this.penColor,
            currentWidth: this.penWidth,
            clearSignal: this.clearSignal,
            strokes: this.strokes,
            strokesVersion: this.strokesVersion,
            onStrokeComplete: (pts: StrokePoint[]) => {
              this.onStrokeComplete(pts);
            }
          })
        }
        .layoutWeight(1)
        .width('100%')

        DrawingToolbar({
          currentColor: $penColor,
          currentWidth: $penWidth,
          onClear: () => { this.onClear(); },
          onUndo: () => { this.onUndo(); },
          onNextWord: () => { this.onNextWord(); }
        })

        this.HostAnswerJudgmentArea();
      } else {
        Column() {
          GuessingCanvas({ strokes: this.strokes })
        }
        .layoutWeight(1)
        .width('100%')
        .onVisibleAreaChange([0, 1], (isExpanding: boolean, currentRatio: number) => {
          this.syncLocalStateFromDDO();
        })

        Column() {
          AnswerSubmit({
            currentScore: this.myScore,
            historyAnswers: $answers,
            onSubmitAnswer: (answer: string) => {
              this.onSubmitGuess(answer);
            }
          })

          ScoreBoard({
            scoresData: this.scoresData,
            currentPlayerId: this.localNetworkId
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  @Builder
  TabletLayout() {
    Row() {
      if (this.userRole === 'host') {
        Column() {
          DrawingCanvas({
            currentColor: this.penColor,
            currentWidth: this.penWidth,
            clearSignal: this.clearSignal,
            strokes: this.strokes,
            strokesVersion: this.strokesVersion,
            onStrokeComplete: (pts: StrokePoint[]) => {
              this.onStrokeComplete(pts);
            }
          })
        }
        .layoutWeight(1)
        .height('100%')
        .padding(12)

        Column({ space: 8 }) {
          DrawingToolbar({
            currentColor: $penColor,
            currentWidth: $penWidth,
            onClear: () => { this.onClear(); },
            onUndo: () => { this.onUndo(); },
            onNextWord: () => { this.onNextWord(); }
          })

          Divider().strokeWidth(1).color('#E0E0E0')

          this.HostAnswerJudgmentArea();
        }
        .width(260)
        .height('100%')
        .padding(8)
        .backgroundColor('#FAFAFA')
      } else {
        Column() {
          GuessingCanvas({ strokes: this.strokes })
        }
        .layoutWeight(1)
        .height('100%')
        .padding(12)

        Column({ space: 8 }) {
          AnswerSubmit({
            currentScore: this.myScore,
            historyAnswers: $answers,
            onSubmitAnswer: (answer: string) => {
              this.onSubmitGuess(answer);
            }
          })

          ScoreBoard({
            scoresData: this.scoresData,
            currentPlayerId: this.localNetworkId
          })
        }
        .width(280)
        .height('100%')
        .padding(8)
        .backgroundColor('#FAFAFA')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  @Builder
  TopInfoBar() {
    Row() {
      Text(this.userRole === 'host' ? '画板端' : '猜题端')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor(this.userRole === 'host' ? '#2196F3' : '#FF9800')
        .borderRadius(12)

      if (this.ddoUtil !== null && this.ddoUtil.isLocal) {
        Text('模拟器')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor('#9C27B0')
          .borderRadius(8)
          .margin({ left: 6 })
      }

      Blank()

      if (this.userRole === 'host') {
        Text(`题目: ${this.currentWord || '暂无'}`)
          .fontSize(14)
          .fontColor('#FF5722')
          .fontWeight(FontWeight.Bold)
          .padding({ left: 8, right: 8 })

        Text(`第 ${AppStorage.get<number>('roundNumber') || 1} 轮`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 8 })

        Text(`房间号: ${this.gameSessionId || '创建中...'}`)
          .fontSize(12)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }

      Blank()

      Text(this.localDeviceName)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('100%')
    .height(36)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 画板端答案判定区域
   */
  @Builder
  HostAnswerJudgmentArea() {
    Column({ space: 4 }) {
      if (this.answers.length > 0) {
        Text('玩家答案:')
          .fontSize(12)
          .fontColor('#666666')
          .width('100%')
          .padding({ left: 8, top: 4 })

        List({ space: 4 }) {
          ForEach(this.answers, (item: Record<string, Object>, index: number) => {
            ListItem() {
              Row({ space: 6 }) {
                Text(((item['playerName'] as string) || '未知'))
                  .fontSize(11)
                  .fontColor('#333333')
                  .maxLines(1)
                  .width(50)

                Text((item['answer'] as string) || '')
                  .fontSize(13)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                  .maxLines(1)

                if (item['isJudged'] === true) {
                  Text(item['isCorrect'] === true ? '✓' : '✗')
                    .fontSize(11)
                    .fontColor(item['isCorrect'] === true ? '#4CAF50' : '#FF6B6B')
                } else {
                  Row({ space: 4 }) {
                    Button('✓')
                      .fontSize(10)
                      .width(28)
                      .height(24)
                      .backgroundColor('#4CAF50')
                      .borderRadius(4)
                      .onClick(() => {
                        this.onJudgeCorrect(index as number);
                      })

                    Button('✗')
                      .fontSize(10)
                      .width(28)
                      .height(24)
                      .backgroundColor('#FF6B6B')
                      .borderRadius(4)
                      .onClick(() => {
                        this.onJudgeWrong(index as number);
                      })
                  }
                }
              }
              .width('100%')
              .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            }
          }, (item: Record<string, Object>, index: number) => index.toString())
        }
        .width('100%')
        .height(120)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(4)
      }

      ScoreBoard({
        scoresData: this.scoresData,
        currentPlayerId: this.localNetworkId
      })
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }
}
