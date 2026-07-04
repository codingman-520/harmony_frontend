import { User } from '../model/User';
import { UserService, UserStats } from '../service/UserService';
import router from '@ohos.router';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import promptAction from '@ohos.promptAction';

@Component
export struct Profile {
  @State userProfile: User = {
    id: '',
    username: '',
    nickname: '正在获取...',
    email: '',
    role: 'STUDENT',
    token: ''
  };
  @State isLoading: boolean = false;
  @State totalDuration: number = 0;
  @State masteredSkills: number = 0;

  // 确保外层父组件有 @Provide currentIndex: number
  @Consume @Watch('onTabChange') currentIndex: number;

  // 1. 组件初始化时触发加载
  async aboutToAppear() {
    console.info("Profile组件：aboutToAppear 触发");
    await this.loadData();
  }

  // 2. 兜底机制：当被作为自定义组件放在页面中，或者所在的页面每次显示时触发
  async onPageShow() {
    console.info("Profile组件：页面可见，强制刷新数据");
    await this.loadData();
  }

  // 3. 监听外层 Tabs 的切换行为
  async onTabChange() {
    console.info(`Profile组件：监听到 Tab 切换，当前索引 = ${this.currentIndex}`);
    if (this.currentIndex === 3) { // 假设个人中心是第 4 个 Tab (索引从 0 开始计算)
      await this.loadData();
    }
  }

  // 核心数据拉取方法
  async loadData() {
    // 避免重复加载
    if (this.isLoading) return;
    this.isLoading = true;
    try {
      console.info("Profile组件：开始请求后端接口...");

      // 1. 先用一个普通变量接收并发请求返回的数组
      const results = await Promise.all([
        UserService.getUserProfile(),
        UserService.getUserStats()
      ]);

      // 2. 通过索引下标安全取值，规避 ArkTS 的解构限制
      let profileRes = results[0];
      let statsRes = results[1];

      if (profileRes) {
        if (!profileRes.nickname || profileRes.nickname === 'null' || profileRes.nickname === 'undefined') {
          profileRes.nickname = profileRes.username;
        }
        this.userProfile = profileRes;
        console.info(`Profile组件：成功获取用户名 -> ${this.userProfile.nickname}`);
      }

      if (statsRes) {
        this.totalDuration = Number(statsRes.totalDuration || 0);
        this.masteredSkills = Number(statsRes.masteredSkills || 0);
        console.info(`Profile组件：成功获取统计 -> 时长:${this.totalDuration}, 技能:${this.masteredSkills}`);
      }
    } catch (e) {
      console.error("Profile组件：加载个人中心数据失败! 错误原因: ", JSON.stringify(e));
      // 如果后端接口报错，给用户一个友好提示
      this.userProfile.nickname = '未登录/网络异常';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶栏 Header
      Row() {
        Text('AI伴学平台').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#005ea1')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      // 滚动主体
      Scroll() {
        Column({ space: 16 }) {

          // 1. 个人卡片 (Profile Card)
          Row({ space: 16 }) {
            Image('https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=portrait%20of%20student%20friendly&image_size=square')
              .width(64)
              .height(64)
              .borderRadius(32)
              .border({ width: 2, color: 'rgba(255,255,255,0.8)' })

            Column() {
              Row({ space: 8 }) {
                Text(this.userProfile.nickname)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(this.userProfile.role === 'ADMIN' ? '管理员' : '学生')
                  .fontSize(10)
                  .fontColor(Color.White)
                  .border({ width: 1, color: Color.White })
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(12)
              }
              Text(this.userProfile.email || '未绑定邮箱').fontSize(12).fontColor('#d2e4ff').margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1) // 让其填满，保证右边点击事件不被阻断
          }
          .width('100%')
          .padding(24)
          .borderRadius(12)
          .linearGradient({ direction: GradientDirection.RightBottom, colors: [['#005ea1', 0.0], ['#4A90D9', 1.0]] })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 2 })

          // 2. 统计卡片 (Stats)
          Row({ space: 12 }) {
            this.StatBox('累计学习', this.totalDuration, '小时', '#005ea1', true)
            this.StatBox('掌握技能', this.masteredSkills, '项', '#67C23A', false)
          }
          .width('100%')

          // 3. 菜单列表 (Menu List) - 修复布局边界
          Column() {
            this.MenuItem('📚', '学习记录', 'record')
            Divider().color('#f0eded').margin({ left: 16, right: 16 })
            this.MenuItem('⚙️', '设置', 'settings')
            Divider().color('#f0eded').margin({ left: 16, right: 16 })
            this.MenuItem('ℹ️', '关于伴学平台', 'about')
          }
          .width('100%') // 必须加 100% 宽度
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#e3e2e2' })

          // 4. 退出登录 (Logout)
          Button('退出登录')
            .width('100%')
            .height(48)
            .backgroundColor('transparent')
            .fontColor('#F56C6C')
            .border({ width: 1, color: '#F56C6C' })
            .borderRadius(24)
            .margin({ top: 16 })
            .onClick(async () => {
              console.info("用户点击了退出登录");
              AppStorage.setOrCreate('token', '');
              AppStorage.setOrCreate('userId', 0);
              await PreferencesUtil.delete('token');
              await PreferencesUtil.delete('userId');
              router.replaceUrl({ url: 'pages/Login' });
            })

          Text('Version 2.4.0 (Enterprise Build)').fontSize(10).fontColor('#909399').margin({ top: 16 })
        }
        .padding(16)
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#faf9f9')
  }

  // 统计块 Builder
  @Builder
  StatBox(title: string, rawVal: number, unit: string, valColor: string, isTime: boolean) {
    Column() {
      Text(title).fontSize(12).fontColor('#626567')
      Row({ space: 4 }) {
        // 在内部动态渲染，规避传递死字面量的问题
        Text(isTime ? (rawVal / 60).toFixed(1) : rawVal.toFixed(0))
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(valColor)
        Text(unit).fontSize(10).fontColor('#626567')
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 1, color: '#e3e2e2' })
    .alignItems(HorizontalAlign.Start)
    // 增加点击同步刷新效果（作为彩蛋）
    .onClick(async () => {
      await this.loadData();
    })
  }

  // 菜单块 Builder
  @Builder
  MenuItem(icon: string, title: string, action: string) {
    Row() {
      Text(icon).fontSize(16).margin({ right: 12 })
      Text(title).fontSize(16).fontColor('#1a1c1c')
      Blank()
      Text('>').fontSize(16).fontColor('#c1c7d2')
    }
    .width('100%') // 必须设为满宽
    .height(56)   // 限制高度
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White) // 方便捕获全屏点击手势
    .onClick(() => {
      console.info(`点击了菜单: ${title}`);
      promptAction.showToast({ message: `点击了 [${title}]，功能开发中...` });
      if (action === 'record') {
        // 后续联调路由跳转逻辑
        // router.pushUrl({ url: 'pages/Record' })
      }
    })
  }
}