/* SQL Business Analysis: Retail Sales Database
   Tables: Regions, Categories, Customers, Products, Orders
   Tool: SQLite (DB Browser for SQLite)
   Open retail_business.db in DB Browser for SQLite, then run these queries in the Execute SQL tab. */

/* ============================================================
   SECTION A — UNDERSTAND THE DATABASE
   ============================================================
   Database Structure Summary

   Table       | Purpose                                   | Important Fields
   ------------|--------------------------------------------|--------------------------------
   Regions     | Lookup of the 5 sales regions               | Region_ID (PK), Region_Name
   Categories  | Lookup of the 8 product categories          | Category_ID (PK), Category_Name
   Customers   | One row per customer, tied to a region       | Customer_ID (PK), Region_ID (FK -> Regions)
   Products    | One row per distinct item sold               | Product_ID (PK), Product_Name, Category_ID (FK -> Categories), Unit_Price
   Orders      | One row per transaction (the fact table)     | Order_ID (PK), Customer_ID (FK -> Customers),
               |                                              | Product_ID (FK -> Products), Quantity, Sales,
               |                                              | Payment_Method, Location, Order_Date, Discount_Applied

   Relationships:
   - Customers.Region_ID   -> Regions.Region_ID       (many customers per region)
   - Products.Category_ID  -> Categories.Category_ID  (many products per category)
   - Orders.Customer_ID    -> Customers.Customer_ID   (many orders per customer)
   - Orders.Product_ID     -> Products.Product_ID     (many orders per product)

   Orders is the central "fact" table; Customers, Products, Categories, and
   Regions are "dimension" tables that describe who/what/where an order relates to.
*/

-- Inspect table structures
PRAGMA table_info(Regions);
PRAGMA table_info(Categories);
PRAGMA table_info(Customers);
PRAGMA table_info(Products);
PRAGMA table_info(Orders);


/* ============================================================
   SECTION B — EXPLORE THE DATA
   ============================================================ */

-- How many customers are present?
SELECT COUNT(*) AS Total_Customers FROM Customers;

-- How many orders are recorded?
SELECT COUNT(*) AS Total_Orders FROM Orders;

-- How many different products are available?
SELECT COUNT(*) AS Total_Products FROM Products;

-- Which categories are present?
SELECT DISTINCT Category_Name FROM Categories ORDER BY Category_Name;

-- Which regions are present?
SELECT DISTINCT Region_Name FROM Regions ORDER BY Region_Name;

-- What is the date range of the dataset?
SELECT MIN(Order_Date) AS Earliest_Order, MAX(Order_Date) AS Latest_Order FROM Orders;

-- Top 10 highest-value orders
SELECT Order_ID, Customer_ID, Sales, Order_Date
FROM Orders
ORDER BY Sales DESC
LIMIT 10;

-- Distinct payment methods and locations (categorical exploration)
SELECT DISTINCT Payment_Method FROM Orders;
SELECT DISTINCT Location FROM Orders;


/* ============================================================
   SECTION C — SQL FUNDAMENTALS FOR BUSINESS ANALYSIS
   ============================================================ */

-- Find orders above a specific sales value (e.g. above €300)
SELECT Order_ID, Customer_ID, Sales
FROM Orders
WHERE Sales > 300
ORDER BY Sales DESC;

-- Find customers from a particular region (via join, since Region lives on Customers/Regions)
SELECT c.Customer_ID, r.Region_Name
FROM Customers c
JOIN Regions r ON c.Region_ID = r.Region_ID
WHERE r.Region_Name = 'Central';

-- Find products belonging to a specific category
SELECT p.Product_Name, cat.Category_Name, p.Unit_Price
FROM Products p
JOIN Categories cat ON p.Category_ID = cat.Category_ID
WHERE cat.Category_Name = 'Butchers';

-- Find orders within a selected date range
SELECT Order_ID, Sales, Order_Date
FROM Orders
WHERE Order_Date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY Order_Date;

-- Display the highest-value orders
SELECT Order_ID, Sales FROM Orders ORDER BY Sales DESC LIMIT 5;

-- Display the lowest-value orders
SELECT Order_ID, Sales FROM Orders ORDER BY Sales ASC LIMIT 5;


/* ============================================================
   SECTION D — FILTERING BUSINESS DATA
   ============================================================ */

-- Which customers belong to a set of selected regions? (IN)
SELECT c.Customer_ID, r.Region_Name
FROM Customers c
JOIN Regions r ON c.Region_ID = r.Region_ID
WHERE r.Region_Name IN ('North', 'South');

-- Which products belong to a set of selected categories? (IN)
SELECT p.Product_Name, cat.Category_Name
FROM Products p
JOIN Categories cat ON p.Category_ID = cat.Category_ID
WHERE cat.Category_Name IN ('Beverages', 'Food');

-- Which orders fall within a specific sales range? (BETWEEN)
SELECT Order_ID, Sales
FROM Orders
WHERE Sales BETWEEN 100 AND 200
ORDER BY Sales;

-- Which transactions occurred during a particular period? (AND)
SELECT Order_ID, Sales, Order_Date
FROM Orders
WHERE Order_Date >= '2023-01-01' AND Order_Date <= '2023-12-31';

-- Which products match a specific name pattern? (LIKE)
SELECT Product_Name FROM Products WHERE Product_Name LIKE '%FUR%';

-- Business Question: Which customers are in the North or South region?
-- Result: 10 of the 25 customers (5 North, 5 South)
-- Interpretation: makes up 40% of the customer base, and roughly 40% of revenue too --
-- proportional, not skewed toward either region.


/* ============================================================
   SECTION E — BUSINESS PERFORMANCE ANALYSIS
   ============================================================ */

-- Total Sales, Orders, Average/Min/Max Order Value
SELECT
    SUM(Sales)   AS Total_Sales,
    COUNT(*)     AS Total_Orders,
    AVG(Sales)   AS Average_Order_Value,
    MIN(Sales)   AS Minimum_Order_Value,
    MAX(Sales)   AS Maximum_Order_Value
FROM Orders;

-- Sales by Category
SELECT cat.Category_Name, SUM(o.Sales) AS Category_Sales
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY cat.Category_Name
ORDER BY Category_Sales DESC;

-- Sales by Region
SELECT r.Region_Name, SUM(o.Sales) AS Region_Sales
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Regions r ON c.Region_ID = r.Region_ID
GROUP BY r.Region_Name
ORDER BY Region_Sales DESC;

-- Product-wise Sales (top 10 products by revenue)
-- NOTE: grouped by (Product_Name, Category_Name) together, not Product_Name alone --
-- "Unknown Item" (a placeholder for missing item names during Week 1 cleaning)
-- appears in every category, so grouping by name alone would incorrectly merge
-- unrelated categories into one row.
SELECT p.Product_Name, cat.Category_Name, SUM(o.Sales) AS Product_Sales
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY p.Product_Name, cat.Category_Name
ORDER BY Product_Sales DESC
LIMIT 10;

-- Monthly Sales
SELECT strftime('%Y-%m', Order_Date) AS Month, SUM(Sales) AS Monthly_Sales
FROM Orders
GROUP BY Month
ORDER BY Month;

-- Which month generated the highest sales?
SELECT strftime('%Y-%m', Order_Date) AS Month, SUM(Sales) AS Monthly_Sales
FROM Orders
GROUP BY Month
ORDER BY Monthly_Sales DESC
LIMIT 1;


/* ============================================================
   SECTION F — GROUP BY & HAVING
   ============================================================ */

-- Which categories generated more than €190,000 in revenue?
SELECT cat.Category_Name, SUM(o.Sales) AS Category_Sales
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY cat.Category_Name
HAVING SUM(o.Sales) > 190000
ORDER BY Category_Sales DESC;

-- Which regions have more than 2,400 orders?
SELECT r.Region_Name, COUNT(*) AS Order_Count
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Regions r ON c.Region_ID = r.Region_ID
GROUP BY r.Region_Name
HAVING COUNT(*) > 2400
ORDER BY Order_Count DESC;

-- Which customers generated revenue above €62,000? (high-value customers)
SELECT Customer_ID, SUM(Sales) AS Customer_Revenue
FROM Orders
GROUP BY Customer_ID
HAVING SUM(Sales) > 62000
ORDER BY Customer_Revenue DESC;

-- Which products have sufficient sales volume (more than 40 units sold)?
SELECT p.Product_Name, cat.Category_Name, SUM(o.Quantity) AS Units_Sold
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY p.Product_Name, cat.Category_Name
HAVING SUM(o.Quantity) > 40
ORDER BY Units_Sold DESC;


/* ============================================================
   SECTION G — MULTI-TABLE ANALYSIS USING JOINS
   ============================================================ */

-- Customer-wise revenue and order count (Customers + Orders)
SELECT c.Customer_ID, r.Region_Name, COUNT(o.Order_ID) AS Order_Count, SUM(o.Sales) AS Total_Revenue
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Regions r ON c.Region_ID = r.Region_ID
GROUP BY c.Customer_ID
ORDER BY Total_Revenue DESC;

-- Best-selling products (Products + Orders)
SELECT p.Product_Name, cat.Category_Name, SUM(o.Sales) AS Product_Revenue, SUM(o.Quantity) AS Units_Sold
FROM Products p
JOIN Orders o ON p.Product_ID = o.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY p.Product_Name, cat.Category_Name
ORDER BY Product_Revenue DESC
LIMIT 10;

-- Category-wise product performance (Products + Categories)
SELECT cat.Category_Name, COUNT(DISTINCT p.Product_ID) AS Number_of_Products, SUM(o.Sales) AS Category_Revenue
FROM Categories cat
JOIN Products p ON cat.Category_ID = p.Category_ID
JOIN Orders o ON p.Product_ID = o.Product_ID
GROUP BY cat.Category_Name
ORDER BY Category_Revenue DESC;

-- Regional customer performance (Customers + Regions)
SELECT r.Region_Name, COUNT(DISTINCT c.Customer_ID) AS Number_of_Customers, SUM(o.Sales) AS Region_Revenue
FROM Regions r
JOIN Customers c ON r.Region_ID = c.Region_ID
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY r.Region_Name
ORDER BY Region_Revenue DESC;

-- LEFT JOIN: identify customers with NO recorded orders
SELECT c.Customer_ID
FROM Customers c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;
-- Result: every customer has placed at least one order in this dataset (see report).


/* ============================================================
   SECTION H — BUSINESS CHALLENGE (7 real-world questions)
   ============================================================ */

-- Q1 [SALES] Which quarter generated the highest sales?
SELECT
    CAST(strftime('%Y', Order_Date) AS INTEGER) AS Year,
    ((CAST(strftime('%m', Order_Date) AS INTEGER) - 1) / 3) + 1 AS Quarter,
    SUM(Sales) AS Quarterly_Sales
FROM Orders
GROUP BY Year, Quarter
ORDER BY Quarterly_Sales DESC
LIMIT 1;

-- Q2 [CUSTOMERS] Who are the top 5 highest-value customers?
SELECT c.Customer_ID, r.Region_Name, SUM(o.Sales) AS Total_Revenue
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Regions r ON c.Region_ID = r.Region_ID
GROUP BY c.Customer_ID
ORDER BY Total_Revenue DESC
LIMIT 5;

-- Q3 [PRODUCTS] Business Question: Which products contribute the most revenue?
SELECT p.Product_Name, cat.Category_Name, SUM(o.Sales) AS Product_Revenue
FROM Products p
JOIN Orders o ON p.Product_ID = o.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY p.Product_Name
ORDER BY Product_Revenue DESC
LIMIT 5;

-- Q4 [CATEGORIES] Business Question: Which category performs best, and which worst?
SELECT cat.Category_Name, SUM(o.Sales) AS Category_Sales
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
JOIN Categories cat ON p.Category_ID = cat.Category_ID
GROUP BY cat.Category_Name
ORDER BY Category_Sales DESC;

-- Q5 [REGIONS] Business Question: Which region generates the most revenue?
SELECT r.Region_Name, SUM(o.Sales) AS Region_Sales
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Regions r ON c.Region_ID = r.Region_ID
GROUP BY r.Region_Name
ORDER BY Region_Sales DESC;

-- Q6 [TRENDS] Business Question: How does sales performance change year over year?
SELECT strftime('%Y', Order_Date) AS Year, SUM(Sales) AS Yearly_Sales
FROM Orders
WHERE strftime('%Y', Order_Date) IN ('2022','2023','2024')
GROUP BY Year
ORDER BY Year;

-- Q7 [BUSINESS OPPORTUNITY] Business Question: Which segment of customers
-- (by order count) appears underserved and could be an improvement opportunity?
SELECT
    CASE
        WHEN order_count >= 500 THEN 'Frequent (500+ orders)'
        WHEN order_count >= 400 THEN 'Regular (400-499 orders)'
        ELSE 'Infrequent (<400 orders)'
    END AS Customer_Frequency_Segment,
    COUNT(*) AS Number_of_Customers,
    SUM(total_revenue) AS Segment_Revenue
FROM (
    SELECT Customer_ID, COUNT(*) AS order_count, SUM(Sales) AS total_revenue
    FROM Orders
    GROUP BY Customer_ID
) sub
GROUP BY Customer_Frequency_Segment
ORDER BY Segment_Revenue DESC;
