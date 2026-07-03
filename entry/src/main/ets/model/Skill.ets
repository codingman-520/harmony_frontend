export interface SubSkill {
  id: number;
  name: string;
  status: number; // 0: 未开始, 1: 学习中, 2: 已掌握
}

export interface SkillItem {
  id: number;
  title: string;
  tag: string;
  tagColor: string;
  desc: string;
  subSkills: SubSkill[];
}