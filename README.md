# Sales Data Mart and OLAP Cubes in Oracle 19c Database

Overview
This project aims to establish a specialized Sales Data Mart to enhance data analytics and reporting for the Sales Department. Data is initially sourced from CSV files and loaded into an Oracle 19c database. The ETL process is managed through PL/SQL procedures and SSIS, transforming the relational data into a dimensional model. Finally, OLAP cubes are generated for advanced analytical capabilities.

## Tech Stack
Database: Oracle 19c
ETL Tools: PL/SQL, SSIS

## Data Sources
Initial Data: CSV Files
Operational Database: Oracle 19c

## Features
Data Loading: Import data from CSV to Oracle 19c relational database.
Dimensional Modeling: Create schema with dimension and fact tables in Oracle 19c.
ETL Process: Extract, Transform, Load data from relational to dimensional database.
OLAP Cubes: Generate cubes post-ETL for analytical queries.

## Constraints
Proper Primary and Foreign key constraints in Dimension and Fact tables.

## Future Scope
Real-time data updating.
Extend data mart for additional departments.
