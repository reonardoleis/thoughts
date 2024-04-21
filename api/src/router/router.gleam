import controllers/context.{type ControllerContext}
import controllers/posts.{find_by_id, posts}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: ControllerContext) -> Response {
  case wisp.path_segments(req) {
    ["v1", "posts"] -> posts(req, ctx)
    ["v1", "posts", id] -> find_by_id(id, ctx)
    _ -> wisp.not_found()
  }
}
