#' Get Connection
#' @importFrom DBI dbConnect
#' @importFrom RPostgreSQL PostgreSQL
#' @importFrom RMySQL MySQL
get_con <- function(){
  drivers <- list("PostgreSQL" = quote(RPostgreSQL::PostgreSQL()),
                  "MySQL" = quote(RMySQL::MySQL()))
  driver <- drivers[[Sys.getenv("rmdb_driver")]]
  con <- DBI::dbConnect(eval(driver),
                        dbname=Sys.getenv("rmdb_name"),
                        host=Sys.getenv("rmdb_host"),
                        port=Sys.getenv("rmdb_port"),
                        user=Sys.getenv("rmdb_user"),
                        password=Sys.getenv("rmdb_password"))
  return(con)
}

#' Disconnect
#' @importFrom DBI dbDisconnect
disconnect_con = function(){
  DBI::dbDisconnect(getOption("RMDB"))
}

#' Replace connection
replace_con = function(){
  options(RMDB = get_con())
}

#' Instantiate RMDB
create_rmdb <- function(){
  replace_con()
}

#' Replace the connection object
#' @export
reset_connection <- function(){
  message(paste0("Reestablishing connection to ",
                 Sys.getenv("rmdb_driver"),
                 " database: ",
                 Sys.getenv("rmdb_name"), "..."))
  disconnect_con()
  invisible(replace_con())
}

