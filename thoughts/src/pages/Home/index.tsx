import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { list } from "../../services/post";
import { Pagination, Post } from "../../services/types";

function Home() {
  const [posts, setPosts] = useState<Pagination<Post>>();

  async function fetchData(page: number = 1, limit: number = 10) {
    const posts = await list(page, limit);
    setPosts(posts);
  }

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <>
      <div className="flex flex-row items-center justify-center h-screen text-white">
        <div className="flex flex-col w-full max-w-2xl p-4 space-y-4">
          {posts?.data.map((post) => (
            <Link key={post.id} to={`/post/${post.id}`}>
              <div
                key={post.id}
                className="flex flex-col p-4 bg-slate-800 rounded-lg h-[90px]"
              >
                <h2 className="text-2xl font-bold">{post.title}</h2>
                <div className="block h-[90px] overflow-hidden truncate">
                  {post.content}
                </div>
              </div>
            </Link>
          ))}
          <div className="flex flex-row items-center justify-center h-16 text-white">
            <div className="flex flex-row space-x-4">
              <button
                className="px-4 py-2 bg-slate-800 rounded-lg"
                disabled={posts?.prev === 0}
                onClick={() => fetchData(posts?.prev)}
              >
                Prev
              </button>
              <button
                className="px-4 py-2 bg-slate-800 rounded-lg"
                disabled={posts?.next === 0}
                onClick={() => fetchData(posts?.next)}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default Home;
