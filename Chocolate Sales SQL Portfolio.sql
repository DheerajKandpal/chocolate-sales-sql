CREATE TABLE chocolate_sales (
    id SERIAL PRIMARY KEY,
    sales_person VARCHAR(100),
    country VARCHAR(100),
    product VARCHAR(100),
    sale_date DATE,
    amount DECIMAL(10, 2),
    boxes_shipped INT
);

-- For uploading the data from the MacBook to pgadmin4
COPY chocolate_sales(sales_person, country, product, sale_date, amount, boxes_shipped)
FROM '/Users/dheerajkandpal/Downloads/chocolate_sales_clean_fixed.csv'
DELIMITER ','
CSV HEADER;

-- Display the first 10 rows from the chocolate_sales table
SELECT * FROM chocolate_sales
LIMIT 10;

-- Check column names and data types in the chocolate_sales table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'chocolate_sales';

-- Calculate total revenue by each country
SELECT country, SUM(amount) AS total_revenue
FROM chocolate_sales
GROUP BY country
ORDER BY total_revenue DESC;

-- Identify the top 3 best-selling products by total sales amount
SELECT product, SUM(amount) AS total_sales
FROM chocolate_sales
GROUP BY product
ORDER BY total_sales DESC
LIMIT 3;

-- Generate monthly revenue trends using sale_date
SELECT TO_CHAR(sale_date, 'YYYY-MM') AS month, SUM(amount) AS revenue
FROM chocolate_sales
GROUP BY month
ORDER BY month;

-- Find the top-performing sales person based on total revenue
SELECT sales_person, SUM(amount) AS total_sales
FROM chocolate_sales
GROUP BY sales_person
ORDER BY total_sales DESC
LIMIT 1;

-- Calculate the average revenue earned per box shipped
SELECT ROUND(AVG(amount / boxes_shipped), 2) AS avg_revenue_per_box
FROM chocolate_sales;

-- Filter the sales data to only include transactions from India
SELECT *
FROM chocolate_sales
WHERE country = 'India';

-- Display total sales for each product in each country
SELECT country, product, SUM(amount) AS total_sales
FROM chocolate_sales
GROUP BY country, product
ORDER BY country, total_sales DESC;

-- Identify the month with the highest total revenue
SELECT TO_CHAR(sale_date, 'YYYY-MM') AS month, SUM(amount) AS revenue
FROM chocolate_sales
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

-- Analyze revenue trends per product over time
SELECT 
    product, 
    TO_CHAR(sale_date, 'YYYY-MM') AS month, 
    SUM(amount) AS monthly_revenue
FROM chocolate_sales
GROUP BY product, month
ORDER BY product, month;

-- Calculate each sales person's contribution to total revenue (as a percentage)
SELECT 
    sales_person,
    SUM(amount) AS total_sales,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM chocolate_sales), 2) AS revenue_share_percentage
FROM chocolate_sales
GROUP BY sales_person
ORDER BY total_sales DESC;

-- Identify products with average revenue per box greater than ₹500
SELECT product, ROUND(SUM(amount) / SUM(boxes_shipped), 2) AS avg_revenue_per_box
FROM chocolate_sales
GROUP BY product
HAVING SUM(amount) / SUM(boxes_shipped) > 500
ORDER BY avg_revenue_per_box DESC;

-- List the top-selling product in each country using window functions
SELECT country, product, total_sales
FROM (
    SELECT 
        country,
        product,
        SUM(amount) AS total_sales,
        RANK() OVER (PARTITION BY country ORDER BY SUM(amount) DESC) AS rank
    FROM chocolate_sales
    GROUP BY country, product
) ranked
WHERE rank = 1;


--Top 2 Products per Country by Revenue
SELECT country, product, total_sales
FROM (
    SELECT
        country,
        product,
        SUM(amount) AS total_sales,
        RANK() OVER (PARTITION BY country ORDER BY SUM(amount) DESC) AS rk
    FROM chocolate_sales
    GROUP BY country, product
) ranked
WHERE rk <= 2
ORDER BY country, rk;


--Salesperson Performance Ranking with Percentiles
SELECT
    sales_person,
    SUM(amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS rank,
    PERCENT_RANK() OVER (ORDER BY SUM(amount)) AS percentile
FROM chocolate_sales
GROUP BY sales_person
ORDER BY total_sales DESC;
