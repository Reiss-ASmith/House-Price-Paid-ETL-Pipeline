# House Price Paid Data Pipeline

## Project Summary

This project is a PostgreSQL-based ELT data pipeline built using the UK Land Registry House Price Paid dataset (1995 to present), with support for both full historical loads and monthly incremental updates.

It was created to practise and demonstrate core junior data engineering skills, including Python-based orchestration, bulk data loading, SQL transformations, schema design, operational logging, and analytics consumption via Power BI.

The pipeline ingests raw property transaction data, structures it into a relational schema, and exposes analytical views that are consumed by a Power BI dashboard.

---

## What This Project Demonstrates

- Building an ELT data pipeline using Python and PostgreSQL
- High-volume bulk loading using PostgreSQL COPY
- Loading raw data into a dedicated staging schema
- Designing a normalised data model with dimension and fact tables
- Using year-based partitioning for scalable time-series data
- Writing idempotent load logic using ON CONFLICT
- Handling both full historical loads and monthly incremental updates
- Creating reusable SQL views for analysis and reporting
- Consuming PostgreSQL views in Power BI to build analytical dashboards
- Structured logging to console and file for observability
- Running PostgreSQL in a Docker container for reproducibility

---

## Pipeline Overview

The pipeline follows an ELT (Extract, Load, Transform) pattern:

1. Extract  
   Python scripts download the full historical dataset and monthly update files and write them to a local data directory.

2. Load  
   Raw CSV data is loaded into PostgreSQL using COPY. Separate raw landing tables are used for full and monthly loads before inserting into cleaned and normalised core tables.

3. Transform  
   SQL views calculate analytical metrics such as median prices and transaction counts.

4. Analyse  
   Power BI connects directly to PostgreSQL and consumes the analytical views to produce dashboards.

All transformations are performed inside PostgreSQL using SQL.

---

## Data Model

### Schemas

raw_house_data  
Contains raw, untransformed data exactly as it appears in the source CSV files. Separate landing tables are used for full and monthly loads.

house_data  
Contains the cleaned and structured warehouse tables, including:
- counties
- districts
- property types
- tenures
- a partitioned fact table for house price transactions

---

### Fact Table

house_data.house_price_paid
- Partitioned by year on the date column
- Composite primary key (sale_id, date) to support partitioning and safe re-runs
- Designed for time-based and regional analysis

---

## How to Run the Pipeline

Requirements:
- Docker Desktop
- Python 3.x (virtual environment recommended)
- VS Code with the PostgreSQL extension
- Power BI Desktop (optional, for dashboard)

Start PostgreSQL:
docker compose up -d

Run the pipeline:
python main.py

You will be prompted to choose between:
- a full historical load
- a monthly update
- a database reset (development only)

---

## Logging & Observability

The pipeline uses structured logging:
- logs are written to the console during execution
- logs are also written to logs/pipeline.log

Logs record pipeline stages, data load steps, SQL execution, and failures, making long-running operations easier to monitor and debug.

---

## Analytics

The pipeline exposes SQL views that provide:
- median house prices by year
- median prices by district and county
- transaction counts over time

These views are consumed directly by **Power BI**, which is used to create an interactive dashboard for exploring UK house price trends.

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

Dashboard screenshots for each report page are available in the `powerbi/Screenshots` directory

Note: Recent years may not include all months due to publication and registration delays in HM Land Registry data.
---

## Design Notes

- The pipeline is designed to be re-runnable without duplicating data
- Full loads use TRUNCATE + COPY for predictable development runs
- Monthly updates use a dedicated raw landing table
- Core tables enforce uniqueness using ON CONFLICT
- Partitioning keeps queries performant as the dataset grows
- Raw data is preserved separately from transformed data to maintain traceability
- Large CSV files are intentionally excluded from version control

---

## Future Improvements

- Deploy the pipeline to a cloud-hosted PostgreSQL database (Azure)
- Automate monthly updates using GitHub Actions
- Migrate analytics layer to Microsoft Fabric

---

## Data Attribution
Contains HM Land Registry data © Crown copyright and database right 2021. This data is licensed under the Open Government Licence v3.0.

## Author

Reiss Allen-Smith  
Computer Science Graduate | Aspiring Data Engineer