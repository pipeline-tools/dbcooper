test_that("init inits", {
  src <- dbplyr::lahman_sqlite()
  dbc_init(src, "lahman")
  
  expect_true("tbl_lazy" %in% class(lahman_appearances()))
  
})
