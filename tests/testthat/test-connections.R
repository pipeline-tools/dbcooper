test_that("connection not found", {
  expect_error(dbc_get_connection("nonexistant"), "Connection not found")
})


test_that("connection added", {
  conn <- DBI::dbConnect(RSQLite::dbDriver("SQLite"), ":memory:")
  dbc_add_connection(conn, "added_conn")
  expect_equal(dbc_get_connection("added_conn"), conn)
})


test_that("connections cleared", {
  conn <- DBI::dbConnect(RSQLite::dbDriver("SQLite"), ":memory:")
  dbc_add_connection(conn, "dropped_conn")
  expect_equal(dbc_get_connection("dropped_conn"), conn)
  dbc_clear_connections()
  expect_error(dbc_get_connection("dropped_conn"), "Connection not found")
})
