import http from '@ohos.net.http';

const BASE_URL: string = 'http://172.29.66.214:8080';
const TOKEN: string = 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJsYXUiLCJ1c2VySWQiOjEsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzMDYxMDI0LCJleHAiOjE3ODM2NjU4MjR9.RprE0iN1E7nx5pBHPQ-oIcWYB9Im06pgoWZCjVZFM2cEwCiBkWkEus6yMVENljgw';

export class HttpUtil {
  static async request(url: string, method: http.RequestMethod, data?: Record<string, string>): Promise<http.HttpResponse> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${BASE_URL}${url}`,
        {
          method: method,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${TOKEN}`
          },
          extraData: data,
          readTimeout: 30000,
          connectTimeout: 30000
        }
      );

      if (response.responseCode === 200) {
        return response;
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

  static async post(url: string, data?: Record<string, string>): Promise<http.HttpResponse> {
    return HttpUtil.request(url, http.RequestMethod.POST, data);
  }
}