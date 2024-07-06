import app/router
import app/web
import gleam/erlang/process
import gleam/option
import gleam/pgo
import mist
import wisp

pub fn main() {
  wisp.configure_logger()

  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        database: "main",
        user: "admin",
        password: option.Some("admin"),
      ),
    )

  let ctx = web.Context(db)

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    handler
    |> wisp.mist_handler("secret key")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
