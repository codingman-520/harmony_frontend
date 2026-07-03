export interface User {
  id: string;
  username: string;
  nickname: string;
  email: string;
  role: 'STUDENT' | 'ADMIN';
  token: string;
}