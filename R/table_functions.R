#' List tables
#' @import dplyr
#' @importFrom DBI dbGetQuery
list_tables <- function(){
  message(paste0("Getting table names from ",
                 Sys.getenv("rmdb_driver"),
                 " database: ",
                 Sys.getenv("rmdb_name"), "..."))
  tables <- DBI::dbGetQuery(getOption("RMDB"),
                            "SELECT CONCAT(table_schema, '.', table_name) AS table_name_raw
                            FROM information_schema.tables
                            WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
                            ")
  if(nrow(tables) > 0){
    tables <- tables %>% pull()
  } else{
    tables <- NULL
    message("...no tables found.")
  }
  return(tables)
}

#' Access a single table
#' @importFrom dplyr tbl
#' @importFrom dbplyr in_schema
access_table <- function(table_name, con = getOption('RMDB')){
  if(!grepl("\\.", table_name)){
    tryCatch(dplyr::tbl(con, table_name), error = function(error){message(paste0(error))})
  } else if(grepl("\\.", table_name) && !grepl("^\\.", table_name)){
    table_split <- unlist(strsplit(table_name, "[.]"))
    schema <- table_split[1]
    table <- table_split[2]
    tryCatch(dplyr::tbl(con, dbplyr::in_schema(schema, table)), error = function(error){message(paste0(error))})
  } else if(grepl("^\\.", table_name)){
    table <- paste0("public", gsub("^\\.", "_", table_name))
    tryCatch(dplyr::tbl(con, table_name), error = function(error){message(paste0(error))})
  }
}

#' Access a table by name
#' @param table_name a table name to send to the database
#' @export
rmdb_tbl <- function(table_name){
  access_table(table_name)
}

#' Query the database
#' @param query query for database
#' @importFrom dplyr tbl sql
#' @importFrom yaml read_yaml
#' @export
rmdb_query <- function(query){
  if(grepl("*.yml$", query)){
    yaml <- yaml::read_yaml(query)
    if("query" %in% names(yaml)){
      query <- yaml[["query"]]
    } else {
      stop(paste0("No parameter 'query' found in file ", query))
    }
  }
  tryCatch(dplyr::tbl(getOption("RMDB"), dplyr::sql(query)), error = function(error){message(paste0(error))})
}

#' Create table function
create_table_function <-function(table_name, env){
  fun <- eval(parse(text = paste0("function(){access_table('", table_name, "')}")))
  attr(fun, 'table') <- table_name
  if(grepl("[.]", table_name)){
    clean_name <- gsub("[.]", "_", table_name)
  } else {
    clean_name <- table_name
  }

  function_name <- paste0("tbl_", clean_name)
  assign(function_name, fun, pos = env)

}

#' Get table functions
#' @importFrom purrr map
#' @exportPattern ^tbl_.*$
get_table_functions <- function(env){
  tables <- list_tables()
  invisible(purrr::map(tables, create_table_function, env = env))
}

