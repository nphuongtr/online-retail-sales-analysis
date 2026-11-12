# Online Retail Sales Analysis (PostgreSQL & Power BI)

## Project Overview

This project analyzes the Online Retail II dataset using PostgreSQL and Power BI to evaluate sales performance, product trends, customer behavior, and geographic patterns.

The goal is to transform raw retail transaction data into meaningful business insights through SQL querying, data cleaning, exploratory analysis, and interactive data visualization.

## Dataset

- **Source:** [UCI Machine Learning Repository – Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
- **Time Period:** December 2009 – December 2011
- **Original Records:** 1,067,371
- **Unique Invoices:** 53,628
- **Unique Products:** 5,305
- **Unique Customers:** 5,942 (excluding missing customer IDs)
- **Countries:** 43

## Tools & Technologies

- **PostgreSQL 18** – Data cleaning, querying, and analysis
- **pgAdmin 4** – Database management and SQL execution
- **Power BI** – Sales dashboard and data visualization
- **Microsoft Excel / CSV** – Data storage and export

## Data Cleaning

The original dataset was cleaned to prepare it for sales analysis.

- Excluded transactions with zero or negative quantities.
- Excluded transactions with zero or negative prices.
- Excluded cancellation invoices beginning with "C".
- Created a cleaned sales view (`clean_sales`) for analysis.

After cleaning, the dataset contained **1,041,652 records**.

## Key Business Metrics

Based on the cleaned dataset:

| Metric | Result |
|---|---:|
| Total Revenue | £20,972,594.55 |
| Total Items Sold | 11,420,287 |
| Unique Invoices | 40,077 |
| Average Order Value | £523.31 |
| Countries | 43 |

## Analysis Areas

1. Overall sales performance
2. Monthly sales trends
3. Product performance and revenue contribution
4. Customer behavior and purchasing frequency
5. Geographic sales analysis
6. Customer and revenue concentration
7. Business insights and recommendations

## Power BI Dashboard

The interactive sales dashboard presents:

- Total revenue
- Total invoices
- Total items sold
- Monthly sales revenue trends
- Monthly invoice trends
- Monthly items sold trends

A PDF export of the dashboard is included in this repository.

## Project Structure

- `README.md` – Project overview, methodology, and key metrics
- `retail_analysis.sql` – SQL queries used throughout the analysis
- `monthly_sales.csv` – Monthly sales data exported from PostgreSQL for Power BI
- `Online_Retail_Sales_Dashboard.pdf` – Power BI dashboard export
- `business_insights.md` – Detailed findings, interpretations, and business recommendations

## Conclusion

This project demonstrates practical data analytics skills, including SQL data cleaning, exploratory data analysis, business performance evaluation, and data visualization.

The findings provide insights into sales trends, customer purchasing behavior, product performance, and geographic revenue distribution. These insights can help support business decisions related to customer retention, inventory management, and market expansion.