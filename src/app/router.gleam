import app/web.{type Context, middleware}
import films/handlers.{
  create_film, delete_film, get_all_films, get_film_by_id, update_film,
}
import gleam/http.{Delete, Get, Post, Put}
import gleam/int
import wisp

pub fn handle_request(request: wisp.Request, ctx: Context) -> wisp.Response {
  use req <- middleware(request)

  case wisp.path_segments(req) {
    ["films"] if req.method == Get -> get_all_films(ctx)
    ["films", id] if req.method == Get -> {
      let assert Ok(id) = int.parse(id)
      get_film_by_id(ctx, id)
    }
    ["films"] if req.method == Post -> create_film(req, ctx)
    ["films"] if req.method == Put -> update_film(req, ctx)
    ["films", id] if req.method == Delete -> {
      let assert Ok(id) = int.parse(id)
      delete_film(ctx, id)
    }
    _ -> wisp.not_found()
  }
}
