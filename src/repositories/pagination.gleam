pub type Pagination(a) {
  Pagination(
    data: List(a),
    total: Int,
    page: Int,
    limit: Int,
    pages: Int,
    next: Int,
    prev: Int,
  )
}
