# House Price Paid Data Pipeline

## Project Summary

This project is a PostgreSQL-based ELT data pipeline built using the UK House Price Paid dataset (1995 to present).
It was created to practise and demonstrate core junior data engineering skills, including data modelling, SQL transformations,
and working with containerised databases.

The pipeline ingests raw property transaction data, structures it into a relational schema, and exposes analytical views
that can be queried directly or used in BI tools such as Power BI.

---

## What This Project Demonstrates

- Building a data pipeline using PostgreSQL and SQL
- Loading raw data into a staging schema
- Designing a normalised data model with dimension and fact tables
- Using year-based partitioning for scalable time-series data
- Writing idempotent load logic using ON CONFLICT
- Creating reusable SQL views for analysis and reporting
- Running PostgreSQL in a Docker container for reproducibility

---

## Pipeline Overview

The pipeline follows an ELT (Extract, Load, Transform) pattern:

1. Extract  
   Raw CSV files are loaded into a staging schema called raw_house_data without modification.

2. Load  
   Data is inserted into cleaned and normalised tables in the house_data schema.

3. Transform  
   SQL views calculate analytical metrics such as median prices and transaction counts.

All transformations are performed inside PostgreSQL using SQL.

---

## Data Model

### Schemas

raw_house_data  
Contains raw, untransformed data exactly as it appears in the source CSV files.

house_data  
Contains the cleaned and structured warehouse tables, including:
- counties
- districts
- property types
- tenures
- a partitioned fact table for house sales

### Fact Table

house_data.house_price_paid
- Partitioned by year on the date column
- Composite primary key (sale_id, date) to support safe re-runs
- Designed for time-based and regional analysis

---



## How to Run the Pipeline

Requirements:
- Docker Desktop
- VS Code with the PostgreSQL extension
- House Price Paid CSV files placed in the data directory

Start PostgreSQL:
docker compose up -d

Run the SQL scripts in the following order using the VS Code PostgreSQL extension:

- 99_reset.sql (optional, development only)
- 00_schema.sql
- 01_extract.sql
- 02_load.sql
- 03_transformation_views.sql

---

## Analytics

The pipeline exposes SQL views that provide:
- median house prices by year
- median prices by district and county
- sale counts over time
- monthly district-level median price rankings

### Monthly Median Price Rankings (Window Functions)

A dedicated analytical view calculates the **monthly median house price per district** and ranks districts **within each calendar month**.

This view demonstrates:
- use of a CTE
- use of `PERCETILE_CONT` to calculate medians
- correct year–month grouping using `DATE_TRUNC('month', date)`
- SQL window functions (`DENSE_RANK`) for intra-month ranking
- reusable view-based transformations for downstream analytics

Example use cases include identifying:
- the most expensive and most affordable districts each month
- relative price changes over time
- ranked outputs suitable for visualisation tools such as Power BI

### Power BI Report

The analytical views produced by this pipeline are used in a Power BI report stored in the project repository.

The report includes:

a market overview showing long-term national house price trends and transaction volumes

district-level affordability comparisons for a selected year

monthly district price rankings based on SQL window functions

The Power BI report connects to the database using Import mode and reflects the latest available data at refresh time.

Dashboard screenshots for each report page are available in the 'powerbi/Screenshots' directory

Note: Recent years may not include all months due to publication and registration delays in HM Land Registry data.
---

## Design Notes

- The pipeline is designed to be re-runnable without duplicating data
- Partitioning is used to keep queries performant as the dataset grows
- Raw data is preserved separately from transformed data to maintain traceability
- Large CSV files are intentionally excluded from version control

---

## Future Improvements

- Python scripts to automatically download and incrementally load new House Price Paid data from the UK government website
- Basic data quality checks such as row counts, null checks, and duplicate detection
- Automated execution of pipeline steps

---

## Author

Reiss Allen-Smith  
Computer Science Graduate | Aspiring Data Engineer
