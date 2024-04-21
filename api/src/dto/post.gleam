import gleam/dynamic.{type Dynamic}
import gleam/json
import gleam/list
import models/post.{type Post as PostModel}
import repositories/pagination

pub type CreatePostReq {
  CreatePostReq(title: String, content: String)
}

pub fn decode_create_post_req(
  json: Dynamic,
) -> Result(CreatePostReq, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      CreatePostReq,
      dynamic.field("title", dynamic.string),
      dynamic.field("content", dynamic.string),
    )
  decoder(json)
}

pub fn encode_post(post: PostModel) -> String {
  let object =
    json.object([
      #("id", json.int(post.id)),
      #("title", json.string(post.title)),
      #("content", json.string(post.content)),
      #("created_at", json.string(post.created_at)),
    ])

  json.to_string(object)
}

pub fn encode_posts_pagination(
  pagination: pagination.Pagination(PostModel),
) -> String {
  let object = [
    #("total", json.int(pagination.total)),
    #("page", json.int(pagination.page)),
    #("limit", json.int(pagination.limit)),
    #("pages", json.int(pagination.pages)),
    #("next", json.int(pagination.next)),
    #("prev", json.int(pagination.prev)),
  ]

  let object =
    list.append(
      [
        #(
          "data",
          json.array(pagination.data, fn(x: PostModel) -> json.Json {
            json.object([
              #("id", json.int(x.id)),
              #("title", json.string(x.title)),
              #("content", json.string(x.content)),
              #("created_at", json.string(x.created_at)),
            ])
          }),
        ),
      ],
      object,
    )

  json.to_string(json.object(object))
}
