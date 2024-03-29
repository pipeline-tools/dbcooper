% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{dbc_list_tables}
\alias{dbc_list_tables}
\alias{dbc_list_tables.default}
\alias{dbc_list_tables.PqConnection}
\alias{dbc_list_tables.Snowflake}
\alias{dbc_list_tables.SnowflakeDBConnection}
\alias{dbc_list_tables.duckdb_connection}
\title{List tables in a database}
\usage{
dbc_list_tables(con, exclude_schemas)

\method{dbc_list_tables}{default}(con, exclude_schemas = c("information_schema", "pg_catalog"))

\method{dbc_list_tables}{PqConnection}(con, exclude_schemas = c("information_schema", "pg_catalog"))

\method{dbc_list_tables}{Snowflake}(con, exclude_schemas = c("INFORMATION_SCHEMA"))

\method{dbc_list_tables}{SnowflakeDBConnection}(con, exclude_schemas = c("INFORMATION_SCHEMA"))

\method{dbc_list_tables}{duckdb_connection}(con, exclude_schemas = c("INFORMATION_SCHEMA"))
}
\arguments{
\item{con}{A connection or pool object}

\item{exclude_schemas}{Schemas for which no tables should be returned.
The default excludes information_schema and pg_catalog, which typically
contain database metadata.}
}
\description{
dbListTables doesn't work for all types of databases, especially
ones that have schemas. We use this approach instead.
Work in progress as we test across different database types.
}
