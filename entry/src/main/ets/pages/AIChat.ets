import { ChatMessage, ChatResponseData } from '../model/Message';
import { ChatService } from '../service/ChatService';
import util from '@ohos.util';

@Component
export struct AIChat {
  @Consume messages: ChatMessage[];
  @Consume conversationId: string;
  @Consume @Watch('onTabChange') currentIndex: number;

  @State inputText: string = '';
  @State isAnalyzing: boolean = false;
  
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    if (this.currentIndex === 2 && (!this.messages || this.messages.length === 0)) {
      this.loadData();
    } else if (this.currentIndex === 2) {
      this.scrollToBottom();
    }
  }

  onTabChange() {
    if (this.currentIndex === 2 && (!this.messages || this.messages.length === 0)) {
      this.loadData();
    } else if (this.currentIndex === 2) {
      this.scrollToBottom();
    }
  }

  public async loadData() {
    this.isAnalyzing = true;
    try {
      const data = await ChatService.getChatHistory();
      if (Array.isArray(data)) {
        this.messages = data;
      } else {
        this.messages = [];
      }
    } catch (e) {
      console.error("【核心网络错误日志】 错误码: " + (e.code || "未知") + ", 错误信息: " + (e.message || JSON.stringify(e)));
      this.messages = [];
    } finally {
      this.isAnalyzing = false;
      this.scrollToBottom();
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('AI智能对话').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#005ea1')
        Blank()
        Text('清空').fontSize(14).fontColor('#F56C6C').onClick(() => { this.messages = []; })
      }.width('100%').height(48).padding({ left: 16, right: 16 }).backgroundColor(Color.White).shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      // Chat List
      if (this.messages && this.messages.length > 0) {
        List({ space: 16, scroller: this.scroller }) {
          ListItem() {
            Text('今天 14:30').fontSize(10).fontColor('#909399').backgroundColor('#efeeed').padding({ left: 12, right: 12, top: 4, bottom: 4 }).borderRadius(12)
          }.width('100%').margin({ top: 16 })

          ForEach(this.messages, (msg: ChatMessage, index: number) => {
            ListItem() {
              this.MessageBubble(msg)
            }
          }, (msg: ChatMessage, index: number) => msg.id ? msg.id.toString() + index.toString() : index.toString())
          
          if (this.isAnalyzing) {
            ListItem() {
              Row() {
                Text('AI 正在思考中...').fontSize(14).fontColor('#909399').backgroundColor(Color.White).padding(12).borderRadius({ topLeft: 4, topRight: 12, bottomLeft: 12, bottomRight: 12 })
              }.width('100%').justifyContent(FlexAlign.Start)
            }
          }
        }
        .width('100%').layoutWeight(1).padding({ left: 16, right: 16, bottom: 16 }).backgroundColor('#F5F7FA')
      } else {
        Column() {
          Text(this.isAnalyzing ? "正在连接AI导师..." : "暂无对话记录，快来开启第一课吧！")
            .fontSize(14)
            .fontColor('#909399')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F7FA')
      }

      // Input Area
      Row() {
        TextInput({ text: this.inputText, placeholder: '输入你要提问的问题...' })
          .layoutWeight(1).height(40).backgroundColor('#efeeed').borderRadius(20).padding({ left: 16, right: 16 }).enterKeyType(EnterKeyType.Send)
          .onChange((val: string) => this.inputText = val).onSubmit(() => this.sendMessage())
        
        Button('发送').width(64).height(40).margin({ left: 12 }).backgroundColor(this.inputText.trim() ? '#4A90D9' : '#c1c7d2').fontColor(Color.White).borderRadius(20)
          .onClick(() => this.sendMessage()).enabled(this.inputText.trim().length > 0)
      }.width('100%').padding(12).backgroundColor(Color.White).border({ width: { top: 1 }, color: '#e3e2e2' })
    }.width('100%').height('100%')
  }

  @Builder
  MessageBubble(msg: ChatMessage) {
    Row() {
      if (msg.isMe) {
        Blank()
        Text(msg.text).fontSize(14).fontColor(Color.White).backgroundColor('#4A90D9').padding(12).borderRadius({ topLeft: 12, topRight: 4, bottomLeft: 12, bottomRight: 12 }).constraintSize({ maxWidth: '80%' })
      } else {
        Text(msg.text).fontSize(14).fontColor('#333333').backgroundColor(Color.White).padding(12).borderRadius({ topLeft: 4, topRight: 12, bottomLeft: 12, bottomRight: 12 }).constraintSize({ maxWidth: '80%' })
        Blank()
      }
    }.width('100%')
  }

  sendMessage() {
    const query = this.inputText.trim();
    if (!query) return;

    this.messages.push({ id: util.generateRandomUUID(true), text: query, isMe: true });
    this.inputText = '';
    this.scrollToBottom();
    this.isAnalyzing = true;
    this.requestAI(query);
  }

  scrollToBottom() {
    setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); }, 100);
  }

  async requestAI(query: string) {
    try {
      const result = await ChatService.sendMessage(query, this.conversationId);
      
      if (result.conversationId) {
        this.conversationId = result.conversationId;
      }
      
      this.messages.push({ 
        id: util.generateRandomUUID(true), 
        text: result.answer, 
        isMe: false 
      });
      
    } catch (e) {
      this.messages.push({ 
        id: util.generateRandomUUID(true), 
        text: '网络连接或数据解析失败，请检查网络设置或后端服务状态', 
        isMe: false 
      });
    } finally {
      this.isAnalyzing = false;
      this.scrollToBottom();
    }
  }
}