import gleam/pgo.{type Connection}
import wisp

pub type Context {
  Context(connection: Connection)
}

pub fn middleware(
  request: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.log_request(request)
  use <- wisp.rescue_crashes

  handle_request(request)
}
