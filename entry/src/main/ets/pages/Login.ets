import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { AuthLoginData, AuthService } from '../service/AuthService';
import { PreferencesUtil } from '../utils/PreferencesUtil';

@Entry
@Component
struct Login {
  @State username: string = 'admin';
  @State password: string = '123456';
  @State isLoading: boolean = false;

  build() {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Circle({ width: 88, height: 88 }).fill('#4A90D9')
          Text('AI').fontSize(28).fontWeight(FontWeight.Bold).fontColor(Color.White)
        }
        .width('100%')
        .margin({ top: 56, bottom: 16 })

        Text('AI伴学与职业成长平台')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1c1c')
          .textAlign(TextAlign.Center)
          .width('100%')

        Column({ space: 12 }) {
          Row({ space: 10 }) {
            Text('👤').fontSize(16).fontColor('#717782')
            TextInput({ text: this.username, placeholder: '请输入用户名' })
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .fontSize(14)
              .onChange((val: string) => { this.username = val; })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#e3e2e2' })

          Row({ space: 10 }) {
            Text('🔒').fontSize(16).fontColor('#717782')
            TextInput({ text: this.password, placeholder: '请输入密码' })
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .fontSize(14)
              .type(InputType.Password)
              .onChange((val: string) => { this.password = val; })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#e3e2e2' })

          Button(this.isLoading ? '登录中...' : '登录')
            .width('100%')
            .height(48)
            .backgroundColor('#4A90D9')
            .fontColor(Color.White)
            .fontSize(16)
            .borderRadius(24)
            .enabled(!this.isLoading && this.username.trim().length > 0 && this.password.trim().length > 0)
            .onClick(() => { this.doLogin(); })
        }
        .margin({ top: 28 })
        .padding({ left: 16, right: 16 })

        Text('还没有账号？去注册')
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)

      Text('提示：账号 admin / student，密码 123456')
        .fontSize(12)
        .fontColor('#c1c7d2')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private async doLogin(): Promise<void> {
    if (this.isLoading) return;
    this.isLoading = true;
    try {
      const data: AuthLoginData = await AuthService.login(this.username.trim(), this.password.trim());
      AppStorage.setOrCreate('token', data.token);
      AppStorage.setOrCreate('userId', data.userId);
      await PreferencesUtil.put('token', data.token);
      await PreferencesUtil.put('userId', data.userId.toString());
      promptAction.showToast({ message: '登录成功' });
      router.replaceUrl({ url: 'pages/Index' });
    } catch (e) {
      promptAction.showToast({ message: '登录失败：' + (e.message || JSON.stringify(e)) });
    } finally {
      this.isLoading = false;
    }
  }
}
