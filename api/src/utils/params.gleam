import gleam/int

pub fn parse_int_fallback(s: String, fallback: Int) -> Int {
  case int.parse(s) {
    Ok(v) -> v
    _ -> fallback
  }
}
