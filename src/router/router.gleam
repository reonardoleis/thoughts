import controllers/context.{type ControllerContext}
import controllers/posts.{posts}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: ControllerContext) -> Response {
  case wisp.path_segments(req) {
    ["post"] -> posts(req, ctx)
    _ -> wisp.not_found()
  }
}
