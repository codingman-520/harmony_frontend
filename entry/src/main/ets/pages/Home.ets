import { User } from '../model/User';
import { UserService } from '../service/UserService';

@Component
export struct Home {
  @State userProfile: User | null = null;
  @State isLoading: boolean = false;

  async aboutToAppear() {
    this.isLoading = true;
    try {
      this.userProfile = await UserService.getUserProfile();
    } catch (e) {
      console.error("加载首页用户数据失败: ", JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        // Header & Stats
        Stack({ alignContent: Alignment.Top }) {
          // Gradient Background
          Column() {
            Row() {
              Row({ space: 12 }) {
                Image('https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=professional%20avatar%203D%20smile&image_size=square')
                  .width(48).height(48).borderRadius(24).border({ width: 2, color: 'rgba(255,255,255,0.3)' })
                Column() {
                  Text(`Hi, ${this.userProfile?.nickname || '开发者'}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
                  Text('今天也要加油呀！').fontSize(12).fontColor('rgba(255,255,255,0.8)').margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start)
              }
              Blank()
              // Notification icon placeholder
              Text('🔔').fontSize(20)
            }.width('100%').padding({ left: 16, right: 16, top: 40 })
          }
          .width('100%').height(200)
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#4A90D9', 0.0], ['#6DB3F8', 1.0]]
          })

          // Stats Card
          Row() {
            this.StatItem('12', '掌握技能')
            Divider().vertical(true).height(32).color('#c1c7d2')
            this.StatItem('85%', '学习进度')
            Divider().vertical(true).height(32).color('#c1c7d2')
            this.StatItem('24', '连续打卡')
          }
          .width('90%').height(80)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 160 })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
          .justifyContent(FlexAlign.SpaceEvenly)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%').height(250)

        // Quick Entry Grid
        Grid() {
          GridItem() { this.QuickEntryItem('🌳', '技能树', '可视化成长路径', '#005ea1', '#e0e3e6') }
          GridItem() { this.QuickEntryItem('🤖', 'AI对话', '全天候智能导师', '#005f9c', '#d0e4ff') }
          GridItem() { this.QuickEntryItem('🎯', '模拟面试', '实战演练涨经验', '#E6A23C', '#fdf6ec') }
          GridItem() { this.QuickEntryItem('👤', '个人中心', '管理学习档案', '#67C23A', '#f0f9eb') }
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12).columnsGap(12)
        .padding(16)
        .height(180)

        // Hot Skills
        Row() {
          Text('🔥 热门技能').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1a1c1c')
          Blank()
          Text('查看全部').fontSize(12).fontColor('#005ea1')
        }.width('100%').padding({ left: 16, right: 16, top: 8 })

        Scroll() {
          Row({ space: 8 }) {
            this.HotSkillTag('Frontend React', true)
            this.HotSkillTag('Python AI', false)
            this.HotSkillTag('Data Analysis', false)
            this.HotSkillTag('UI Design', false)
          }.padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%')

        // Featured Course
        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Image('https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=futuristic%20computer%20terminal%20neural%20network%20code%20snippets&image_size=landscape_16_9')
              .width('100%').height(160).objectFit(ImageFit.Cover)
            Text('NEW').fontSize(10).fontColor(Color.White).backgroundColor('#005ea1')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(4).margin(12).fontWeight(FontWeight.Bold)
          }.width('100%')
          Column() {
            Row() {
              Text('大语言模型提示词工程').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1a1c1c')
              Blank()
              Text('免费').fontSize(12).fontColor('#67C23A')
            }.width('100%')
            Text('深入浅出地学习如何优化 AI 的输出结果，提升工作效率 200%。')
              .fontSize(12).fontColor('#414751').margin({ top: 8 }).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            Row() {
              Text('1,248 人正在学习').fontSize(10).fontColor('#717782')
            }.width('100%').margin({ top: 16 })
          }.padding(16)
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 4, bottom: 16 })
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
        .clip(true)

        // Daily Challenge
        Row() {
          Row({ space: 12 }) {
            Circle({ width: 40, height: 40 }).fill('rgba(255,255,255,0.2)')
            Column() {
              Text('每日挑战').fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color.White)
              Text('完成 3 道算法题，奖励 50 积分').fontSize(12).fontColor('rgba(255,255,255,0.8)').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start)
          }
          Blank()
          Button('去挑战').fontSize(12).fontColor('#2b78bf').backgroundColor(Color.White).height(32)
        }
        .width('90%').padding(16).backgroundColor('#2b78bf').borderRadius(12).margin({ bottom: 32 })

      }
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor('#faf9f9')
    .scrollBar(BarState.Off)
  }

  @Builder
  StatItem(val: string, label: string) {
    Column() {
      Text(val).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#005ea1')
      Text(label).fontSize(10).fontColor('#414751').margin({ top: 4 })
    }
  }

  @Builder
  QuickEntryItem(icon: string, title: string, subtitle: string, color: string, bgColor: string) {
    Column() {
      Row() {
        Text(icon).fontSize(20).width(40).height(40).textAlign(TextAlign.Center).backgroundColor(bgColor).borderRadius(8)
      }.width('100%').margin({ bottom: 12 })
      Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#005ea1').width('100%')
      Text(subtitle).fontSize(10).fontColor('#414751').width('100%').margin({ top: 4 })
    }
    .padding(16).backgroundColor(Color.White).borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .width('100%').height('100%')
  }

  @Builder
  HotSkillTag(name: string, isActive: boolean) {
    Text(name)
      .fontSize(12)
      .fontColor(isActive ? '#005ea1' : '#414751')
      .backgroundColor(isActive ? 'rgba(0,94,161,0.1)' : '#e0e3e6')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .borderRadius(16)
      .border({ width: 1, color: isActive ? 'rgba(0,94,161,0.2)' : '#c1c7d2' })
  }
}