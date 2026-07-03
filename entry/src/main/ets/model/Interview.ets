export interface InterviewStartResponse {
  sessionId: number;
  questionId: number;
  questionText: string;
}

export interface InterviewAnswerResponse {
  sessionId: number;
  isCompleted: boolean;
  questionId?: number;
  questionText?: string;
  currentIndex?: number;
  totalCount?: number;
}

export interface InterviewResult {
  score: number;
  feedback?: string;
}

