interface Post {
  id: number;
  title: string;
  content: string;
  created_at: string;
}

interface Pagination<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  pages: number;
  next: number;
  prev: number;
}

export type { Pagination, Post };
