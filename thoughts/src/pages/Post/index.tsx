import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { get } from "../../services/post";
import { Post as PostType } from "../../services/types";

function Post() {
  const { id } = useParams();
  const [post, setPost] = useState<PostType>();

  async function fetchData(id: number) {
    const post = await get(id);
    setPost(post);
  }

  useEffect(() => {
    fetchData(Number(id));
  }, []);

  return (
    <>
      <div className="flex flex-row justify-center h-screen text-white ">
        <div className="flex flex-col w-full max-w-[80%] p-4 space-y-4">
          <div className="flex flex-col p-4 bg-slate-800 rounded-lg">
            <h2 className="text-4xl font-bold text-center">{post?.title}</h2>
            <h3 className="text-lg text-center">{post?.created_at}</h3>
            <div
              className="block text-justify mt-2"
              dangerouslySetInnerHTML={{ __html: post?.content || "" }}
            />
          </div>
        </div>
      </div>
    </>
  );
}

export default Post;
