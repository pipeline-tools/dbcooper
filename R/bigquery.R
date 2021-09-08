#' Wrap a BigQuery dataset with accessor functions
#' 
#' @export
dbc_bigquery <- function(prefix,
                         dataset,
                         billing = dbc_param("BIGQUERY_BILLING_PROJECT"),
                         project = "bigquery-public-data",
                         env = parent.frame(),
                         ...) {
  con <- DBI::dbConnect(
    bigrquery::bigquery(),
    dataset = dataset,
    billing = billing,
    project = project,
    ...
  )
  
  dbc_init(con, prefix, env = env)
}
