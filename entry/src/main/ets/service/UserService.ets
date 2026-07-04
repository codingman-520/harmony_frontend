import { User } from '../model/User';
import { HttpUtil } from '../utils/HttpUtil';

export interface UserStats {
  totalDuration: number;
  masteredSkills: number;
}

export class UserService {
  static async getUserProfile(): Promise<User> {
    try {
      const response = await HttpUtil.get('/api/user/profile');
      if (response.responseCode === 200 && response.result) {
        const resObj = JSON.parse(response.result as string) as Record<string, Object>;
        if (resObj.code === 200) {
          return resObj.data as User;
        }
      }
      throw new Error("Failed to load user profile");
    } catch (error) {
      console.error('获取用户信息失败，降级使用本地 Mock 数据: ' + JSON.stringify(error));
      const userId = AppStorage.get<number>('userId') || 1;
      return new Promise<User>(resolve => {
        setTimeout(() => resolve({
          id: userId.toString(),
          username: 'student',
          nickname: 'HarmonyOS User',
          email: 'student@growth-ai.com',
          role: 'STUDENT',
          token: 'mock-token'
        }), 300);
      });
    }
  }

  static async getUserStats(): Promise<UserStats> {
    try {
      const response = await HttpUtil.get('/api/user/stats');
      if (response.responseCode === 200 && response.result) {
        const resObj = JSON.parse(response.result as string) as Record<string, Object>;
        if (resObj.code === 200) {
          return resObj.data as UserStats;
        }
      }
      throw new Error("Failed to load user stats");
    } catch (error) {
      console.error('获取用户统计信息失败: ' + JSON.stringify(error));
      return { totalDuration: 0, masteredSkills: 0 } as UserStats;
    }
  }
}