-- Online Retail II: Sales Analysis
-- Database: PostgreSQL
-- Dataset: UCI Online Retail II

-- DATA PREPARATION
-- Create tables and combine datasets

CREATE TABLE retail_2009_2010 (
	invoice VARCHAR(20),
	stock_code VARCHAR(20),
	description TEXT,
	quantity INTEGER,
	invoice_date TIMESTAMP,
	price NUMERIC(10, 2),
	customer_id NUMERIC(10, 0),
	country VARCHAR(100)
);

CREATE TABLE retail_2010_2011 (
	invoice VARCHAR(20),
    stock_code VARCHAR(20),
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    price NUMERIC(10, 2),
    customer_id NUMERIC(10, 0),
    country VARCHAR(100)
);

-- Combine sales data from both years into one view
CREATE VIEW retail_all AS
SELECT * 
FROM retail_2009_2010

UNION ALL 

SELECT *
FROM retail_2010_2011;

SELECT COUNT(*)
FROM retail_all;


-- DATASET OVERVIEW

-- 1. Dataset Overview
-- Check the total number of records and unique values

SELECT
	COUNT(*) AS total_rows,
	COUNT(DISTINCT invoice) AS unique_invoices,
	COUNT(DISTINCT stock_code) AS unique_products,
	COUNT(DISTINCT customer_id) AS unique_customers,
	COUNT(DISTINCT country) AS unique_countries
FROM retail_all;

-- 2. Check the data range of the dataset
-- Identify the earliest and latest transaction dates

SELECT 
	MIN(invoice_date) AS first_transaction,
	MAX(invoice_date) AS last_transaction
FROM retail_all;


-- DATA QUALITY AND CLEANING

-- 3. Check missing values
-- Identify missing values in important columns

SELECT
    COUNT(*) FILTER (WHERE invoice IS NULL) AS missing_invoice,
    COUNT(*) FILTER (WHERE stock_code IS NULL) AS missing_stock_code,
    COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE invoice_date IS NULL) AS missing_date,
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country
FROM retail_all;

-- 4. Check negative and zero quantities
-- Identify potential returns and unusual transaction records

SELECT
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_quantity,
    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity,
    COUNT(*) FILTER (WHERE price < 0) AS negative_price,
    COUNT(*) FILTER (WHERE price = 0) AS zero_price
FROM retail_all;

-- 5. Inspect records with negative prices
-- Identify transactions with unusual negative prices

SELECT *
FROM retail_all
WHERE price < 0;

-- 6. Inspect transactions with negative quantities
-- Examine potential product returns and cancellations

SELECT *
FROM retail_all
WHERE quantity < 0
LIMIT 10;

-- 7. Identify cancellation invoices
-- Count invoices with a C prefix

SELECT 
	COUNT(*) AS cancellation_records,
	COUNT(DISTINCT invoice) as cancellation_invoices
FROM retail_all
WHERE invoice LIKE 'C%';

-- 8. Compare negative quantities and cancellation invoices
-- Identify negative-quantity records with and without a C prefix

SELECT 
	CASE 
		WHEN invoice LIKE 'C%' THEN 'Cancellation (C prefix)'
		ELSE 'No C prefix'
	END AS transaction_type,
	COUNT(*) AS total_records
FROM retail_all
WHERE quantity < 0
GROUP BY transaction_type;

-- 9. Inspect negative quantities without a C prefix
-- Examine transactions that may represent returns or adjustments

SELECT *
FROM retail_all
WHERE quantity < 0
AND invoice NOT LIKE 'C%'
LIMIT 10;

-- 10. Analyze negative quantities without a C prefix
-- Check their price values and missing customer IDs

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE price = 0) AS zero_price_records,
    COUNT(*) FILTER (WHERE price > 0) AS positive_price_records,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_ids
FROM retail_all
WHERE quantity < 0
  AND invoice NOT LIKE 'C%';

-- 11. Investigate zero-price transactions
-- Identify the most common product descriptions with zero prices

SELECT
    description,
    COUNT(*) AS total_records
FROM retail_all
WHERE price = 0
GROUP BY description
ORDER BY total_records DESC
LIMIT 15;

-- 12. Analyze zero-price transactions by quantity
-- Compare positive and negative quantities with zero prices

SELECT
    CASE
        WHEN quantity > 0 THEN 'Positive quantity'
        WHEN quantity < 0 THEN 'Negative quantity'
        ELSE 'Zero quantity'
    END AS quantity_type,
    COUNT(*) AS total_records
FROM retail_all
WHERE price = 0
GROUP BY quantity_type
ORDER BY total_records DESC;

-- 13. Inspect positive quantities with zero prices
-- Investigate potentially free products or promotional items

SELECT *
FROM retail_all
WHERE price = 0
  AND quantity > 0
LIMIT 15;

-- 14. Check missing descriptions in zero-price transactions
-- Determine how many zero-price records lack product descriptions

SELECT
    COUNT(*) AS zero_price_records,
    COUNT(*) FILTER (
        WHERE description IS NULL
    ) AS missing_descriptions,
    COUNT(*) FILTER (
        WHERE description IS NOT NULL
    ) AS available_descriptions
FROM retail_all
WHERE price = 0;

-- 15. Create a cleaned sales view
-- Keep regular sales transactions with positive quantities and prices

CREATE VIEW clean_sales AS
SELECT *
FROM retail_all
WHERE quantity > 0
  AND price > 0
  AND invoice NOT LIKE 'C%';

-- Check the number of records in the cleaned sales view

SELECT COUNT(*) AS total_clean_sales
FROM clean_sales;


-- SALES PERFORMANCE ANALYSIS

-- 16. Calculate overall sales revenue
-- Calculate revenue using quantity multiplied by unit price

SELECT
    SUM(quantity * price) AS total_revenue,
    SUM(quantity) AS total_items_sold,
    COUNT(DISTINCT invoice) AS total_invoices
FROM clean_sales;

-- 17. Analyze annual sales performance
-- Compare revenue and sales volume by year

SELECT
    EXTRACT(YEAR FROM invoice_date) AS sales_year,
    SUM(quantity * price) AS total_revenue,
    SUM(quantity) AS total_items_sold,
    COUNT(DISTINCT invoice) AS total_invoices
FROM clean_sales
GROUP BY sales_year
ORDER BY sales_year;

-- 18. Analyze monthly sales trends
-- Calculate revenue, items sold, and invoices by month

SELECT
    DATE_TRUNC('month', invoice_date)::DATE AS sales_month,
    SUM(quantity * price) AS total_revenue,
    SUM(quantity) AS total_items_sold,
    COUNT(DISTINCT invoice) AS total_invoices
FROM clean_sales
GROUP BY sales_month
ORDER BY sales_month;

-- 19. Rank months by total revenue
-- Identify the highest and lowest revenue months

SELECT
    DATE_TRUNC('month', invoice_date)::DATE AS sales_month,
    SUM(quantity * price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(quantity * price) DESC
    ) AS revenue_rank
FROM clean_sales
GROUP BY sales_month
ORDER BY revenue_rank;


-- PRODUCT ANALYSIS

-- 20. Identify the top 10 products by quantity sold
-- Rank products based on total units sold

SELECT
	stock_code,
	description,
	SUM(quantity) AS total_quantity_sold,
	SUM(quantity * price) AS total_revenue,
	COUNT(DISTINCT invoice) AS total_invoices
FROM clean_sales
GROUP BY stock_code, description
ORDER BY total_quantity_sold DESC
LIMIT 10;	

-- 21. Identify the top 10 products by revenue
-- Rank products based on total revenue

SELECT
    stock_code,
    description,
    SUM(quantity * price) AS total_revenue,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT invoice) AS total_invoices
FROM clean_sales
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;


-- CUSTOMER ANALYSIS

-- 22. Analyze customer data
-- Count customers and transactions with missing customer IDs

SELECT
	COUNT(*) AS total_records,
	COUNT(customer_id) AS records_with_customer_id,
	COUNT(*) FILTER (
		WHERE customer_id IS NULL
	) AS records_without_customer_id, 
	COUNT(DISTINCT customer_id) AS unique_customers,
	SUM(quantity * price) FILTER (
		WHERE customer_id IS NOT NULL
		) AS revenue_from_identified_customers
from clean_sales;

-- 23. Identify the top 10 customers by revenue
-- Rank customers based on their total spending

SELECT
	customer_id,
	COUNT(DISTINCT invoice) AS total_invoices,
	SUM(quantity) AS total_items_purchased,
	SUM(quantity * price) AS total_revenue
FROM clean_sales
WHERE customer_id IS NOT NULL
GROUP By customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- GEOGRAPHIC ANALYSIS

-- 24. Analyze sales performance by country
-- Compare revenue, items sold, and invoices across countries

SELECT
	country,
	COUNT(DISTINCT invoice) AS total_invoices,
	SUM(quantity) AS total_items_sold,
	SUM(quantity * price) AS total_revenue
FROM clean_sales
GROUP BY country
ORDER BY total_revenue DESC;


-- CUSTOMER ANALYSIS

-- 25. Calculate Average Order Value (AOV)
-- Measure the average revenue generated per invoice

SELECT
	COUNT(DISTINCT invoice) AS total_invoices,
	SUM(quantity * price) AS total_revenue,
	ROUND(
		SUM(quantity * price) / COUNT(DISTINCT invoice),
		2
	) AS average_order_value
FROM clean_sales;


-- REVENUE CONTRIBUTION

-- 26. Calculate revenue contribution from the top 10 products
-- Compare top product revenue with total sales revenue

WITH product_revenue AS (
    SELECT
        stock_code,
        description,
        SUM(quantity * price) AS total_revenue
    FROM clean_sales
    GROUP BY stock_code, description
),
top_products AS (
    SELECT *
    FROM product_revenue
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT
    SUM(total_revenue) AS top_10_product_revenue,
    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(quantity * price) FROM clean_sales),
        2
    ) AS revenue_percentage
FROM top_products


-- CUSTOMER ANALYSIS

-- 27. Calculate revenue contribution from the top 10 customers
-- Compare top customer revenue with total identified customer revenue

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(quantity * price) AS total_revenue
    FROM clean_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
top_customers AS (
    SELECT *
    FROM customer_revenue
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT
    SUM(total_revenue) AS top_10_customer_revenue,
    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(quantity * price)
         FROM clean_sales
         WHERE customer_id IS NOT NULL),
        2
    ) AS revenue_percentage
FROM top_customers;

-- 28. Analyze customer purchase frequency
-- Group customers based on the number of invoices

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS total_invoices,
        SUM(quantity * price) AS total_revenue
    FROM clean_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        CASE
            WHEN total_invoices = 1 THEN 'One-time customers'
            WHEN total_invoices BETWEEN 2 AND 5 THEN 'Repeat customers'
            ELSE 'Frequent customers'
        END AS customer_segment,
        total_revenue
    FROM customer_orders
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(total_revenue) FROM customer_segments),
        2
    ) AS revenue_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;


-- GEOGRAPHIC ANALYSIS

-- 29. Analyze monthly sales trends by top 5 countries
-- Compare monthly revenue across the five highest-revenue countries

WITH top_countries AS (
    SELECT
        country
    FROM clean_sales
    GROUP BY country
    ORDER BY SUM(quantity * price) DESC
    LIMIT 5
)
SELECT
    country,
    DATE_TRUNC('month', invoice_date)::DATE AS sales_month,
    SUM(quantity * price) AS monthly_revenue
FROM clean_sales
WHERE country IN (
    SELECT country
    FROM top_countries
)
GROUP BY
    country,
    sales_month
ORDER BY
    country,
    sales_month;