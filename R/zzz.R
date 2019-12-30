#' Connect and grab tables when loaded
.onLoad <- function(libname, pkgname) {
  package_env <- parent.env(environment())
  message(paste0("Establishing connection to ", Sys.getenv("rmdb_driver"), " database ", Sys.getenv("rmdb_name"), "..."))
  create_rmdb()
  get_table_functions(env = package_env)
}

#' Disconnect
.onUnload <- function(libpath){
  disconnect_con()
  options(RMDB = NULL)
}
