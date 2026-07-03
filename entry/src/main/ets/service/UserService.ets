import { User } from '../model/User';
import { HttpUtil } from '../utils/HttpUtil';

export class UserService {
  static async getUserProfile(): Promise<User> {
    try {
      const response = await HttpUtil.get('/api/user/profile');
      return JSON.parse(response.result as string) as User;
    } catch (error) {
      console.error('获取用户信息失败，降级使用本地 Mock 数据');
      return new Promise(resolve => {
        setTimeout(() => resolve({
          id: '1',
          username: 'zhangsan',
          nickname: '张三',
          email: 'zhangsan.edu@growth-ai.com',
          role: 'STUDENT',
          token: 'mock-token'
        }), 300);
      });
    }
  }
}