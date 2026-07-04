import { HttpUtil } from '../utils/HttpUtil';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T | null;
}

export interface LoginResponseData {
  id: number;
  username: string;
  role: string;
  token: string;
}

export interface AuthLoginRequest {
  username: string;
  password: string;
}

export interface AuthLoginData {
  token: string;
  userId: number;
}

export class AuthService {
  static async login(username: string, password: string): Promise<AuthLoginData> {
    const req: AuthLoginRequest = {
      username: username,
      password: password
    };

    const res = await HttpUtil.post('/api/auth/login/student', req);
    const parsed = JSON.parse(res.result as string) as ApiResponse<LoginResponseData>;
    if (parsed.code !== 200 || !parsed.data) {
      throw new Error(parsed.message || '登录失败');
    }
    if (!parsed.data.token || parsed.data.token.length === 0) {
      throw new Error('登录失败：token 为空');
    }
    const data: AuthLoginData = {
      token: parsed.data.token,
      userId: parsed.data.id
    };
    return data;
  }
}
