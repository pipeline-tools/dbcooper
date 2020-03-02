## First, utilities to access a table from a connection ID.

#' Access a single table
#' 
#' @param table_name Name of the table in the database. If no table is
#' provided, returns a list of tables as a character vector.
#' @template con-id
dbc_table <- function(table_name = NULL, con_id) {
  con <- dbc_get_connection(con_id)
  
  if (is.null(table_name)) {
    return(dbc_list_tables(con))
  }
  
  if(!grepl("\\.", table_name)){
    dplyr::tbl(con, table_name)
  } else if (grepl(".\\.", table_name)) {
    table_split <- strsplit(table_name, "\\.")[[1]]
    schema <- table_split[1]
    table <- table_split[2]
    dplyr::tbl(con, dbplyr::in_schema(schema, table))
  } else if(grepl("^\\.", table_name)){
    table <- paste0("public", gsub("^\\.", "_", table_name))
    dplyr::tbl(con, table)
  }
}

#' Given a string, turn it into a SQL query
#' 
#' Internal function to pull a query from a string. If the string is in a
#' YAML or plain text file, read it
#' 
#' @param query A string or filename
query_from_str <- function(query) {
  if (grepl("*.yml$", query)) {
    if (!requireNamespace("yaml", quietly = TRUE)) {
      stop("Reading a yml file requires the yaml package to be installed")
    }
    
    yaml <- yaml::read_yaml(query)
    
    if("sql" %in% names(yaml)) {
      query <- yaml[["sql"]]
    } else {
      stop(paste0("No parameter 'sql' found in file ", query))
    }
  } else if (file.exists(query)) {
    # Query is in a file; read it
    query <- paste(readLines(query), collapse = "\n")
  }
  query
}

#' Run a query on a SQL database and get a remote table back
#' 
#' @param query Either a SQL query as a string, a file containing a SQL
#' query, or a YAML file with a \code{sql} parameter.
#' @template con-id
#' 
#' @return A \code{tbl_sql} with the remote results
dbc_query <- function(query, con_id) {
  dplyr::tbl(dbc_get_connection(con_id), dplyr::sql(query_from_str(query)))
}

#' Execute a query on a SQL database
#' 
#' @param query Either a SQL query as a string, a file containing a SQL
#' query, or a YAML file with a \code{sql} parameter.
#' @template con-id
dbc_execute <- function(query, con_id) {
  DBI::dbExecute(dbc_get_connection(con_id), query)
}
