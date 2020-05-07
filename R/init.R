# Initialize the tables based on a database connection

#' Create one table function
#' 
#' @param table_name Name of the table
#' @template con-id
#' @param env Environment in which to create the table accessors, such
#' as the global environment or a package namespace.
#' @param table_format Optionally, a function to clean the table name
#' before turning it into a function name, such as removing prefixes 
#' @param table_post Post-processing to perform on each table before
#' returning it
#' 
#' @importFrom purrr %||%
assign_table_function <- function(table_name,
                                  con_id,
                                  env = parent.frame(),
                                  table_formatter = NULL,
                                  table_post = NULL) {
  table_formatter <- table_formatter %||% identity
  table_post <- table_post %||% identity
  
  # Create the function
  fun <- function() table_post(dbc_table(table_name, con_id))
  attr(fun, 'connection') <- con_id
  attr(fun, 'table') <- table_name
  
  clean_name <- table_formatter(table_name)
  clean_name <- tolower(gsub("\\.", "_", clean_name))
  
  function_name <- paste0(con_id, "_", clean_name)
  assign(function_name, fun, pos = env)
}

#' Create functions for accessing a remote database
#' 
#' Create and assign functions that make accessing a database easy.
#' These include \code{tbl_} functions for each table in the database,
#' as well as \code{query_[id]} and \code{execute_[id]} functions for
#' querying and executing SQL in the database.
#' 
#' @param con A DBI-compliant database connection object, or a
#' \code{src_dbi}.
#' @param con_id A short string that identifies the database. This
#' is used to create functions \code{query_}, \code{tbl_} and
#' \code{execute_} with appropriate names, as well as to cache the
#' connection globally.
#' @param env Environment in which to create the table accessors, such
#' as the global environment or a package namespace.
#' @param tables Optionally, a vector of tables. Useful if dbcooper's
#' table listing functions don't work for a database, or if you want to
#' use only a subset of tables.
#' @param table_prefix Optionally, a prefix to append to each table,
#' usually a schema.
#' @param table_format Optionally, a function to clean the table name
#' before turning it into a function name, such as removing prefixes 
#' @param table_post Post-processing to perform on each table before
#' returning it
#' 
#' @examples 
#' 
#' library(dplyr)
#' library(dbplyr)
#' 
#' # Initialize based on a SQL src or connection object
#' src <- lahman_sqlite()
#' dbc_init(src, "lahman")
#' 
#' ## Tables
#' 
#' # Access each table using autocompleted functions
#' lahman_batting()
#' 
#' # Can also pass the name of a table as a string to lahman_tbl
#' lahman_tbl("Pitching")
#' 
#' # Pass no argument to get a vector of all the tables
#' lahman_list()
#' 
#' # Run a SQL query
#' lahman_query("SELECT COUNT(*) FROM Master")
#' 
#' # Execute queries that change the database
#' lahman_execute("CREATE TABLE Players AS
#'   SELECT playerID, sum(AB) as AB FROM Batting GROUP BY playerID"
#' )
#' 
#' lahman_tbl("Players")
#' 
#' lahman_execute("DROP TABLE Players")
#' 
#' @export
dbc_init <- function(con, con_id, env = parent.frame(), ...) {
  UseMethod("dbc_init")
}

#' @rdname dbc_init
#' @export
dbc_init.default <- function(con, con_id, env = parent.frame(),
                             tables = NULL,
                             table_prefix = NULL,
                             table_formatter = NULL,
                             table_post = NULL,
                             ...) {
  # Assign the connection/pool globally so it can be accessed later
  dbc_add_connection(con, con_id)

  table_post <- table_post %||% identity
  
  # Create functions for querying and getting a single table
  list_fun <- function(query) { dbc_list_tables(dbc_get_connection(con_id)) }
  assign(paste0(con_id, "_list"), list_fun, pos = env)
  
  query_fun <- function(query) { dbc_query(query, con_id) }
  assign(paste0(con_id, "_query"), query_fun, pos = env)
  
  tbl_fun <- function(table_name = NULL) { table_post(dbc_table(paste0(table_prefix, table_name), con_id)) }
  assign(paste0(con_id, "_tbl"), tbl_fun, pos = env)
  
  exec_fun <- function(query) { dbc_execute(query, con_id) }
  assign(paste0(con_id, "_execute"), exec_fun, pos = env)
  
  src_fun <- function() { dbplyr::src_dbi(dbc_get_connection(con_id)) }
  assign(paste0(con_id, "_src"), src_fun, pos = env)
  
  # Create functions for each individual table
  if (is.null(tables)) {
    tables <- dbc_list_tables(con)
  }

  invisible(purrr::map(tables, assign_table_function, con_id, env = env,
                       table_formatter = table_formatter,
                       table_post = table_post))
}

#' @rdname dbc_init
#' @export
dbc_init.src_sql <- function(con, con_id, env = parent.frame(), ...) {
  dbc_init(con$con, con_id, env = parent.frame(), ...)
}
