USE Final_Test
SELECT *
FROM supermarket_sales

-- Show total order
SELECT 
    COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales

-- Show total sales of each branch
SELECT
    Branch
    , ROUND(SUM(cogs),2) AS [Sum Sales]
FROM supermarket_sales
GROUP BY Branch

-- Show total sales and orders of each product line
SELECT 
    Product_line
    , ROUND(SUM(cogs),2) AS [Sum Sales]
    , COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales
GROUP BY Product_line

-- Show total sales and orders of each product line and customer type
SELECT 
    Product_line
    , Customer_type
    , ROUND(SUM(cogs),2) AS [Sum Sales]
    , COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales
GROUP BY Product_line, Customer_type
ORDER BY 1

-- Show total sales of each month
SELECT 
    MONTH(date) AS Month
    , SUM(cogs) AS [Total Sales]
FROM supermarket_sales
GROUP BY MONTH(date);

--  For the month with the highest sales, find the time slots where the total number of orders exceeds the average number of orders per hour
WITH highest_sale_month AS
(
SELECT TOP 1
    MONTH(date) AS [Month]
    , SUM(cogs) AS [Total Sales]
FROM supermarket_sales
GROUP BY MONTH(date)
ORDER BY 2 DESC
), Oders_by_Hours AS 
(
SELECT
    DATEPART(HOUR, [Time]) AS [Hour]
    , COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales
WHERE MONTH([Date]) = (SELECT [Month] FROM highest_sale_month)
GROUP BY DATEPART(HOUR, [Time])
) 
SELECT *
FROM Oders_by_Hours
WHERE [Total Order] > (SELECT AVG([Total Order]) FROM Oders_by_Hours)

-- Customer type with fewer orders but higher sales.
WITH All_Cus AS 
(
SELECT 
    Product_line
    , Customer_type
    , ROUND(SUM(cogs),2) AS [Sum Sales]
    , COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales
GROUP BY Product_line, Customer_type
), Normal AS
(
SELECT 
    Product_line
    , Customer_type
    , ROUND(SUM(cogs),2) AS [Sum Sales]
    , COUNT(Invoice_ID) AS [Total Order]
FROM supermarket_sales
WHERE Customer_type = 'Normal'
GROUP BY Product_line, Customer_type
)
SELECT A.*
FROM ALL_Cus A
INNER JOIN Normal N ON N.Product_line = A.Product_line
WHERE A.[Total Order] <  N.[Total Order] AND A.[Sum Sales] > N.[Sum Sales]
OR   N.[Total Order] <  A.[Total Order] AND N.[Sum Sales] > A.[Sum Sales]


-- Show monthly total sales, orders and total sales, orders before
WITH monthly_sales_orders AS
(
SELECT 
    MONTH([Date]) AS [Month]
    , ROUND(SUM(cogs),2) AS [SumSales]
    , COUNT(Invoice_ID) AS [TotalOrder]
FROM supermarket_sales
GROUP BY MONTH([Date])
), total_before AS
(
SELECT
    [Month] + 1 AS [Month]
    , SUM([SumSales]) OVER (ORDER BY [Month]) AS [Total Sales Before]
    , SUM([TotalOrder]) OVER (ORDER BY [Month]) AS [Total Orders Before]
FROM monthly_sales_orders
) 
SELECT 
    monthly_sales_orders.*
    , total_before.[Total Sales Before]
    , total_before.[Total Orders Before]
FROM monthly_sales_orders
LEFT JOIN total_before ON monthly_sales_orders.[Month] = total_before.[Month]