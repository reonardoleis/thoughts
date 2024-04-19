import controllers/context.{type ControllerContext}
import dto/post.{decode_create_post_req, encode_post, encode_posts_pagination}
import gleam/http.{Get, Post}
import gleam/string_builder
import repositories/posts as posts_repository
import utils/params.{parse_int_fallback}
import utils/query_pagination.{get_query_pagination}
import wisp.{type Request, type Response}

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
      |> wisp.set_header("Access-Control-Allow-Origin", "*")
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
          |> wisp.set_header("Access-Control-Allow-Origin", "*")
        Error(_) -> wisp.internal_server_error()
      }
    }
    Error(_) -> wisp.bad_request()
  }
}

pub fn find_by_id(id: String, ctx: ControllerContext) -> Response {
  let id = parse_int_fallback(id, 0)

  let post = posts_repository.find(ctx.db, id)
  case post {
    Ok(post) ->
      encode_post(post)
      |> string_builder.from_string
      |> wisp.json_response(200)
      |> wisp.set_header("Access-Control-Allow-Origin", "*")
    Error(err) -> {
      case err {
        "not found" -> wisp.not_found()
        "internal error" ->
          wisp.internal_server_error()
          |> wisp.string_body("internal_error")
        other ->
          wisp.internal_server_error()
          |> wisp.string_body(other)
          |> wisp.set_header("Access-Control-Allow-Origin", "*")
      }
    }
  }
}
