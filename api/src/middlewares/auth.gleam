import envoy
import gleam/iterator
import wisp

fn validate_token(token: String) -> Bool {
  case envoy.get("POSTS_API_TOKEN") {
    Ok(expected) -> token == expected
    _ -> False
  }
}

pub fn middleware(
  req: wisp.Request,
  handler: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let authorization =
    req.headers
    |> iterator.from_list
    |> iterator.find(fn(header) {
      case header {
        _ if header.0 == "authorization" -> True
        _ -> False
      }
    })

  case authorization {
    Ok(#(_, token)) ->
      case validate_token(token) {
        True -> handler(req)
        False ->
          wisp.response(401)
          |> wisp.string_body("token is invalid")
      }
    _ ->
      wisp.response(401)
      |> wisp.string_body("token is required")
  }
}
