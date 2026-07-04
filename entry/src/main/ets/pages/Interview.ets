import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { InterviewResult } from '../model/Interview';
import { InterviewService } from '../service/InterviewService';

interface SkillOption {
  label: string;
  value: string;
}

@Entry
@Component
struct Interview {
  @State private skillOptions: SkillOption[] = [
    { label: '前端', value: 'FRONTEND' },
    { label: '后端', value: 'BACKEND' },
    { label: '数据库', value: 'DATABASE' },
    { label: 'DevOps', value: 'DEVOPS' }
  ];
  @State private currentSkill: string = 'FRONTEND';
  
  // 核心单题状态
  @State sessionId: number = 0;
  @State currentQuestionText: string = '';
  @State currentQuestionId: number = 0;
  @State inputAnswer: string = '';
  
  @State private isLoading: boolean = false;
  @State private isSubmitting: boolean = false;
  
  // 报告态
  @State private result: InterviewResult | null = null;

  aboutToAppear(): void {
    this.startInterview(this.currentSkill);
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(18)
          .fontColor('#1a1c1c')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onClick(() => { router.back(); })

        Text('模拟面试')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#005ea1')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(' ')
          .width(42)
      }
      .width('100%')
      .height(48)
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      Scroll() {
        Column({ space: 12 }) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.skillOptions, (opt: SkillOption) => {
                Text(opt.label)
                  .fontSize(12)
                  .fontColor(this.currentSkill === opt.value ? Color.White : '#414751')
                  .backgroundColor(this.currentSkill === opt.value ? '#007DFF' : '#e9e8e8')
                  .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                  .borderRadius(16)
                  .onClick(() => {
                    if (this.currentSkill === opt.value) return;
                    this.currentSkill = opt.value;
                    this.startInterview(opt.value);
                  })
              }, (opt: SkillOption) => opt.value)
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.isLoading) {
            Column() {
              Text('正在启动面试...')
                .fontSize(14)
                .fontColor('#909399')
            }
            .height(180)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else if (this.result) {
            // 报告页面
            Row() {
              Column({ space: 6 }) {
                Text('本次面试结果')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1c1c')
                Row() {
                  Text(`得分：${this.result.score}`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#005ea1')
                }.alignItems(VerticalAlign.Bottom)

                if (this.result.feedback) {
                  Text('AI 综合考评语')
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1a1c1c')
                    .margin({ top: 8 })
                  Text(this.result.feedback)
                    .fontSize(12)
                    .fontColor('#414751')
                    .lineHeight(20)
                    .margin({ top: 4 })
                }
              }.alignItems(HorizontalAlign.Start)
              Blank()
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#E6F0FF')
            .borderRadius(12)
            .margin({ top: 4 })
          } else if (this.currentQuestionId > 0) {
            // 答题区域
            Column({ space: 10 }) {
              Text(this.currentQuestionText)
                .fontSize(14)
                .fontColor('#1a1c1c')
                .fontWeight(FontWeight.Bold)
                .width('100%')

              TextArea({ text: this.inputAnswer, placeholder: '请输入你的回答（支持要点式）' })
                .width('100%')
                .height(160)
                .backgroundColor('#f7f7f7')
                .borderRadius(12)
                .padding(12)
                .fontSize(13)
                .onChange((val: string) => { this.inputAnswer = val; })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
          } else {
            Column() {
              Text('暂无题目')
                .fontSize(14)
                .fontColor('#909399')
            }
            .height(180)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }

          Blank().height(92)
        }
        .padding(16)
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (!this.result) {
        Row() {
          Button(this.isSubmitting ? '提交中...' : '提交并进入下一题')
            .width('92%')
            .height(48)
            .backgroundColor('#4A90D9')
            .fontColor(Color.White)
            .fontSize(16)
            .borderRadius(24)
            .enabled(!this.isSubmitting && this.inputAnswer.trim().length > 0)
            .onClick(() => { this.submitCurrentAnswer(); })
        }
        .width('100%')
        .height(72)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#e3e2e2' })
      } else {
        Row() {
          Button('重新面试')
            .width('92%')
            .height(48)
            .backgroundColor(Color.White)
            .fontColor('#4A90D9')
            .fontSize(16)
            .border({ width: 1, color: '#4A90D9' })
            .borderRadius(24)
            .onClick(() => { this.startInterview(this.currentSkill); })
        }
        .width('100%')
        .height(72)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#e3e2e2' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private async startInterview(jobPosition: string): Promise<void> {
    this.isLoading = true;
    this.result = null;
    this.inputAnswer = '';
    this.currentQuestionId = 0;
    this.sessionId = 0;
    try {
      const res = await InterviewService.startInterview(jobPosition);
      this.sessionId = res.sessionId;
      this.currentQuestionId = res.questionId;
      this.currentQuestionText = res.questionText;
    } catch (e) {
      let errorMessage = '未知错误';
      if (e instanceof Error) {
        errorMessage = e.message;
      } else if (typeof e === 'string') {
        errorMessage = e;
      } else {
        errorMessage = JSON.stringify(e);
      }
      promptAction.showToast({ message: '启动面试失败：' + errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  private async submitCurrentAnswer(): Promise<void> {
    if (this.isSubmitting || !this.inputAnswer.trim()) return;
    this.isSubmitting = true;
    try {
      const res = await InterviewService.submitAnswer(this.sessionId, this.currentQuestionId, this.inputAnswer);
      if (res.isCompleted) {
        await this.loadReport();
      } else if (res.questionId && res.questionText) {
        this.currentQuestionId = res.questionId;
        this.currentQuestionText = res.questionText;
        this.inputAnswer = ''; // 清空输入框进入下一题
      } else {
        // 如果后端既没有返回 isCompleted=true，也没有返回下一题（可能是因为后端只返回了 code:200 data:null 或者格式有误）
        // 按照容错逻辑，我们将其视为答题结束，尝试去拉取报告
        console.warn("未获取到下一题且 isCompleted 不为 true，尝试强制进入报告流转");
        await this.loadReport();
      }
    } catch (e) {
      let errorMessage = '未知错误';
      if (e instanceof Error) {
        errorMessage = e.message;
      } else if (typeof e === 'string') {
        errorMessage = e;
      } else {
        errorMessage = JSON.stringify(e);
      }
      promptAction.showToast({ message: '提交失败：' + errorMessage });
    } finally {
      this.isSubmitting = false;
    }
  }

  private async loadReport(): Promise<void> {
    this.isLoading = true; // 复用 isLoading 展示一个过渡态
    try {
      // 增加轮询等待机制，直到大模型生成出有效分数为止
      let retryCount = 0;
      let reportResult: InterviewResult | null = null;
      while (retryCount < 8) { // 最多重试 8 次，每次 5 秒，总计等待约 40 秒
        try {
          reportResult = await InterviewService.getReport(this.sessionId);
          // 如果拿到了真实对象且有评分，则说明后端生成完毕
          if (reportResult && reportResult.score !== undefined && reportResult.score !== null) {
            break;
          }
        } catch (e) {
          // 如果后端还没准备好（比如报 400 或 面试尚未完成），不抛出错误，而是静默等待重试
          console.info("报告未准备好，正在等待重试...");
        }
        retryCount++;
        await new Promise<void>(resolve => setTimeout(resolve, 5000)); // 每次等 5 秒
      }
      
      if (reportResult && reportResult.score !== undefined && reportResult.score !== null) {
        this.result = reportResult;
        promptAction.showToast({ message: '报告生成完毕' });
      } else {
        throw new Error('AI 评分超时，请稍后再试');
      }
    } catch (e) {
      let errorMessage = '未知错误';
      if (e instanceof Error) {
        errorMessage = e.message;
      } else if (typeof e === 'string') {
        errorMessage = e;
      } else {
        errorMessage = JSON.stringify(e);
      }
      promptAction.showToast({ message: '获取报告失败：' + errorMessage });
    } finally {
      this.isLoading = false;
    }
  }
}
