export interface ChatMessage {
  id: string;
  text: string;
  isMe: boolean;
}

export interface ChatResponseData {
  answer: string;
  conversation_id: string;
}

export interface ChatResponse {
  code: number;
  message: string;
  data: ChatResponseData;
}