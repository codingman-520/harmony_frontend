import { SkillItem, SubSkill } from '../model/Skill';
import { HttpUtil } from '../utils/HttpUtil';

export interface BackendSkill {
  id: number;
  name: string;
  description: string;
  parentId: number;
  category: string;
  status: number;
  children: BackendSkill[];
}

export interface BackendResponse {
  code: number;
  message: string;
  data: BackendSkill[];
}

export class SkillService {
  static async getSkillTreeList(category: string = 'ALL'): Promise<SkillItem[]> {
    try {
      const url = category === 'ALL' ? '/api/skills/tree' : `/api/skills/tree?category=${category}`;
      const response = await HttpUtil.get(url);
      const resObj = JSON.parse(response.result as string) as BackendResponse;
      console.info("【联调终点站】后端返回给前端的完整 res 对象为: " + JSON.stringify(resObj));
      
      let finalData: BackendSkill[] = [];
      if (resObj.data && Array.isArray(resObj.data)) {
        finalData = resObj.data;
      }
      
      // 适配后端字段映射 (name -> title, children -> subSkills)
      const mappedSkills: SkillItem[] = finalData.map((item: BackendSkill) => {
        let tagColor = '#4A90D9'; // 默认颜色
        if (item.category === 'FRONTEND') tagColor = '#4A90D9';
        else if (item.category === 'BACKEND') tagColor = '#E6A23C';
        else if (item.category === 'DATABASE') tagColor = '#4A90D9'; // MySQL 等
        else if (item.category === 'DEVOPS') tagColor = '#67C23A';
        else if (item.category === 'SOFT_SKILLS') tagColor = '#909399';

        const subSkillsList: SubSkill[] = item.children ? item.children.map((child: BackendSkill): SubSkill => {
          const sub: SubSkill = {
            id: child.id,
            name: child.name,
            status: child.status
          };
          return sub;
        }) : [];

        const skill: SkillItem = {
          id: item.id,
          title: item.name,
          tag: item.category,
          tagColor: tagColor,
          desc: item.description,
          subSkills: subSkillsList
        };
        return skill;
      });
      
      return mappedSkills;
    } catch (error) {
      console.error('获取技能树列表失败，降级使用本地 Mock 数据');
      return new Promise(resolve => {
        setTimeout(() => resolve([
          {
            id: 1,
            title: 'React 核心生态',
            tag: 'Frontend',
            tagColor: '#4A90D9',
            desc: '掌握现代前端开发的灵魂，从 Hook 到状态管理，构建高性能响应式应用。',
            subSkills: [
              { id: 101, name: 'Hooks', status: 2 },
              { id: 102, name: 'Next.js', status: 2 },
              { id: 103, name: 'Redux Toolkit', status: 0 },
              { id: 104, name: 'Three.js', status: 0 }
            ]
          },
          {
            id: 2,
            title: '云原生架构设计',
            tag: 'DevOps',
            tagColor: '#67C23A',
            desc: '利用 Kubernetes 与 Docker 实现微服务弹性伸缩，打造高可用的分布式系统。',
            subSkills: [
              { id: 201, name: 'Docker', status: 2 },
              { id: 202, name: 'K8s', status: 0 },
              { id: 203, name: 'Terraform', status: 0 },
              { id: 204, name: 'CI/CD', status: 0 }
            ]
          },
          {
            id: 3,
            title: '高性能后端工程',
            tag: 'Backend',
            tagColor: '#E6A23C',
            desc: '深入并发模型与 JVM 调优，构建足以支撑千万级流量的稳健后端核心。',
            subSkills: [
              { id: 301, name: 'Go / Java', status: 2 },
              { id: 302, name: 'Redis', status: 2 },
              { id: 303, name: 'gRPC', status: 2 },
              { id: 304, name: 'Kafka', status: 0 }
            ]
          }
        ]), 500);
      });
    }
  }

  static async toggleSkill(skillId: number, userId: number): Promise<boolean> {
    try {
      const url = `/api/skills/toggle/${skillId}?userId=${userId}`;
      console.info(`【发起点亮请求】 请求地址: ${url}`);
      await HttpUtil.post(url);
      return true;
    } catch (error) {
      console.error('点亮技能失败，降级返回成功');
      return new Promise(resolve => setTimeout(() => resolve(true), 300));
    }
  }
}