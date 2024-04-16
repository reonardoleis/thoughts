import controllers/context.{type ControllerContext}
import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
import gleam/string_builder
import models/post.{type Post as PostModel}
import repositories/pagination
import repositories/posts as posts_repository
import utils/query_pagination.{get_query_pagination}
import wisp.{type Request, type Response}

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

pub fn posts(req: Request, ctx: ControllerContext) -> Response {
  case req.method {
    Get -> get(req, ctx)
    Post -> post(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn get(req: Request, ctx: ControllerContext) -> Response {
  let #(page, limit) = get_query_pagination(wisp.get_query(req))

  let posts = posts_repository.list(ctx.db, page, limit)
  case posts {
    Ok(posts) ->
      encode_posts_pagination(posts)
      |> string_builder.from_string
      |> wisp.json_response(200)
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn post(req: Request, ctx: ControllerContext) -> Response {
  use json <- wisp.require_json(req)

  let decoded = decode_create_post_req(json)

  case decoded {
    Ok(req) -> {
      let post = posts_repository.create(ctx.db, req.title, req.content)
      case post {
        Ok(v) ->
          encode_post(v)
          |> string_builder.from_string
          |> wisp.json_response(200)
        Error(_) -> wisp.internal_server_error()
      }
    }
    Error(_) -> wisp.bad_request()
  }
}
