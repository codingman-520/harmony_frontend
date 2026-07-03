import { User } from '../model/User';
import { UserService } from '../service/UserService';
import router from '@ohos.router';

@Component
export struct Profile {
  @State userProfile: User | null = null;
  @State isLoading: boolean = false;

  async aboutToAppear() {
    this.isLoading = true;
    try {
      this.userProfile = await UserService.getUserProfile();
    } catch (e) {
      console.error("加载个人中心数据失败: ", JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('AI伴学平台').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#005ea1')
      }.width('100%').height(48).justifyContent(FlexAlign.Center).backgroundColor(Color.White).shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      Scroll() {
        Column({ space: 16 }) {
          // Profile Card
          Row({ space: 16 }) {
            Image('https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=portrait%20of%20student%20friendly&image_size=square')
              .width(64).height(64).borderRadius(32).border({ width: 2, color: 'rgba(255,255,255,0.8)' })
            Column() {
              Row({ space: 8 }) {
                Text(this.userProfile?.nickname || '加载中...').fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White)
                Text(this.userProfile?.role === 'ADMIN' ? '管理员' : '学生').fontSize(10).fontColor(Color.White).border({ width: 1, color: Color.White }).padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(12)
              }
              Text(this.userProfile?.email || '').fontSize(12).fontColor('#d2e4ff').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start)
          }
          .width('100%').padding(24).borderRadius(12)
          .linearGradient({ direction: GradientDirection.RightBottom, colors: [['#005ea1', 0.0], ['#4A90D9', 1.0]] })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 2 })

          // Stats
          Row({ space: 12 }) {
            this.StatBox('累计学习', '128', '小时', '#005ea1')
            this.StatBox('掌握技能', '12', '项', '#67C23A')
          }.width('100%')

          // Menu List
          Column() {
            this.MenuItem('📚', '学习记录')
            Divider().color('#e3e2e2').margin({ left: 16, right: 16 })
            this.MenuItem('⚙️', '设置')
            Divider().color('#e3e2e2').margin({ left: 16, right: 16 })
            this.MenuItem('ℹ️', '关于')
          }.backgroundColor(Color.White).borderRadius(12).border({ width: 1, color: '#e3e2e2' })

          // Logout
          Button('退出登录')
            .width('100%').height(48).backgroundColor('transparent').fontColor('#F56C6C').border({ width: 1, color: '#F56C6C' }).borderRadius(24)
            .margin({ top: 16 })
            .onClick(() => {
              console.info("用户点击了退出登录");
              router.replaceUrl({ url: 'pages/Login' });
            })
            
          Text('Version 2.4.0 (Enterprise Build)').fontSize(10).fontColor('#909399').margin({ top: 16 })
        }.padding(16).width('100%')
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#faf9f9')
  }

  @Builder
  StatBox(title: string, val: string, unit: string, valColor: string) {
    Column() {
      Text(title).fontSize(12).fontColor('#626567')
      Row({ space: 4 }) {
        Text(val).fontSize(24).fontWeight(FontWeight.Bold).fontColor(valColor)
        Text(unit).fontSize(10).fontColor('#626567')
      }.alignItems(VerticalAlign.Bottom).margin({ top: 4 })
    }.layoutWeight(1).padding(16).backgroundColor(Color.White).borderRadius(12).border({ width: 1, color: '#e3e2e2' })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  MenuItem(icon: string, title: string) {
    Row() {
      Text(icon).fontSize(16).margin({ right: 12 })
      Text(title).fontSize(16).fontColor('#1a1c1c')
      Blank()
      Text('>').fontSize(16).fontColor('#c1c7d2')
    }.width('100%').padding(16)
    .onClick(() => {
      console.info(`点击了菜单: ${title}`);
    })
  }
}
