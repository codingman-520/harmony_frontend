import http from '@ohos.net.http';
import router from '@ohos.router';
import { PreferencesUtil } from './PreferencesUtil';

const BASE_URL: string = 'http://172.19.18.132:8080';

interface HttpHeaders {
  'Content-Type': string;
  'Authorization'?: string;
}

export class HttpUtil {
  static async request(url: string, method: http.RequestMethod, data?: object): Promise<http.HttpResponse> {
    const httpRequest = http.createHttp();
    try {
      let token: string = '';
      const storedToken = AppStorage.get<string>('token');
      if (storedToken && storedToken.length > 0) {
        token = storedToken;
      }

      const header: HttpHeaders = token.length > 0 ? {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      } : {
        'Content-Type': 'application/json'
      };

      const response = await httpRequest.request(
        `${BASE_URL}${url}`,
        {
          method: method,
          header: header,
          extraData: data,
          readTimeout: 30000,
          connectTimeout: 30000
        }
      );

      if (response.responseCode === 200) {
        return response;
      } else if (response.responseCode === 401) {
        AppStorage.setOrCreate('token', '');
        AppStorage.setOrCreate('userId', 0);
        await PreferencesUtil.delete('token');
        await PreferencesUtil.delete('userId');
        router.replaceUrl({ url: 'pages/Login' });
        throw new Error("[HttpError] Token已过期，请重新登录");
      } else {
        throw new Error(`[HttpError] 请求失败，状态码: ${response.responseCode}`);
      }
    } catch (error) {
      console.error(`【网络请求彻底失败】 错误详情: ${JSON.stringify(error)}`);
      throw new Error("Http Request Failed");
    } finally {
      httpRequest.destroy();
    }
  }

  static async get(url: string): Promise<http.HttpResponse> {
    return HttpUtil.request(url, http.RequestMethod.GET);
  }

  static async post(url: string, data?: object): Promise<http.HttpResponse> {
    return HttpUtil.request(url, http.RequestMethod.POST, data);
  }
}
