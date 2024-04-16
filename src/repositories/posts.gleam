import gleam/dynamic
import gleam/iterator
import gleam/pgo
import gleam/result.{try}
import models/post as models
import repositories/pagination.{Pagination}

pub fn create(
  db: pgo.Connection,
  title: String,
  content: String,
) -> Result(models.Post, pgo.QueryError) {
  let sql =
    "
    INSERT INTO posts (title, content)
    VALUES ($1, $2)
    RETURNING id, created_at
    "

  let result =
    pgo.execute(
      sql,
      db,
      [pgo.text(title), pgo.text(content)],
      dynamic.tuple2(dynamic.int, dynamic.string),
    )

  case result {
    Ok(response) -> {
      let assert [post] = response.rows
      let #(id, created_at) = post
      Ok(models.Post(id, title, content, created_at))
    }
    Error(err) -> Error(err)
  }
}

pub fn list(
  db: pgo.Connection,
  page: Int,
  limit: Int,
) -> Result(pagination.Pagination(models.Post), pgo.QueryError) {
  let sql =
    "
    SELECT COUNT(*)
    FROM posts
    "

  use result <- try(pgo.execute(sql, db, [], dynamic.element(0, dynamic.int)))

  let assert [total] = result.rows

  let sql =
    "
    SELECT id, title, content, created_at::TEXT
    FROM posts
    ORDER BY id DESC
    OFFSET $1
    LIMIT $2
    "

  let offset = { page - 1 } * limit

  let t =
    dynamic.tuple4(dynamic.int, dynamic.string, dynamic.string, dynamic.string)

  use result <- try(pgo.execute(sql, db, [pgo.int(offset), pgo.int(limit)], t))

  let posts =
    iterator.from_list(result.rows)
    |> iterator.map(fn(row) {
      let #(id, title, content, created_at) = row
      models.Post(id, title, content, created_at)
    })
    |> iterator.to_list

  let pages = { total / limit } + 1
  let next = case page + 1 {
    x if x <= pages -> x
    _ -> page
  }

  let prev = case page - 1 {
    x if x > 0 -> x
    _ -> page
  }

  Pagination(posts, total, page, limit, pages, next, prev)
  |> Ok
}
