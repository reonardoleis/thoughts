import gleam/option
import gleam/pgo

pub fn connect() -> pgo.Connection {
  let config =
    pgo.Config(
      ..pgo.default_config(),
      host: "localhost",
      user: "postgres",
      password: option.Some("postgres"),
      database: "thoughts",
      pool_size: 15,
    )

  pgo.connect(config)
}
