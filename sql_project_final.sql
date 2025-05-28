-- SQL PROJECT
create database superstore_data;  -- created a database

use superstore_data; -- selected the database

DESCRIBE superstore_table; -- imported a csv file directly

UPDATE superstore_table 
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y');


UPDATE superstore_table 
SET `Ship Date` = STR_TO_DATE(`Ship Date`, '%m/%d/%Y');

-- Rename columns with spaces and modify datatype

ALTER TABLE superstore_table   
CHANGE COLUMN `Row ID` row_id INT,
CHANGE COLUMN `Order ID` order_id VARCHAR(50),
CHANGE COLUMN `Order Date` order_date DATE,
CHANGE COLUMN `Ship Date` ship_date DATE,
CHANGE COLUMN `Ship Mode` ship_mode VARCHAR(50),
CHANGE COLUMN `Customer ID` customer_id VARCHAR(50),
CHANGE COLUMN `Customer Name` customer_name VARCHAR(100),
CHANGE COLUMN `Postal Code` postal_code INT,
CHANGE COLUMN `Product ID` product_id VARCHAR(50),
CHANGE COLUMN `Sub-Category` sub_category VARCHAR(50),
CHANGE COLUMN `Product Name` product_name VARCHAR(150),

-- Just modify datatype for columns without spaces
MODIFY COLUMN `Segment` VARCHAR(50),
MODIFY COLUMN `Country` VARCHAR(50),
MODIFY COLUMN `City` VARCHAR(50),
MODIFY COLUMN `State` VARCHAR(50),
MODIFY COLUMN `Region` VARCHAR(50),
MODIFY COLUMN `Category` VARCHAR(50),
MODIFY COLUMN `Sales` DOUBLE,
MODIFY COLUMN `Quantity` INT,
MODIFY COLUMN `Discount` DOUBLE,
MODIFY COLUMN `Profit` DOUBLE;

SELECT * FROM superstore_table;

DESCRIBE superstore_table;

-- now we'll perform some EDA 
SELECT DISTINCT Region FROM superstore_table;
SELECT DISTINCT Segment FROM superstore_table;
SELECT DISTINCT Category FROM superstore_table;
SELECT DISTINCT ship_mode FROM superstore_table;

-- Orders from the 'West' region
SELECT * FROM superstore_table WHERE region = 'West';

-- Orders with sales greater than 500
SELECT * FROM superstore_table WHERE sales > 500;

-- Orders where discount is more than 0
SELECT * FROM superstore_table WHERE discount > 0;

-- Highest sales first
SELECT * FROM superstore_table ORDER BY sales DESC;

-- Most profitable orders first
SELECT * FROM superstore_table ORDER BY profit DESC;

-- highest sold products (top 10)

SELECT product_name,sales FROM superstore_table ORDER BY sales DESC LIMIT 10 ;

-- top selling states (top 10)

SELECT state, SUM(sales) AS total_sales
FROM superstore_table
GROUP BY state
ORDER BY total_sales DESC
LIMIT 10;

-- sales with respect to segment
SELECT segment, SUM(sales) 
FROM superstore_table 
GROUP BY segment;

-- sales with respect to category
SELECT category, SUM(sales) 
FROM superstore_table GROUP BY category;

-- Bottom 5 profit values (most loss-making orders)
SELECT * FROM superstore_table ORDER BY profit ASC LIMIT 5;

-- Top 10 orders by sales in the 'Central' region
SELECT * 
FROM superstore_table 
WHERE region = 'Central' 
ORDER BY sales DESC 
LIMIT 10;

-- Year-wise sales
SELECT YEAR(Order_Date) AS year, SUM(sales)
FROM superstore_table
GROUP BY year;

-- Month-wise profit
SELECT MONTH(Order_Date) AS month,
 SUM(profit)
FROM superstore_table
GROUP BY month
ORDER BY month ASC;

-- Most profitable
SELECT product_name, SUM(profit) AS total_profit
FROM superstore_table
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

-- Least profitable
SELECT product_name, SUM(profit) AS total_profit
FROM superstore_table
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;

-- filtering and conditional queries 
-- Orders from 'West' region AND segment 'Consumer'
SELECT * 
FROM superstore_table 
WHERE region = 'West' AND segment = 'Consumer';

-- Orders from 'East' region OR with sales > 1000
SELECT * 
FROM superstore_table 
WHERE region = 'East' OR sales > 1000;

-- Customers whose names start with 'A'
SELECT * 
FROM superstore_table 
WHERE customer_name LIKE 'A%';

-- Product names containing the word "Book"
SELECT * 
FROM superstore_table 
WHERE product_name LIKE '%Book%';

-- Orders from specific states
SELECT * 
FROM superstore_table 
WHERE state IN ('California', 'Texas', 'New York');

-- Orders where sales is between 500 and 1000
SELECT * 
FROM superstore_table 
WHERE sales BETWEEN 500 AND 1000;

-- Orders where order date is between two specific dates
SELECT * 
FROM superstore_table 
WHERE order_date BETWEEN '2016-01-01' AND '2017-12-31';

-- Specific Staes where category is office supplies 
SELECT * FROM superstore_table 
WHERE State IN ('Arizona','Washington') 
AND Category = 'Office Supplies';

-- product between specific discounts

SELECT * FROM superstore_table 
WHERE Discount BETWEEN 0.1 AND 0.3;

-- Aggregations and Grouping
-- orders by city
SELECT City,COUNT(order_id) AS orders_per_city 
FROM superstore_table GROUP BY City ;
-- category wise avg profits
SELECT Category,avg(profit) AS avg_profits 
FROM superstore_table GROUP BY Category;

-- max,min and avg  discount per sub-catg
SELECT sub_category ,max(Discount) AS max_discount ,
 min(Discount) AS min_discount 
 ,avg(Discount) AS avg_discount
FROM superstore_table GROUP BY sub_category;

-- profit per segment 

SELECT Segment,sum(profit) AS total_profits,
avg(profit) AS avg_profits 
FROM superstore_table GROUP BY Segment;
-- sales per category
SELECT Category,sum(sales) AS total_sales,
avg(sales) AS avg_sales
FROM superstore_table GROUP BY Category;

-- product wise sales
SELECT product_name,sum(sales) AS total_sales,
avg(sales) AS avg_sales
FROM superstore_table GROUP BY product_name;

-- top 5 products by total sales 
SELECT product_name,sum(sales) AS total_sales
FROM superstore_table GROUP BY product_name
ORDER BY total_sales DESC LIMIT 5;

-- creating new tables to perform joins

CREATE TABLE customers_table AS
SELECT DISTINCT customer_id, customer_name, segment
FROM superstore_table;

CREATE TABLE products_table AS
SELECT DISTINCT product_id, product_name, category, sub_category
FROM superstore_table;

CREATE TABLE orders_table AS
SELECT order_id, order_date, ship_date, 
ship_mode, customer_id, product_id,
sales, quantity, discount, profit
FROM superstore_table;

-- 1. INNER JOIN: Customers who placed at least one order
SELECT * 
FROM customers_table
INNER JOIN orders_table 
ON customers_table.customer_id = orders_table.customer_id;

-- 2. LEFT JOIN: Show all customers and their orders (if any)
SELECT * 
FROM customers_table AS c
LEFT JOIN orders_table AS o 
ON c.customer_id = o.customer_id;

-- 3. RIGHT JOIN: Show all orders with customer details (if customer exists)
SELECT * 
FROM orders_table AS o
RIGHT JOIN customers_table AS c 
ON o.customer_id = c.customer_id;

-- 4. LEFT JOIN: Only selected columns – customers and their order info
SELECT c.customer_id, c.customer_name, o.order_id, o.sales
FROM customers_table AS c
LEFT JOIN orders_table AS o 
ON c.customer_id = o.customer_id;

-- 5. INNER JOIN: Orders and their product details (only ordered products)
SELECT o.order_id, o.product_id, p.product_name, p.category, o.sales
FROM orders_table AS o
INNER JOIN products_table AS p 
ON o.product_id = p.product_id;

-- 6. LEFT JOIN: All customers, their orders, and matching product details (if any)
SELECT c.customer_name, o.customer_id, p.product_name
FROM customers_table AS c
LEFT JOIN orders_table AS o 
ON c.customer_id = o.customer_id
LEFT JOIN products_table AS p 
ON o.product_id = p.product_id;

-- FULL OUTER JOIN simulation: Combine LEFT JOIN and RIGHT JOIN results using UNION
-- This returns all customers and all orders,
-- showing matching rows where customer_id is the same,
-- and includes unmatched rows from both tables with NULLs for missing matches.
SELECT 
    c.customer_id, 
    c.customer_name, 
    o.order_id, 
    o.sales, 
    o.order_date
FROM customers_table AS c
LEFT JOIN orders_table AS o
ON c.customer_id = o.customer_id

UNION

SELECT 
    c.customer_id, 
    c.customer_name, 
    o.order_id, 
    o.sales, 
    o.order_date
FROM customers_table AS c
RIGHT JOIN orders_table AS o
ON c.customer_id = o.customer_id;

-- DATE FUNCTIONS

-- Extract year and month, sum sales per month
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sales) AS total_sales
FROM orders_table
GROUP BY order_year, order_month;

-- Calculate shipping time (days)
SELECT order_id, DATEDIFF(ship_date, order_date) AS shipping_days
FROM orders_table;

-- Filter orders placed in 2015
SELECT *
FROM orders_table
WHERE YEAR(order_date) = 2015;

-- GETTING WHICH YEAR HAS MOST ORDERS
SELECT YEAR(order_date) AS order_year,
COUNT(order_id) AS total_orders,
SUM(quantity) as total_quantity
FROM orders_table 
GROUP BY  order_year
ORDER BY total_orders DESC ;
-- orders by month and year
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, COUNT(order_id)
FROM orders_table
GROUP BY year, month;
-- orders between 1 jan 2016 to 31 dec 2026
SELECT order_id,product_id,quantity,order_date FROM 
orders_table WHERE order_date BETWEEN '2016-01-01' AND '2016-12-31';
-- Data Cleaning and Transformation
SELECT order_id,profit,
    CASE
        WHEN profit > 100 THEN 'High'
        WHEN profit BETWEEN 10 AND 100 THEN 'Medium'
        ELSE 'Low'
    END AS profit_classification
FROM orders_table;

SELECT order_date,ship_date ,
CASE WHEN DATEDIFF(ship_date,order_date)<=2 THEN 'FAST' 
WHEN DATEDIFF(ship_date,order_date) BETWEEN 3 AND 5  THEN 'SLOW'
ELSE 'DELAYED'
END AS shippig_status
FROM orders_table
;

SELECT 
    order_id,
    sales,
    profit,
    (profit / sales) AS profit_margin
FROM orders_table
WHERE sales > 0;  -- to avoid division by zero

-- Adding Primary key in customers
ALTER TABLE customers_table
ADD PRIMARY KEY (customer_id);

-- Adding Foreign key in orders
ALTER TABLE orders_table
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers_table(customer_id);

-- GETTING WITH THE VIEWS
 CREATE VIEW customer_sales_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers_table AS c
JOIN orders_table AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- prodct performance view

 CREATE VIEW products_performance AS 
SELECT p.product_id,p.product_name,
 COUNT(o.order_id) AS total_orders,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.sales) AS total_sales 
FROM products_table AS p 
JOIN
orders_table AS o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

-- Show total sales, total profit, and total orders per month and year as view .
CREATE VIEW monthly_sales_summary AS
SELECT YEAR(order_date) AS sale_year ,MONTH(order_date) AS sale_month,
sum(sales) AS total_sales ,sum(profit) AS total_profit ,
count(order_id) AS total_orders
FROM orders_table
GROUP BY sale_year,sale_month;

-- CTE'S
WITH customer_summary AS (
    SELECT customer_id, COUNT(order_id) AS order_count, SUM(sales) AS total_sales
    FROM orders_table
    GROUP BY customer_id
)
SELECT *
FROM customer_summary
WHERE order_count > 3 AND total_sales > 10000;

WITH product_summary AS (
    SELECT 
        product_id,
        SUM(sales) AS total_sales,
        COUNT(order_id) AS total_orders
    FROM orders_table
    GROUP BY product_id
)
SELECT *
FROM product_summary
WHERE total_sales > 5000 AND total_orders > 5;

-- adding region in customer table from superstore table

ALTER TABLE customers_table
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(100);

UPDATE customers_table AS c
JOIN superstore_table AS s ON c.customer_id = s.customer_id
SET 
    c.city = s.City,
    c.state = s.State;
    -- Monthly Region-Wise Sales Summary
-- Shows total sales per city for each month and year to identify high-performing regions over time
WITH monthly_region_sales AS (
    SELECT 
        c.city,
        MONTH(o.order_date) AS order_month,
        YEAR(o.order_date) AS order_year,
        SUM(o.sales) AS total_sales
    FROM orders_table o
    JOIN customers_table c ON o.customer_id = c.customer_id
    GROUP BY c.city, YEAR(o.order_date), MONTH(o.order_date)
) SELECT *
FROM monthly_region_sales
ORDER BY total_sales DESC;
--   using window function
-- 1️⃣ ROW NUMBER: Gives a serial number for each order per customer by date
SELECT 
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_num
FROM 
    orders_table;



-- 2️⃣ RANK: Ranks sales per customer (with gaps for ties)
SELECT 
    Order_ID, 
    Customer_ID, 
    Sales,
    RANK() OVER (PARTITION BY Customer_ID ORDER BY Sales DESC) AS rank_per_customer
FROM 
    orders_table;



-- 3️⃣ DENSE_RANK: Ranks sales per customer (no gaps for ties)
SELECT 
    Order_ID, 
    Customer_ID, 
    Sales,
    DENSE_RANK() OVER (PARTITION BY Customer_ID ORDER BY Sales DESC) AS dense_rank_per_customer
FROM 
    orders_table;



-- 4️⃣ LAG & LEAD: Get previous and next sale amount per customer by order date
SELECT 
    Order_ID,
    Customer_ID,
    Sales,
    Order_Date,
    LAG(Sales) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS previous_sale,
    LEAD(Sales) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS next_sale
FROM 
    orders_table;

