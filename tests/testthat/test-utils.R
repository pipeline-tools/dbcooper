test_that("param not set", {
  expect_error(dbc_param("nonexistant"), "You must set nonexistant in your .Renviron \\(then restart R\\)")
})


test_that("option is set", {
  set_option("my_option_name", "my_option_value")
  expect_equal(getOption("my_option_name"), "my_option_value")
})
