import gleam/pgo

pub type ControllerContext {
  Context(db: pgo.Connection)
}
