import app/web.{type Context}
import films/models.{CreateFilm, Film}
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/pgo
import gleam/string
import gleam/string_builder
import wisp

pub fn get_all_films(ctx: Context) -> wisp.Response {
  let sql = "SELECT * FROM Films;"
  let decoder = dynamic.tuple3(dynamic.int, dynamic.string, dynamic.int)
  let assert Ok(records) = pgo.execute(sql, ctx.connection, [], decoder)
  let films =
    records.rows
    |> list.map(fn(x) { Film(x.0, x.1, x.2) })
  let json =
    "["
    <> films
    |> list.map(fn(x) {
      json.object([
        #("id", json.int(x.id)),
        #("name", json.string(x.name)),
        #("year", json.int(x.year)),
      ])
      |> json.to_string()
    })
    |> string.join(",")
    <> "]"
  wisp.ok() |> wisp.json_body(string_builder.from_string(json))
}

pub fn get_film_by_id(ctx: Context, id: Int) -> wisp.Response {
  let sql = "SELECT * FROM Films WHERE id = $1"
  let decoder = dynamic.tuple3(dynamic.int, dynamic.string, dynamic.int)
  let assert Ok(records) =
    pgo.execute(sql, ctx.connection, [pgo.int(id)], decoder)
  let film = case records.rows {
    [x] -> Some(Film(x.0, x.1, x.2))
    _ -> None
  }
  let json = case film {
    Some(x) ->
      json.object([
        #("id", json.int(x.id)),
        #("name", json.string(x.name)),
        #("year", json.int(x.year)),
      ])
      |> json.to_string()
    None -> "null"
  }
  wisp.ok() |> wisp.json_body(string_builder.from_string(json))
}

pub fn create_film(request: wisp.Request, ctx: Context) -> wisp.Response {
  use body <- wisp.require_json(request)

  let decoder =
    dynamic.decode2(
      CreateFilm,
      dynamic.field("name", dynamic.string),
      dynamic.field("year", dynamic.int),
    )
  let assert Ok(film) = decoder(body)
  let sql = "INSERT INTO Films(name, year) VALUES($1, $2)"
  let _ =
    pgo.execute(
      sql,
      ctx.connection,
      [pgo.text(film.name), pgo.int(film.year)],
      dynamic.dynamic,
    )
  wisp.no_content()
}

pub fn update_film(request: wisp.Request, ctx: Context) -> wisp.Response {
  use body <- wisp.require_json(request)

  let decoder =
    dynamic.decode3(
      Film,
      dynamic.field("id", dynamic.int),
      dynamic.field("name", dynamic.string),
      dynamic.field("year", dynamic.int),
    )
  let assert Ok(film) = decoder(body)
  let sql = "UPDATE Films SET name = $1, year = $2 WHERE id = $3"
  let _ =
    pgo.execute(
      sql,
      ctx.connection,
      [pgo.text(film.name), pgo.int(film.year), pgo.int(film.id)],
      dynamic.dynamic,
    )
  wisp.no_content()
}

pub fn delete_film(ctx: Context, id: Int) -> wisp.Response {
  let sql = "DELETE FROM Films WHERE id = $1"
  let _ = pgo.execute(sql, ctx.connection, [pgo.int(id)], dynamic.dynamic)
  wisp.no_content()
}
