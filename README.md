# remotedb
For getting accessor functions for remote tables in R

# How to use

Edit your Renviron with `usethis::edit_r_environ()` and add the `rmdb_` parameters to connect to your database:

- `rmdb_driver:`Pick your database's driver *(for the time being, the only support is for "PostgreSQL")*
- `rmdb_name:` The name of the database
- `rmdb_host:` The host location of the database
- `rmdb_port:` Port of database (usuallt 5432 for PostgreSQL)
- `rmdb_user:` Database user name
- `rmdb_password:`Database user's password

Once `remotedb` is loaded with `library(remotedb)`, the package will autocreate accessor functions that make each database table available to you as a remote `tbl`. Access functions follow the pattern `tbl_schema_table()`. 

Additionally, there are three other important functions:

- `reset_connection():` Sometimes your database connection will go stale. This will reset that connection
- `rmdb_tbl():` Access a table in the database by name, using the format `rmdb_tbl("schema.table_name")`
- `rmdb_query():` Send a SQL query directly to the database

# Things to add

## Support for other database types

- MySQL 
- SQLite
- SQL Server
- Oracle

## Additional Renviron parameters
- `rmdb_explicit_schemas`: Only create accessor functions for tables within a certain schema
- `rmdb_exclude_schemas`: Create accessor functions for all schema except the ones listed

## YAML support for `rmdb_query()`

When handed a `.yml` file instead of SQL text, search the file for a `query` parameter and execute that query.
