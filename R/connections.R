# Work with global connections

#' Add a connection or pool to the global options
#' 
#' dbcooper maintains a named list of connections or
#' (recommended) pools. This internal function adds
#' one.
#' 
#' @param con Connection or pool object
#' @template con-id
#' 
#' @export
dbc_add_connection <- function(con, con_id) {
  connections <- getOption("dbc_connections")
  
  if (is.null(connections)) {
    connections <- list()
  }
    
  connections[[con_id]] <- con
  
  options(dbc_connections = connections)
}

#' Retrieve a connection or pool from the global options
#' 
#' dbcooper maintains a named list of connections or
#' (recommended) pools. This internal function retrieves
#' one.
#' 
#' @template con-id
#' 
#' @export
dbc_get_connection <- function(con_id) {
  connections <- getOption("dbc_connections")
  
  con <- connections[[con_id]]
  
  if (is.null(con)) {
    stop("Connection not found: ", con)
  }
  
  con
}

#' Clear all connections created by dbc
#' 
#' @export 
dbc_clear_connections <- function() {
  connections <- getOption("dbc_connections")
  
  for (con in connections) {
    purrr::possibly(DBI::dbDisconnect, NULL)(con)
  }
  
  options(dbc_connections = list())
}