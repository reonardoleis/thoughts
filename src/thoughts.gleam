import controllers/context
import database/connector
import gleam/erlang/process
import mist
import router/router
import wisp

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let db = connector.connect()
  let ctx = context.Context(db)

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
