import { InterviewResult, InterviewStartResponse, InterviewAnswerResponse } from '../model/Interview';
import { HttpUtil } from '../utils/HttpUtil';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T | null;
}

export interface AnswerRequest {
  sessionId: number;
  questionId: number;
  answer: string;
}

export interface InterviewStartRequest {
  jobPosition: string;
}

export class InterviewService {
  static async startInterview(jobPosition: string): Promise<InterviewStartResponse> {
    const req: InterviewStartRequest = {
      jobPosition: jobPosition
    };
    
    // 获取全局 userId，确保与后端登录态完美对齐
    const currentUserId = AppStorage.get<number>('userId') || 1;
    
    const res = await HttpUtil.post(`/api/interview/start?userId=${currentUserId}`, req as object);
    const parsed = JSON.parse(res.result as string) as ApiResponse<InterviewStartResponse>;
    if (parsed.code !== 200 || !parsed.data) {
      throw new Error(parsed.message || '启动面试失败');
    }
    return parsed.data;
  }

  static async submitAnswer(sessionId: number, questionId: number, answer: string): Promise<InterviewAnswerResponse> {
    const req: AnswerRequest = {
      sessionId: sessionId,
      questionId: questionId,
      answer: answer
    };
    
    const res = await HttpUtil.post('/api/interview/answer', req as object);
    const parsed = JSON.parse(res.result as string) as ApiResponse<InterviewAnswerResponse>;
    if (parsed.code !== 200 || !parsed.data) {
      throw new Error(parsed.message || '提交答案失败');
    }
    return parsed.data;
  }

  static async getReport(sessionId: number): Promise<InterviewResult> {
    const res = await HttpUtil.get(`/api/interview/report/${sessionId}`);
    const parsed = JSON.parse(res.result as string) as ApiResponse<InterviewResult>;
    if (parsed.code !== 200 || !parsed.data) {
      throw new Error(parsed.message || '获取报告失败');
    }
    return parsed.data;
  }
}

