# sales-customer-financial-analysis-sql
SQL-based exploratory and financial analysis of transactional sales data using SQL Server.

## Overview
This project analyzes transactional sales data using SQL Server.
The goal is to explore the data, validate data quality, and generate core financial and customer insights that could support basic business reporting.
The analysis is done entirely in SQL using Microsoft SQL Server Management Studio (SSMS).

---
## Dataset
The project uses three tables loaded from CSV files:
- Customers (customer attributes and demographics)
- Products (product details and cost information)
- Sales (transaction-level sales data)

These tables follow a simple star-schema style structure with a sales fact table and dimension tables.

---

## Objectives
- Check data quality and identify missing or invalid values
- Explore customers, products, and sales distributions
- Analyze revenue, quantity sold, and customer behavior
- Perform time-based analysis (monthly and yearly trends)
- Build clear, reusable SQL queries for reporting purposes

---

## Tools Used
- SQL Server (SSMS)
- T-SQL (CTEs, window functions, aggregations)

---

## Key Analyses
- Data quality checks (null values, invalid quantities, revenue impact)
- Exploratory data analysis on customers, products, and sales
- Revenue and customer trend analysis over time
- Customer and product segmentation
- Ranking and year-over-year performance analysis

---

## Project Structure
- `data/` contains the raw CSV files
- `sql/` contains SQL scripts organized by analysis stage:
  - Data exploration and quality checks
  - Financial and customer analysis

---

## Scope
This project focuses on backend analytics using SQL.
Visualization and dashboarding are planned as a future extension.
