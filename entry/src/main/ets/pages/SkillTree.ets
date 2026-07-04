import { LengthMetrics } from '@ohos.arkui.node';
import { SkillItem, SubSkill } from '../model/Skill';
import { SkillService } from '../service/SkillService';

@Component
export struct SkillTree {
  @State categories: string[] = ['ALL'];
  @State categoryMap: Record<string, string> = { 'ALL': 'ALL' };
  @State currentCategory: string = 'ALL';

  @Consume skills: SkillItem[];
  @Consume @Watch('onTabChange') currentIndex: number;
  @State isLoading: boolean = false;
  @State forceUpdateTrigger: boolean = false;

  async aboutToAppear() {
    await this.loadCategories();
    if (this.currentIndex === 1 && (!this.skills || this.skills.length === 0)) {
      this.loadData();
    }
  }

  async onTabChange() {
    if (this.currentIndex === 1) {
      if (this.categories.length <= 1) {
        await this.loadCategories();
      }
      if (!this.skills || this.skills.length === 0) {
        this.loadData();
      }
    }
  }

  private async loadCategories() {
    try {
      const cats = await SkillService.getCategories();
      if (cats && cats.length > 0) {
        const catNames: string[] = [];
        const catMap: Record<string, string> = {};
        for (let i = 0; i < cats.length; i++) {
          const item = cats[i];
          catNames.push(item.name);
          catMap[item.name] = item.code;
        }
        this.categories = catNames;
        this.categoryMap = catMap;
      }
    } catch (e) {
      console.error("加载动态分类数据失败: " + JSON.stringify(e));
    }
  }

  public async loadData(category: string = 'ALL') {
    this.isLoading = true;
    try {
      const param = this.categoryMap[category] || 'ALL';
      const data = await SkillService.getSkillTreeList(param);
      // 🔥 注入真理日志：直接打印拿到的第一个大分类里的第一个子技能状态
      if (data && data.length > 0 && data[0].subSkills && data[0].subSkills.length > 0) {
        console.info("=== [数据对齐检查] 刚刚拉取到的第一个子技能状态是: " + data[0].subSkills[0].status);
      }
      
      if (Array.isArray(data)) {
        // 🔥 第一步：极其残忍地直接清空数据源，逼迫组件树彻底销毁现有的 List 节点
        this.skills = [];
        
        // 🔥 第二步：利用定时器在下一个宏任务周期（10毫秒后）把真数据塞进去，强行逼迫 UI 重生
        setTimeout(() => {
          this.getUIContext().animateTo({ duration: 150 }, () => {
            this.skills = data;
            this.isLoading = false;
          });
        }, 10);
      } else {
        this.skills = [];
        this.isLoading = false;
      }
    } catch (e) {
      console.error("【网络请求彻底失败】 错误详情: " + JSON.stringify(e));
      this.skills = [];
      this.isLoading = false;
    } finally {
      this.forceUpdateTrigger = !this.forceUpdateTrigger;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('技能树').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#005ea1')
      }.width('100%').height(48).justifyContent(FlexAlign.Center).backgroundColor(Color.White).shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      // Categories
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.categories, (cat: string, index: number) => {
            Text(cat)
              .fontSize(12)
              .fontColor(this.currentCategory === cat ? Color.White : '#414751')
              .backgroundColor(this.currentCategory === cat ? '#007DFF' : '#e9e8e8')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                if (this.currentCategory === cat) return;
                
                this.getUIContext().animateTo({ duration: 200 }, () => {
                  this.currentCategory = cat;
                });
                
                // 触发带参的网络请求，刷新列表
                this.loadData(cat);
              })
          }, (cat: string, index: number) => cat + index.toString())
        }.padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%')

      // List
      if (this.skills && this.skills.length > 0) {
        List({ space: 12 }) {
          ForEach(this.skills, (skill: SkillItem, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(skill.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
                  Blank()
                  Text(skill.tag)
                    .fontSize(10).fontWeight(FontWeight.Bold).fontColor(skill.tagColor)
                    .backgroundColor(`${skill.tagColor}1A`) 
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4)
                }.width('100%')
                Text(skill.desc).fontSize(12).fontColor('#909399').margin({ top: 8, bottom: 16 })
                
                if (skill.subSkills && skill.subSkills.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                    ForEach(skill.subSkills, (sub: SubSkill, subIndex: number) => {
                      Button({ type: ButtonType.Normal }) {
                        Row() {
                          if (sub.status === 2) {
                            Text('✓ ').fontSize(12).fontColor('#28A745').fontWeight(FontWeight.Bold)
                          } else if (sub.status === 1) {
                            Text('▶ ').fontSize(12).fontColor('#007DFF').fontWeight(FontWeight.Bold)
                          }
                          Text(sub.status === 2 ? `${sub.name} (已掌握)` : (sub.status === 1 ? `${sub.name} (学习中)` : sub.name))
                            .fontSize(12)
                            .fontColor(sub.status === 2 ? '#28A745' : (sub.status === 1 ? '#007DFF' : '#909399'))
                        }
                      }
                      .backgroundColor(sub.status === 2 ? '#E8F5E9' : (sub.status === 1 ? '#E6F0FF' : '#f4f3f3'))
                      .border({ 
                        width: 1, 
                        color: sub.status === 2 ? '#28A745' : (sub.status === 1 ? '#007DFF' : 'transparent') 
                      })
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .borderRadius(8)
                      .onClick(async () => {
                        console.info("【底层暴击】成功戳中子技能 Button，所属子技能ID 为: " + sub.id);
                        try {
                          const success = await SkillService.toggleSkill(sub.id);
                          if (success) {
                            await this.loadData(this.currentCategory);
                          }
                        } catch (e) {
                          console.error("【点亮技能失败】 错误详情: " + JSON.stringify(e));
                        }
                      })
                    }, (sub: SubSkill, subIndex: number) => sub.name + subIndex.toString() + sub.status.toString())
                  }
                  .width('100%')
                } else {
                  Text('当前模块暂无细分子技能')
                    .fontSize(12)
                    .fontColor('#909399')
                    .margin({ top: 4 })
                }
              }
              .hitTestBehavior(HitTestMode.Transparent)
              .padding(16).backgroundColor(Color.White).borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            }
            .hitTestBehavior(HitTestMode.Transparent)
          }, (skill: SkillItem, index: number) => skill.id ? skill.id.toString() + index.toString() : index.toString())
        }.padding({ left: 16, right: 16, bottom: 16 }).layoutWeight(1).scrollBar(BarState.Off)
      } else {
        Column() {
          Text(this.isLoading ? "正在努力加载技能树..." : "暂无技能数据")
            .fontSize(14)
            .fontColor('#909399')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      // 🎮 绝对隔离的实验按钮
      // 实验按钮已被移除，正式环境不需要
    }
    .width('100%').height('100%')
    .backgroundColor('#faf9f9')
    .opacity(this.forceUpdateTrigger ? 0.999 : 1)
  }
}
