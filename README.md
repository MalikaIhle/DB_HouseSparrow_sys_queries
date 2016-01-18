# DB_HouseSparrow_sys_queries

To get to the SQL code of ‘sys_queries’, you can go to ‘file’, ‘options’, ‘current database’, ‘navigation options’, ‘display options’, tick ‘show system objects’. The system objects comprise ‘usys_tables’ and ‘usys_queries’, the later being used to build the ‘sys_queries’. Those queries also use values set in ‘tblDatabaseSettings’.

a)	I provide my annotated SQL codes dissecting those sys_queries. They can be used for learning SQL and smart ways of querying things, for understanding the subtlety of the DB, for inspiration in writing your own queries for a related question.

b)	For some complex queries, I made a power point hierarchical organization chart to see the structure of one query and all the subqueries it is based on. Dark blue are for queries, dark green for tables, others colors are for redundant subqueries either only explained once within a sys_query scheme, or explained in other sys_query scheme.

c)	For the query Sys_SexEstimate, an extra R file was create to give an example of how to call Access from R (which means that it always gets up to date data), and insert your SQL queries in R. In addition, there is a small R tutorial, how to write SQL in R.
