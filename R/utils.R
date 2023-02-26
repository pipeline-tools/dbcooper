#' Require a parameter by name
#' 
#' Throws an error if the parameter is not set.
#' 
#' @param param_name Parameter to look up with \code{\link[base]{Sys.getenv}}.
#' 
#' @export
dbc_param <- function(param_name) {
  ret <- Sys.getenv(param_name)
  if (!nzchar(ret)) {
    stop("You must set ", param_name, " in your .Renviron (then restart R)")
  }
  ret
}

#' Set an option by name
#' 
#' Utility. This is a bit difficult to do with the options() function.
#' 
#' @param option_name Name
#' @param value Value
set_option <- function(option_name, value) {
  args <- stats::setNames(list(value), option_name)
  do.call(options, args)
}

#' List tables in a database
#' 
#' dbListTables doesn't work for all types of databases, especially
#' ones that have schemas. We use this approach instead.
#' Work in progress as we test across different database types.
#' 
#' @param con A connection or pool object
#' @param exclude_schemas Schemas for which no tables should be returned.
#' The default excludes information_schema and pg_catalog, which typically
#' contain database metadata.
#' 
#' @importFrom dplyr %>%
dbc_list_tables <- function(con, exclude_schemas) {
  UseMethod("dbc_list_tables")
}

#' @rdname dbc_list_tables
#' @export
dbc_list_tables.default <- function(con,
                                    exclude_schemas = c("information_schema", "pg_catalog")) {
  tables <- DBI::dbListTables(con)
  
  # Remove ones that match the regex
  exclude_regex <- paste0(exclude_schemas, "\\.", collapse = "|")
  tables <- tables[!grepl(exclude_regex, tables)]
  return(tables)
}

#' @rdname dbc_list_tables
#' @export
dbc_list_tables.PqConnection <- function(con, exclude_schemas = c("information_schema", "pg_catalog")) {
  # Base Query, currently meant for postgres and mysql only
  query <- "SELECT CONCAT(table_schema, '.', table_name) AS table_name_raw, table_schema
            FROM information_schema.tables"
  
  tables <- DBI::dbGetQuery(con, query) %>%
    dplyr::filter(!table_schema %in% exclude_schemas) %>%
    dplyr::select(table_name_raw) %>%
    dplyr::pull()
  
  return(tables)
}

#' @rdname dbc_list_tables
#' @export
dbc_list_tables.Snowflake <- function(con,
                                      exclude_schemas = c("INFORMATION_SCHEMA")) {
  tables <- DBI::dbGetQuery(con, "SHOW TERSE TABLES") %>%
    dplyr::select(database_name, schema_name, name)
  
  views <- DBI::dbGetQuery(con, "SHOW TERSE VIEWS") %>%
    dplyr::select(database_name, schema_name, name)
  
  dplyr::bind_rows(tables, views) %>%
    dplyr::filter(!schema_name %in% exclude_schemas) %>%
    with(paste(database_name, schema_name, name, sep = "."))
}

#' @rdname dbc_list_tables
#' @export
dbc_list_tables.SnowflakeDBConnection <- function(con,
                                                  exclude_schemas = c("INFORMATION_SCHEMA")) {
  # The dplyr.snowflakedb package
  dbc_list_tables.Snowflake(con, exclude_schemas)
}


#' @rdname dbc_list_tables
#' @export
dbc_list_tables.duckdb_connection <- function(con,
                                              exclude_schemas = c("INFORMATION_SCHEMA")) {
  dplyr::pull(DBI::dbGetQuery(con, "SELECT table_schema || '.' || table_name AS table_name FROM information_schema.tables"), "table_name")
}
