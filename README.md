# remotedb
For getting accessor functions for remote tables in R

# How to use

## Necessary setup

**First:** edit your Renviron with `usethis::edit_r_environ()` and add the `rmdb_` parameters to connect to your database:

- **Required**

  - `rmdb_driver:`Pick your database's driver **(for the time being, the only support is for "PostgreSQL")**
  - `rmdb_name:` The name of the database
  - `rmdb_host:` The host location of the database
  - `rmdb_port:` Port of database (usuallt 5432 for PostgreSQL)
  - `rmdb_user:` Database user name
  - `rmdb_password:`Database user's password
  
- **Optional**

  - `rmdb_explicit_schemas:` Pass specific schemas whose tables will get accessor function. Format in .Renviron as `rmdb_explicit_schemas="('schema1', schema2')"`. This `('schema1', schema2')` is passed to a `WHERE` clause to determine the schemas to include, so make sure to follow formatting explicitly.
  - `rmdb_exclude_schemas`: Pass specific schemes whose tables will be excluded from having accessor functions. Format in .Renviron as `rmdb_exclude_schemas="('schema1', schema2')"`. This `('schema1', schema2')` is passed to a `WHERE` clause to determine the schemas to exclude, so make sure to follow formatting explicitly.
  - **NOTE: if both an `rmdb_explicit_schemas` and an `rmdb_exclude_schemas` are defined in Renviron, `rmdb_explicit_schemas` will be prioritized.**

**Next:** install the package with `devtools::install_github("chriscardillo/remotedb")`

**Last:** Load the package with `library(remotedb)`

## Usage

Once `remotedb` is loaded, the package will autocreate accessor functions that make each database table available to you as a remote `tbl`. Access functions follow the pattern `tbl_schema_table()`. 

Additionally, there are three other important functions:

- `reset_connection():` Sometimes your database connection will go stale. This will reset that connection
- `rmdb_tbl():` Access a table in the database by name, using the format `rmdb_tbl("schema.table_name")`
- `rmdb_query():` Send a SQL query directly to the database. Also accepts `.yml` files with a `query` parameter

# Things to add

## Support for other database types

- MySQL 
- SQLite
- SQL Server
- Oracle
