import { Home } from './Home'
import { SkillTree } from './SkillTree'
import { AIChat } from './AIChat'
import { Profile } from './Profile'
import { SkillItem } from '../model/Skill'
import { ChatMessage } from '../model/Message'

@Entry
@Component
struct Index {
  @Provide @Watch('onIndexChanged') currentIndex: number = 0;
  @Provide skills: SkillItem[] = [];
  @Provide messages: ChatMessage[] = [];
  @Provide conversationId: string = '';

  @State private lastSyncedIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  private onIndexChanged(): void {
    if (this.currentIndex === this.lastSyncedIndex) {
      return;
    }
    this.lastSyncedIndex = this.currentIndex;
    this.tabsController.changeIndex(this.currentIndex);
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() { Home() }
        TabContent() { SkillTree() }
        TabContent() { AIChat() }
        TabContent() { Profile() }
      }
      .scrollable(false)
      .barHeight(0) // 隐藏系统原生 TabBar，使用自定义还原高保真设计
      .layoutWeight(1)
      .onChange((index: number) => {
        this.lastSyncedIndex = index;
        this.currentIndex = index;
      })

      // Custom Bottom Navigation
      Row() {
        this.TabItem('首页', 0, '🏠')
        this.TabItem('技能树', 1, '🌳')
        this.TabItem('AI对话', 2, '🤖')
        this.TabItem('我的', 3, '👤')
      }
      .width('100%').height(56).backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#e3e2e2' })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: -2 })
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%').height('100%')
  }

  @Builder
  TabItem(title: string, index: number, icon: string) {
    Column() {
      Text(icon).fontSize(20).margin({ bottom: 2 })
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#005ea1' : '#909399')
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('22%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentIndex === index ? 'rgba(0,94,161,0.1)' : Color.Transparent)
    .borderRadius(12)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }
}
