import { ChatMessage, ChatResponse } from '../model/Message';
import { HttpUtil } from '../utils/HttpUtil';
import util from '@ohos.util';

export interface SendMessageResult {
  answer: string;
  conversationId: string;
}

export class ChatService {
  static async getChatHistory(): Promise<ChatMessage[]> {
    try {
      const response = await HttpUtil.get('/api/ai/history');
      return JSON.parse(response.result as string) as ChatMessage[];
    } catch (error) {
      console.error('获取聊天历史失败，降级使用本地 Mock 数据');
      return new Promise(resolve => {
        setTimeout(() => resolve([
          {
            id: 'init-1',
            text: '你好！我是你的 AI 学习伴侣。在准备今天的进阶课程之前，你有什么具体想了解的概念吗？',
            isMe: false
          }
        ]), 500);
      });
    }
  }

  static async sendMessage(query: string, conversationId: string): Promise<SendMessageResult> {
    const requestData: Record<string, string> = { "query": query, "user": "student_1" };
    if (conversationId) {
      requestData["conversation_id"] = conversationId;
    }
    
    const res = await HttpUtil.post('/api/ai/chat', requestData);
    const parsedRes = JSON.parse(res.result as string) as ChatResponse;
    const aiAnswer = parsedRes.data.answer.replace(/<think>[\s\S]*?<\/think>/g, '').trim();
    
    const result: SendMessageResult = {
      answer: aiAnswer,
      conversationId: parsedRes.data.conversation_id
    };
    return result;
  }
}