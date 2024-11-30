-- 1. Find Top 10 Highest Revenue Generating Products
-- Question: Find top 10 highest revenue generating products
SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- 2. Find Top 5 Highest Selling Products in Each Region
-- Question: Find top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;

-- 3. Month-over-Month Growth Comparison for 2022 and 2023 Sales (e.g., Jan 2022 vs Jan 2023)
-- Question: Find month over month growth comparison for 2022 and 2023 sales (e.g., Jan 2022 vs Jan 2023)
WITH cte AS (
    SELECT EXTRACT(YEAR FROM order_date) AS order_year,
           EXTRACT(MONTH FROM order_date) AS order_month,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- 4. For Each Category, Which Month Had the Highest Sales
-- Question: For each category, which month had highest sales?
WITH cte AS (
    SELECT category, TO_CHAR(order_date, 'YYYYMM') AS order_year_month, 
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;

-- 5. Which Subcategory Had the Highest Growth by Profit in 2023 Compared to 2022
-- Question: Which subcategory had highest growth by profit in 2023 compared to 2022?
WITH cte AS (
    SELECT sub_category, EXTRACT(YEAR FROM order_date) AS order_year,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
),
cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT *,
       (sales_2023 - sales_2022) AS growth
FROM cte2
ORDER BY growth DESC
LIMIT 1;
