# AI伴学系统 — App端静态开发指南

本指南旨在引导开发者在 HarmonyOS NEXT 运行环境下，利用 AI 辅助编程工具（如 Trae、Qoder 等）高效完成 App 端（ArkTS / ArkUI）的静态页面构建、架构分层以及未来与后端的接口联调预备工作。



## 一、项目基础模板创建

**为什么需要手动初始化**

在开发任何 HarmonyOS NEXT 应用前，必须使用官方 IDE（DevEco Studio）进行项目的初始化。这能确保系统配置文件（如 module.json5）、SDK 版本以及编译工具链完全正确。AI 编辑器目前最擅长的是编写和重构代码，而环境搭建和底层配置仍需开发者手动完成。

### 1. 技术栈与运行环境

- **开发工具**：DevEco Studio (建议最新稳定版)
- **SDK 版本**：HarmonyOS NEXT Beta (API 12)
- **编程模型**：Stage Model
- **开发语言**：ArkTS (基于 TypeScript 扩展)

### 2. 初始化步骤

1. 打开 **DevEco Studio**，选择 **Create Project**。
2. 选择 **Empty Ability** 模板，点击 Next。
3. 配置项目基本信息：
   - **Project name**：AiStudyApp
   - **Bundle name**：com.example.aistudyapp
   - **Save location**：选择本地空目录
   - **Compile SDK**：API 12
4. 点击 **Finish** 按钮，等待 Gradle 与 Open Harmony Package Manager (ohpm) 依赖下载及构建完成。

------



## 二、基于 AI 助力的项目目录结构生成

为了降低后期前后端联调的耦合度，本项目采用关注点分离（Decoupling）的设计模式。整个前端工程划分为视图层（Pages）、复用组件层（Components）、数据模型层（Model）和业务服务层（Service）。

请在 AI 编辑器中打开刚才创建的项目，在 AI 聊天面板中直接输入以下指令：

```
请在当前 HarmonyOS NEXT (ArkTS) 项目的 `entry/src/main/ets` 目录下创建分层项目结构。你需要在对应路径下创建这些文件，文件内容先保持基本定义或空白导出，以便后续填充：

1. 数据模型层目录：entry/src/main/ets/model/
   - 创建 entry/src/main/ets/model/User.ets
   - 创建 entry/src/main/ets/model/Skill.ets
   - 创建 entry/src/main/ets/model/Message.ets
   - 创建 entry/src/main/ets/model/Interview.ets

2. 业务服务层目录：entry/src/main/ets/service/
   - 创建 entry/src/main/ets/service/AuthService.ets
   - 创建 entry/src/main/ets/service/SkillService.ets
   - 创建 entry/src/main/ets/service/ChatService.ets
   - 创建 entry/src/main/ets/service/InterviewService.ets

3. 页面层目录：entry/src/main/ets/pages/
   - 创建 entry/src/main/ets/pages/Login.ets
   - 创建 entry/src/main/ets/pages/Home.ets
   - 创建 entry/src/main/ets/pages/SkillTree.ets
   - 创建 entry/src/main/ets/pages/AiChat.ets
   - 创建 entry/src/main/ets/pages/Interview.ets
   - 创建 entry/src/main/ets/pages/Profile.ets

4. 公共组件层目录：entry/src/main/ets/components/
   - 创建 entry/src/main/ets/components/SkillTag.ets
   - 创建 entry/src/main/ets/components/EmptyView.ets

确认文件与目录结构创建无误后，返回创建成功的确认信息。
```

------



## 三、异步 Mock 服务与数据模型设计

### 1. 架构理念

在前后端并行开发的模式下，引入**异步 Mock 服务**有两大核心优势：

- **保障无感替换**：服务层（Service）的所有方法均返回 Promise 对象并包含延迟逻辑，模拟真实的 HTTP 请求耗时。当第四周进行联调时，仅需重写服务层内部的 HTTP 请求实现，而无需对页面层（UI）的调用逻辑、生命周期函数进行任何修改。
- **提前设计异常与加载状态**：异步返回迫使开发者在编写 UI 时，必须考虑数据尚未加载完成时的 “Loading” 状态及数据为空时的 “Empty” 状态。

### 2. 服务与模型生成提示词

请在 AI 编辑器中输入以下指令，生成底层数据模型与异步服务类：

```
我们需要为 AI 伴学平台编写底层数据模型和 Mock 业务服务。请实现以下 4 个模块的 ArkTS 定义，要求避免使用 any 类型，保持严格的强类型约束，并确保所有服务层方法均返回 Promise 以模拟真实的异步网络耗时（使用 setTimeout 模拟 500ms 延迟）：

1. 用户模块
   - model/User.ets：定义 User 接口，包含字段：id (string), username (string), nickname (string), email (string), role (STUDENT 或 ADMIN), token (string)。
   - service/AuthService.ets：
     - 实现 login(username: string, password: string): Promise<User>。当用户名为 admin 且密码为 123456 时，返回模拟用户信息与 token；否则抛出错误。

2. 技能树模块
   - model/Skill.ets：定义 Skill 接口，包含字段：id (string), name (string), category (FRONTEND, BACKEND, DATABASE, DEVOPS, SOFT_SKILLS), description (string), isUnlocked (boolean)。
   - service/SkillService.ets：
     - 实现 getSkillTreeList(): Promise<Skill[]>。返回包含至少 6 个不同分类的模拟技能树数组。
     - 实现 toggleSkill(skillId: string): Promise<boolean>。接收技能 ID，延迟 300ms 后返回操作成功状态（boolean）。

3. AI 智能对话模块
   - model/Message.ets：定义 Message 接口，包含字段：id (string), sender (USER 或 AI), content (string), timestamp (string)。
   - service/ChatService.ets：
     - 实现 getChatHistory(): Promise<Message[]>。返回 2 条初始的欢迎和引导对话。
     - 实现 sendMessage(content: string): Promise<Message>。将用户发送的内容作为入参，延迟 800ms 后返回一条模拟的 AI 回答消息，内容需具有逻辑性和辅导性。

4. 模拟面试模块
   - model/Interview.ets：
     - 定义 Question 接口，包含字段：id (string), questionText (string), standardAnswer (string)。
     - 定义 InterviewResult 接口，包含字段：score (number), timeSpent (string)。
   - service/InterviewService.ets：
     - 实现 getQuestions(skillId: string): Promise<Question[]>。根据技能 ID，返回 3 道针对性的专业面试题。
     - 实现 submitAnswers(answers: string[]): Promise<InterviewResult>。接收用户回答的文本数组，延迟 1000ms 后返回一个模拟的分数（如 85）以及用时（如 "03:15"）。

代码必须符合 HarmonyOS NEXT 语法规范，模型和服务的导入导出路径需要完全匹配项目结构。
```

------



## 四、页面级 ArkUI 组件静态开发

为了保证各页面的视觉风格一致，避免 AI 在生成不同页面时出现色彩、间距和组件尺寸的冲突，请依次复制以下结构化的开发提示词。

### 1. 登录页 (Login.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/Login.ets` 中生成登录页面的 ArkUI 代码：

项目环境说明：
- 屏幕基准：360vp × 800vp。
- 视觉主题色：科技蓝 #4A90D9。

页面组件结构：
- 整体采用 Column 垂直布局，背景色为 #F5F7FA。
- 顶部：应用标志（用一个居中的圆形占位图表示） + 标题 "AI伴学与职业成长平台"（24fp, FontWeight.Bold，外边距适中）。
- 表单区：
  - 用户名输入框：配有用户图标（或字符占位），圆角 12vp，外边距 12vp，提示词为 "请输入用户名"。
  - 密码输入框：输入框类型设为密码，支持内容遮蔽，提示词为 "请输入密码"。
- 提交区：
  - "登录" 按钮：全宽，背景色为 #4A90D9，高度 48vp，圆角 24vp，文本颜色为白色，字号 16fp。
- 底部：辅助文字 "还没有账号？去注册"，字号 14fp，颜色为 #999999，居中排列。

交互与接口预留逻辑：
- 引入 `../service/AuthService`。
- 定义 `@State isLoading: boolean = false` 用于加载控制，`@State username` 和 `password` 绑定输入框。
- 点击“登录”按钮时，触发 `AuthService.login` 异步调用。
- 请求进行中时，按钮状态设为不可点击，并显示 Loading 状态。
- 请求成功后，使用路由 `router.replaceUrl` 跳转至 `pages/Home`；请求失败则使用系统 promptAction.showToast 弹出错误信息。
```

------



### 2. 首页 (Home.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/Home.ets` 中生成首页 Dashboard 的 ArkUI 代码：

项目环境说明：
- 屏幕基准：360vp × 800vp，背景色 #F5F7FA。
- 底部预留高度为 56vp 的全局固定 Tab 导航栏。

页面组件结构：
- 顶部个人信息面板（高度 160vp，背景采用渐变色 #4A90D9 到 #6DB3F8）：
  - 采用水平 Row 布局，包含圆形用户头像（48vp，配有白色描边）与垂直排列的文字："Hi, 伴学伙伴"、"今天也要加油呀！"（白色，14fp，半透明度 0.8）。
  - 右侧配有消息铃铛图标占位。
- 快捷导航网格（采用 Grid 布局，4列等宽卡片）：
  - 包含：技能树、AI对话、模拟面试、个人中心。
  - 每个卡片包含：居中图标（32vp，蓝色系）、文字（12fp，颜色 #333333）。卡片背景为白色，圆角 12vp，带有微弱阴影（rgba(0,0,0,0.05)）。
- 热门技能推荐区：
  - 标题："🔥 热门技能推荐"（16fp 加粗，左边距 16vp）。
  - 水平滚动列表（Scroll + Row）：包含不少于 5 个圆角胶囊状技能标签（如 TypeScript、SpringBoot、MySQL 等）。标签背景为浅蓝 #E8F0FE，文本颜色为 #4A90D9，字号 12fp。
- 底部 Tab 导航栏：
  - 包含首页、技能树、AI对话、我的。首页当前处于高亮态（图标与文本呈 #4A90D9 蓝色），其余为灰色 #999999。

页面跳转交互：
- 快捷网格及底部 Tab 栏点击事件：
  - 点击“技能树” -> 跳转到 `pages/SkillTree`
  - 点击“AI对话” -> 跳转到 `pages/AiChat`
  - 点击“模拟面试” -> 跳转到 `pages/Interview`
  - 点击“个人中心”或“我的” -> 跳转到 `pages/Profile`
```

------



### 3. 技能树页 (SkillTree.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/SkillTree.ets` 中生成技能树页面的 ArkUI 代码：

项目环境说明：
- 页面背景：#F5F7FA。
- 分类标签主题色：FRONTEND（蓝色 #409EFF），BACKEND（绿色 #67C23A），DATABASE（黄色 #E6A23C），DEVOPS（红色 #F56C6C），SOFT_SKILLS（灰色 #909399）。

页面组件结构：
- 顶部导航：左侧返回箭头，居中标题 "技能树"（18fp 加粗）。
- 分类 TabBar（水平滚动）：
  - 选项包括：ALL、前端、后端、数据库、DevOps、软技能。
  - 选中项字体呈深蓝色 #4A90D9，且底部有 2vp 的蓝色指示线；未选中项呈灰色 #666666。
- 技能卡片列表（垂直滚动 List）：
  - 每个卡片背景为白色，圆角 12vp，四周内边距 16vp，卡片间距 12vp。
  - 第一行：技能名称（16fp 加粗） + 右对齐分类标签（小胶囊形状，根据分类展现对应背景色，白字）。
  - 第二行：技能描述（12fp 灰色 #999999，超出单行展示省略号）。
  - 第三行：子技能细分区域（横向 Flex 换行布局），每个子技能为一个 Tag 组件：
    - 已点亮状态：背景 #E8F0FE，文本 #4A90D9，带有一个小勾选框。
    - 未点亮状态：背景 #F5F7FA，文本 #999999。

交互与异步联调逻辑：
- 导入 `../model/Skill` 中的数据结构和 `../service/SkillService` 服务类。
- 定义状态变量 `@State skills: Skill[] = []` 以及 `@State currentCategory: string = 'ALL'`。
- 在页面生命周期 `aboutToAppear` 中，调用 `await SkillService.getSkillTreeList()` 异步获取数据并赋值给 `skills`。
- 当用户点击顶部分类 Tab 时，更新 `currentCategory` 并过滤显示的列表。
- 当用户点击卡片内的子技能标签时，触发 `await SkillService.toggleSkill(id)`，并在回调成功后将对应的 `isUnlocked` 状态取反，以此更新 UI 渲染。
```

------



### 4. AI 对话页 (AiChat.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/AiChat.ets` 中生成智能对话界面的 ArkUI 代码：

页面组件结构：
- 顶部状态栏：左侧返回箭头，中间标题 "AI伴学助手"（18fp 加粗），右侧一个文本动作按钮 "清空历史"（红色 #F56C6C）。
- 消息展示区（垂直滚动 List 容器，背景色为 #F5F7FA，占据屏幕主要高度）：
  - 用户气泡：布局右对齐，头像在右侧（圆形 36vp）。气泡背景色为 #4A90D9，文字颜色为白色，圆角 12vp（右上角为 4vp 小圆角以示气泡指向）。
  - AI 气泡：布局左对齐，头像在左侧（圆形 36vp 机器人占位图）。气泡背景色为白色，文字颜色为 #333333，圆角 12vp（左上角为 4vp 小圆角）。
  - 在列表最底部，当 AI 处于计算状态时，显示带有“AI 正在思考中...”字样的临时呼吸灯气泡。
- 底部交互栏（固定悬浮，高度 60vp，白色背景，顶部带有 1vp 描边）：
  - 包含一个圆角输入框（高度 40vp，占 80% 宽度，提示文本 "输入你要提问的学业或职业问题..."）和发送按钮（圆形，蓝色背景，白字发送图标）。

交互与异步联调逻辑：
- 引入 `../model/Message` 接口以及 `../service/ChatService` 服务类。
- 定义 `@State messageList: Message[] = []`，`@State inputText: string = ""` 以及 `@State isAnalyzing: boolean = false`。
- 页面 `aboutToAppear` 时，调用 `ChatService.getChatHistory()` 加载历史对话。
- 点击发送：
  1. 判断输入框是否为空，为空则置灰发送按钮，不可点击。
  2. 将内容插入 `messageList`，清空输入框。
  3. 将 `isAnalyzing` 设为 true，展示加载等待气泡。
  4. 异步调用 `await ChatService.sendMessage(text)`，获取返回消息后插入列表，并将 `isAnalyzing` 重置为 false。
- 点击 "清空历史"：弹出 Dialog 确认框，用户确认后重置 `messageList` 为空。
```

------



### 5. 模拟面试页 (Interview.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/Interview.ets` 中生成模拟面试界面的 ArkUI 代码：

页面组件结构与状态流转要求：
页面中需要定义一个状态控制变量 `@State currentStep: string = 'PREPARE'` （包含 PREPARE（准备）、INTERVIEWING（面试中）、REPORT（报告）三种状态），根据该变量在界面进行条件渲染。

- 【PREPARE 阶段 UI 布局】
  - 居中展示：大靶心图标（64vp） + 标题 "AI 伴学模拟面试"（20fp 加粗） + 副标题 "输入您需要诊断的技能ID以启动面试"（14fp，灰色）。
  - 表单项：单行输入框（圆角 12vp，提示文本 "请输入技能ID，如: Java"）。
  - 底部操作：全宽按钮 "开始诊断面试"（高度 48vp，背景色 #4A90D9，白字）。

- 【INTERVIEWING 阶段 UI 布局】
  - 顶部进度条：文本显示 "当前第 1/3 题"，并配有横向 Progress 进度指示器，计时器显示 "00:00"。
  - 题目显示卡片：白色背景，圆角 12vp，内边距 20vp，大字体显示具体题目。
  - 答题输入框：TextArea 组件，高度 150vp，提供多行文本输入，提示词为 "请阐述您的答案..."。
  - 操作区："提交当前回答" 按钮。

- 【REPORT 阶段 UI 布局】
  - 居中展示：彩带图标（64vp） + 标题 "本次面试测评完成！"。
  - 得分卡片：背景浅灰色，显示突出的大分数字体（85分，字号 48fp，蓝色 #4A90D9）。
  - 时间用时显示："用时：03:15"。
  - 底部双操作区：
    - 主按钮 "返回个人中心"（背景 #4A90D9）。
    - 辅助按钮 "再来一局"（空心边框按钮）。

交互与异步联调逻辑：
- 导入 `../service/InterviewService`。
- 准备阶段点击开始：调用 `await InterviewService.getQuestions(skillId)`，成功后将状态置为 `INTERVIEWING`，并初始化题目索引。
- 面试中阶段点击提交：如果是最后一题，则调用 `await InterviewService.submitAnswers(answers)`，并展示 Loading，加载完成后将状态置为 `REPORT` 渲染分数。
```

------



### 6. 个人中心页 (Profile.ets) 开发提示词

```
请根据以下设计要求与规范，在 `entry/src/main/ets/pages/Profile.ets` 中生成个人中心界面的 ArkUI 代码：

页面组件结构：
- 顶部卡片背景（背景采用 #4A90D9 到 #6DB3F8 渐变，高度 180vp，内边距 24vp）：
  - 头像组件：圆形设计，半径 64vp，白色包边。
  - 信息栏：垂直排列，显示用户昵称、注册邮箱，以及一个空心描边的 "学生" 或 "管理员" 角色胶囊标签。
- 菜单设置区（白色背景卡片，与顶部背景产生 20vp 向上堆叠效果，左右边距 16vp，圆角 12vp）：
  - 采用垂直 List 布局，每行高度 56vp，内部采用 Row 两端对齐：
    - 包含：左侧小图标（如 📚，⚙️，ℹ️） + 文本标题（"学习成长记录"、"通用设置"、"关于伴学平台"） + 右侧灰色返回标识 ">"。
    - 每行之间配有 1vp 的细分割线。
- 登出操作区：
  - "退出登录" 按钮：位于屏幕中下部，宽度采用百分比填充，背景色为透明，带有红色 #F56C6C 细描边，高度 48vp，圆角 24vp。

交互与异步联调逻辑：
- 个人信息直接绑定 `@State` 变量，在 `aboutToAppear` 生命周期中读取。
- 点击任意菜单项，打印路由跳转日志并保留空置方法。
- 点击“退出登录”按钮：
  1. 调用系统确认 Dialog 弹窗。
  2. 用户确认后，清空内存数据，并调用路由 `router.replaceUrl` 重置回 `pages/Login`。
```

------



## 五、业务层调用逻辑与联调演练

通过前述的数据流分层，UI 页面组件和数据加载动作解耦。以下通过“技能树页面渲染与点亮”场景，详细阐述其执行流程和代码写法，并演示后续联调时的切换步骤。

### 1. 静态开发阶段：UI 层调用异步 Service 闭环代码

在完成的 SkillTree.ets 页面中，其完整的核心架构代码如下：

```
import { Skill } from '../model/Skill';
import { SkillService } from '../service/SkillService';

@Entry
@Component
struct SkillTree {
  @State skills: Skill[] = [];      // 驱动界面的状态变量
  @State isLoading: boolean = false; // 控制加载遮罩

  // 页面生命周期：组件渲染前自动触发
  async aboutToAppear() {
    this.isLoading = true;
    try {
      // 页面完全不知道数据来自 Mock 还是真实后端，只关注接口契约
      this.skills = await SkillService.getSkillTreeList();
    } catch (e) {
      console.error("加载技能树失败: ", JSON.stringify(e));
    } finally {
      this.isLoading = false; // 关闭加载等待
    }
  }

  build() {
    Stack() {
      Column() {
        Text("核心职业技能树")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin(16)

        List({ space: 12 }) {
          ForEach(this.skills, (item: Skill) => {
            ListItem() {
              Row() {
                Column({ alignItems: HorizontalAlign.Start }) {
                  Text(item.name).fontSize(16).fontWeight(FontWeight.Bold)
                  Text(item.description).fontSize(12).fontColor('#999999').margin({ top: 4 })
                }
                Blank()
                
                // 切换点亮状态按钮
                Button() {
                  Text(item.isUnlocked ? "✓ 已掌握" : "点亮")
                    .fontSize(12)
                    .fontColor(item.isUnlocked ? Color.White : '#4A90D9')
                }
                .backgroundColor(item.isUnlocked ? '#4A90D9' : '#E8F0FE')
                .borderRadius(14)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .onClick(async () => {
                  this.isLoading = true;
                  // 异步调用服务接口
                  let success = await SkillService.toggleSkill(item.id);
                  if (success) {
                    // 本地状态变更，ArkTS 底层双向绑定将自动刷新页面 DOM
                    item.isUnlocked = !item.isUnlocked;
                    this.skills = [...this.skills];
                  }
                  this.isLoading = false;
                })
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(12)
              .padding(16)
            }
          }, (item: Skill) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')

      // 加载中过渡态
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(48).height(48).color('#4A90D9')
          Text("正在加载技能数据...").fontSize(14).fontColor('#999999').margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255, 255, 255, 0.7)')
        .justifyContent(FlexAlign.Center)
      }
    }
  }
}
```

------



### 2. 接口联调阶段：Service 层的零侵入无感替换逻辑

进入第四周联调阶段时，无需修改 SkillTree.ets 页面中的任何一行代码。项目开发者仅需重写服务层 service/SkillService.ets 的逻辑，将其内部调用替换为基于系统官方 @ohos.net.http 模块的网络请求：

```
import http from '@ohos.net.http';
import { Skill } from '../model/Skill';

export class SkillService {
  private static baseUrl = "http://10.0.2.2:8080/api/skills"; // 模拟器访问本机的默认映射 IP

  // 替换原有 setTimeout 静态数据，修改为网络请求
  static async getSkillTreeList(): Promise<Skill[]> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        this.baseUrl,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer ' + localToken (在此行加入 JWT 鉴权头)
          },
          readTimeout: 5000,
          connectTimeout: 5000
        }
      );
      
      if (response.responseCode === 200) {
        // 解析后端返回的实体数据
        return JSON.parse(response.result as string) as Skill[];
      } else {
        throw new Error("获取技能树列表异常，错误码：" + response.responseCode);
      }
    } catch (err) {
      console.error("网络请求失败：", JSON.stringify(err));
      throw err;
    } finally {
      httpRequest.destroy(); // 及时销毁请求，释放系统资源
    }
  }

  // 同样无缝改写操作接口为 PATCH/POST 请求
  static async toggleSkill(skillId: string): Promise<boolean> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${this.baseUrl}/${skillId}/toggle`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' }
        }
      );
      return response.responseCode === 200;
    } catch (err) {
      return false;
    } finally {
      httpRequest.destroy();
    }
  }
}
```

通过本设计模式与分步开发流程，项目团队可在早期快速且低门槛地构建流畅美观的前端人机交互（UX），并在后期进行系统集成时，以极其平滑的方式完成与 Spring Boot 3 以及 Dify AI 平台的业务逻辑对接，保障系统整体的工程质量与可维护性。