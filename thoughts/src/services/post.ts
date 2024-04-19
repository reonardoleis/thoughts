import { Pagination, Post } from "./types";

export async function list(
  page: number,
  limit: number
): Promise<Pagination<Post>> {
  const url = (import.meta.env.VITE_API_URL as string) + "/posts";
  const result = await fetch(`${url}?page=${page}&limit=${limit}`);
  const data = await result.json();
  return data;
}

export async function get(id: number): Promise<Post> {
  const url = (import.meta.env.VITE_API_URL as string) + `/posts/${id}`;
  const result = await fetch(url);
  const data = await result.json();
  return data;
}
