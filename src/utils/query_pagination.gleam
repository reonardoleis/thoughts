import gleam/int
import gleam/iterator

pub type QueryPagination =
  #(Int, Int)

fn find_predicate(key: String, x: #(String, String)) -> Bool {
  let #(k, _) = x
  k == key
}

fn get_or_fail_with(
  needle: String,
  haystack: List(#(String, String)),
  onfail: Int,
) -> Int {
  let it = iterator.from_list(haystack)

  let predicate = find_predicate(needle, _)

  case iterator.find(it, predicate) {
    Ok(found) -> {
      let #(_, v) = found
      let parsed = int.parse(v)
      case parsed {
        Ok(v) -> v
        _ -> onfail
      }
    }
    Error(Nil) -> onfail
  }
}

pub fn get_query_pagination(query: List(#(String, String))) -> QueryPagination {
  let page = get_or_fail_with("page", query, 1)
  let limit = get_or_fail_with("limit", query, 10)

  #(page, limit)
}
