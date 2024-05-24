# Sales Data Mart Project

## Table of Contents
1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Data Sources](#data-sources)
4. [Features](#features)
5. [Constraints](#constraints)
6. [Future Scope](#future-scope)
8. [Business Requirements](#business-requirements)
9. [Multi-Dimensional Model Design](#multi-dimensional-model-design)
   - [Fact Table](#fact-table)
   - [Dimension Tables](#dimension-tables)
10. [Implementation](#implementation)
11. [Benefits](#benefits)
12. [Schema Creation and Data Integrity](#schema-creation-and-data-integrity)
13. [ETL Process](#etl-process)
15. [Conclusion](#conclusion)

## Overview
The Sales Data Mart Project aims to enhance data analytics and reporting capabilities for the Sales Department by creating a specialized data mart. This project involves sourcing data from CSV files, loading it into an Oracle 19c database, and managing the ETL process through PL/SQL procedures and SSIS. The goal is to transform relational data into a dimensional model and generate OLAP cubes for advanced analytical capabilities.

## Tech Stack
- **Database:** Oracle 19c
- **ETL Tools:** PL/SQL, SSIS

## Data Sources
- **Initial Data:** CSV Files
- **Operational Database:** Oracle 19c

## Features
1. **Data Loading:** Import data from CSV files into the Oracle 19c relational database.
2. **Dimensional Modeling:** Create schema with dimension and fact tables in Oracle 19c.
3. **ETL Process:** Extract, Transform, and Load data from the relational database to the dimensional database.
4. **OLAP Cubes:** Generate cubes post-ETL for advanced analytical queries.

## Constraints
- Enforce proper primary and foreign key constraints in dimension and fact tables.

## Future Scope
- Implement real-time data updating.
- Extend the data mart to include additional departments.
- 
## Business Requirements
A retail company selling products through various promotions needs insights into their sales, product performance, and customer behavior based on location.
### Sales Analysis
Analyze sales data to understand product performance, promotion effectiveness, and customer purchasing behavior by location.

### Customer Behavior Analysis
Gain insights into buying patterns, preferences, and demographics of customers based on their location.

### Product Performance Analysis
Track product performance over time, including attributes like descriptions, categories, prices, and their impact on sales.

### Promotion Effectiveness Analysis
Evaluate the effectiveness of different promotions by analyzing sales during promotion periods and identifying successful marketing strategies.

## Multi-Dimensional Model Design
The multi-dimensional model consists of a central fact table and associated dimension tables. The fact table stores measures related to sales, while the dimension tables store attributes for detailed analysis.

### Fact Table
**Sales Fact Table:**
- Measures: quantity_sold, amount_sold, unit price, cost price

### Dimension Tables
1. **Product Dimension (Type 2 SCD):**
   - Attributes: Product name, description, category, etc.
   
2. **Customer Dimension (Type 2 SCD):**
   - Attributes: Customer name, gender, marital status, etc.
   
3. **Location Dimension (Type 1 SCD):**
   - Attributes: Country name, country subregion, country region, etc.
   
4. **Promotion Dimension (Type 1 SCD):**
   - Attributes: Promotion name, subcategory, category, etc.
   
5. **Time Dimension (Type 0 SCD):**
   - Attributes: Year, quarter, month, day, etc.

## Implementation
- **Type 1 SCD (Promotion and Location Dimensions):** Changes overwrite existing values.
- **Type 2 SCD (Product and Customer Dimensions):** Changes are preserved historically, adding new records with effective dates while retaining validity periods of previous records.

## Benefits
The multi-dimensional model and Slowly Changing Dimensions (Type 1 and Type 2) enable the company to perform historical analysis, track changes, and understand business dynamics. By analyzing sales, customer behavior, product performance, and promotion effectiveness, the company can make informed decisions to optimize strategies.

This model allows the company to slice and dice data from different perspectives, such as analyzing sales by product, customer segment, promotion, and time period. Historical data helps identify trends, patterns, and correlations, leading to better insights for decision-making.

## Schema Creation and Data Integrity
### Establishing the Schema
Creating a robust schema is crucial, defining the structure of dimension and fact tables to ensure data organization and relationship maintenance. A well-designed schema is the foundation for accurate and efficient analysis.

### Dimension Table Schema
Each dimension table has a specific schema that aligns with its attributes. For example, the DimDate table schema includes time-related attributes such as dates, months, and quarters. Other dimension tables have schemas capturing their unique characteristics.

### Fact Table Schema
The FactSales table schema is designed to accommodate aggregated sales data and links to dimension tables. This schema enables multi-dimensional analysis, allowing exploration of sales insights from various perspectives.

### Data Integrity and Referential Integrity
Data integrity is vital. We enforce referential integrity through foreign key relationships between dimension and fact tables, ensuring data consistency and accurate maintenance across the data mart.

### Maintaining Data Quality
Establishing constraints and validation rules maintains data quality within the Sales Data Mart, minimizing errors, inconsistencies, and inaccuracies affecting analytical outcomes.

### Indexing for Performance
Indexing on frequently queried columns enhances data retrieval performance. Indexes are created on columns like customer IDs, product IDs, and dates, speeding up the process of retrieving specific data subsets.

## ETL Process
The ETL process involves three key stages:

### Extract
Data is extracted from the existing relational database, identifying relevant tables and fields holding sales-related information.

### Transform
Extracted data undergoes transformation to fit the dimensional model structure. This includes cleaning, filtering, aggregating, and formatting data for consistency and compatibility with the data mart.

### Load
Transformed data is loaded into the Sales Data Mart's dimension and fact tables, organizing it for efficient analysis.

We use PL/SQL procedures and SSIS for the ETL process.

## OLAP
Creating OLAP (Online Analytical Processing) cubes allows quick querying and analysis of data, especially for complex aggregations and calculations across multiple dimensions.

An OLAP cube overcomes relational database limitations by providing rapid data analysis. Cubes display and sum large data amounts, offering users searchable access to any data points.

## Conclusion
The successful execution of the Sales Data Mart Project underscores our technical proficiency in creating a robust data warehousing solution. Through meticulous dimensional modeling and adept ETL processes using PL/SQL procedures and SSIS, we've harnessed the power of structured data. Our carefully crafted schema, coupled with data integrity measures and strategic indexing, ensures efficient retrieval and reliability.

This project positions us to derive comprehensive insights from our sales analytics, supporting data-driven decision-making and technological innovation. As we move forward, our Sales Data Mart stands as a testament to our commitment to leveraging data for strategic advantage.

---
