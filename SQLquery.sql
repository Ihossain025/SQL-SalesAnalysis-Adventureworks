
-- ============================================================
-- Project 01: Exploratory Data Analysis
-- Database: AdventureWorksDW2025
-- Server: MS SQL Server
-- ============================================================

USE AdventureWorksDW2025;
GO

-- ============================================================
-- 1. DATABASE EXPLORATION
-- ============================================================

-- Overview of all tables (including views)

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- List only physical (base) tables

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- Explore table structure: columns, data types, nullability

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY
    TABLE_NAME,
    COLUMN_NAME;

-- Identify primary and foreign keys for a specific table

SELECT
    KCU.TABLE_NAME,
    KCU.COLUMN_NAME,
    KCU.CONSTRAINT_NAME,
    TC.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
    ON KCU.TABLE_NAME = TC.TABLE_NAME
    AND KCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE KCU.TABLE_NAME = 'FactResellerSales';

-- Identify Fact vs Dimension tables (naming convention validation)

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'Dim%';

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'Fact%';

-- Inspect specific table structure if needed

SELECT *
FROM FactInternetSales;


-- ============================================================
-- 2. DIMENSION EXPLORATION
-- Focus: Customer, Product, Geography
-- ============================================================

-- ----------------------------
-- Customer Geography Analysis
-- ----------------------------

-- Distinct customer countries

SELECT DISTINCT
    Geo.EnglishCountryRegionName AS Customer_Country
FROM DimCustomer AS Cus
LEFT JOIN DimGeography AS Geo
    ON Cus.GeographyKey = Geo.GeographyKey;

-- Distinct customer cities

SELECT DISTINCT
    Geo.EnglishCountryRegionName AS Customer_Country,
    Geo.City AS Customer_City
FROM DimCustomer AS Cus
LEFT JOIN DimGeography AS Geo
    ON Cus.GeographyKey = Geo.GeographyKey
ORDER BY
    Geo.EnglishCountryRegionName,
    Geo.City;

-- ----------------------------
-- Customer Demographics
-- ----------------------------

-- Gender distribution

SELECT
    CASE
        WHEN Gender = 'M' THEN 'Male'
        WHEN Gender = 'F' THEN 'Female'
        ELSE 'Undefined'
    END AS Gender,
	COUNT (CustomerKey) AS Customer_Count

FROM DimCustomer
GROUP BY
	CASE
        WHEN Gender = 'M' THEN 'Male'
        WHEN Gender = 'F' THEN 'Female'
        ELSE 'Undefined'
    END

-- Age group distribution using CTE

WITH CustomerAges AS (
    SELECT
        CustomerKey,
        DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age
    FROM DimCustomer
)
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS Age_Group,
    COUNT(*) AS Customer_Count

FROM CustomerAges
GROUP BY
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END;

-- Education levels

SELECT DISTINCT
    EnglishEducation AS Customer_Education_Level,
	Count (*) AS Customer_Count
FROM DimCustomer
GROUP BY EnglishEducation
ORDER BY Customer_Count DESC 

-- Occupations

SELECT DISTINCT
    EnglishOccupation AS Customer_Occupation,
	Count (*) AS Customer_Count
FROM DimCustomer
GROUP BY EnglishOccupation
ORDER BY Customer_Count DESC 

-- Marital status

SELECT DISTINCT
    CASE
        WHEN MaritalStatus = 'S' THEN 'Single'
        WHEN MaritalStatus = 'M' THEN 'Married'
        ELSE 'Undefined'
    END AS Marital_Status
FROM DimCustomer;


-- ----------------------------
-- Product Dimension Analysis
-- ----------------------------

-- Product hierarchy: Category → Subcategory → Product

SELECT DISTINCT
    Cat.EnglishProductCategoryName AS Product_Category,
    SubCat.EnglishProductSubcategoryName AS Product_SubCategory,
    Prod.EnglishProductName AS Product_Name
FROM DimProduct AS Prod
LEFT JOIN DimProductSubcategory AS SubCat
    ON Prod.ProductSubcategoryKey = SubCat.ProductSubcategoryKey
LEFT JOIN DimProductCategory AS Cat
    ON SubCat.ProductCategoryKey = Cat.ProductCategoryKey
ORDER BY
    Cat.EnglishProductCategoryName,
    SubCat.EnglishProductSubcategoryName,
    Prod.EnglishProductName;

-- Product attributes

SELECT DISTINCT
    EnglishProductName,
    ProductLine,
    Size,
    Color
FROM DimProduct
ORDER BY
    EnglishProductName,
    ProductLine,
    Size,
    Color;


-- ============================================================
-- 3. DATE EXPLORATION
-- ============================================================

-- Order date range

SELECT
    MIN(CAST(OrderDate AS DATE)) AS First_Order_Date,
    MAX(CAST(OrderDate AS DATE)) AS Last_Order_Date,
    DATEDIFF(
        YEAR,
        MIN(CAST(OrderDate AS DATE)),
        MAX(CAST(OrderDate AS DATE))
    ) AS Order_Timeframe_Years
FROM FactInternetSales;

-- Check for NULLs in date columns

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(OrderDate) AS OrderDate_NotNull,
    COUNT(DueDate) AS DueDate_NotNull,
    COUNT(ShipDate) AS ShipDate_NotNull
FROM FactInternetSales;

-- Validate logical date order

SELECT *
FROM FactInternetSales
WHERE
    OrderDate > ShipDate
    OR ShipDate > DueDate;

-- Shipping and delivery performance

SELECT
    AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AS Avg_Shipping_Time,
    AVG(DATEDIFF(DAY, ShipDate, DueDate)) AS Avg_Delivery_Gap
FROM FactInternetSales;

-- Customer age at first purchase

SELECT
    CustomerKey,
    CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS Customer_Name,
    DATEDIFF(YEAR, BirthDate, DateFirstPurchase) AS Age_At_First_Purchase,
	AVG (DATEDIFF(YEAR, BirthDate, DateFirstPurchase)) OVER () AS Avg_Age_atFirstPurchase
FROM DimCustomer;

-- Customer tenure

SELECT
    CustomerKey,
    CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS Customer_Name,
    DATEDIFF(YEAR, DateFirstPurchase, GETDATE()) AS Customer_Tenure,
	AVG (DATEDIFF(YEAR, DateFirstPurchase, GETDATE())) OVER () Avg_CustomerTenure
FROM DimCustomer;

-- Youngest and oldest customers

SELECT
    MIN(DATEDIFF(YEAR, BirthDate, GETDATE())) AS Youngest_Age,
    MAX(DATEDIFF(YEAR, BirthDate, GETDATE())) AS Oldest_Age
FROM DimCustomer;


-- ============================================================
-- 4. MEASURES EXPLORATION
-- ============================================================

-- Combine Internet & Reseller sales into one view

DROP VIEW IF EXISTS Complete_Sales_Table;
GO

CREATE VIEW Complete_Sales_Table AS
SELECT
    ProductKey,
    SalesTerritoryKey,
    SalesOrderNumber,
    SalesOrderLineNumber,
    OrderQuantity,
    UnitPrice,
    SalesAmount,
    TotalProductCost,
    OrderDate,
    DueDate,
    ShipDate,
    'Internet' AS Sales_Medium
FROM FactInternetSales

UNION ALL

SELECT
    ProductKey,
    SalesTerritoryKey,
    SalesOrderNumber,
    SalesOrderLineNumber,
    OrderQuantity,
    UnitPrice,
    SalesAmount,
    TotalProductCost,
    OrderDate,
    DueDate,
    ShipDate,
    'Reseller' AS Sales_Medium
FROM FactResellerSales;

-- Key metrics

SELECT COUNT(DISTINCT CustomerKey) AS Total_Customers
FROM DimCustomer;

SELECT COUNT(DISTINCT CustomerKey) AS Customers_With_Orders
FROM FactInternetSales;

SELECT COUNT(DISTINCT CustomerKey) AS Customers_Without_Orders
FROM (
    SELECT CustomerKey FROM DimCustomer
    EXCEPT
    SELECT CustomerKey FROM FactInternetSales
) AS NotOrdered;

SELECT COUNT(DISTINCT ProductKey) AS Total_Products
FROM DimProduct;

SELECT COUNT(*) AS Total_Orders
FROM Complete_Sales_Table;

SELECT SUM(OrderQuantity) AS Total_Order_Quantity
FROM Complete_Sales_Table;

SELECT SUM(SalesAmount) AS Total_Sales
FROM Complete_Sales_Table;

SELECT AVG(UnitPrice) AS Avg_Product_UnitPrice
FROM Complete_Sales_Table;

SELECT AVG(TotalProductCost) AS Avg_Product_Cost
FROM Complete_Sales_Table;

-- Combined Key Metrics view

SELECT 'Total_Customers' AS Measure_Name, COUNT(DISTINCT CustomerKey) AS Measure_Value FROM DimCustomer
UNION ALL
SELECT 'Total_Products', COUNT(DISTINCT ProductKey) FROM DimProduct
UNION ALL
SELECT 'Total_Orders', COUNT(*) FROM Complete_Sales_Table
UNION ALL
SELECT 'Total_Order_Quantity', SUM(OrderQuantity) FROM Complete_Sales_Table
UNION ALL
SELECT 'Total_Sales', ROUND(SUM(SalesAmount), 2) FROM Complete_Sales_Table
UNION ALL
SELECT 'Avg_Product_Cost', ROUND(AVG(TotalProductCost), 2) FROM Complete_Sales_Table;


-- ============================================================
-- 5. MAGNITUDE ANALYSIS
-- ============================================================

-- ----------------------------
-- Product Performance
-- ----------------------------

-- All Products by revenue

SELECT
    P.EnglishProductName AS Product_Name,
    SUM(SalesAmount) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimProduct AS P
    ON CST.ProductKey = P.ProductKey
GROUP BY P.EnglishProductName;

-- Top 5 products by revenue

SELECT TOP 5
    P.EnglishProductName AS Product_Name,
    SUM(SalesAmount) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimProduct AS P
    ON CST.ProductKey = P.ProductKey
GROUP BY P.EnglishProductName
ORDER BY SUM(SalesAmount) DESC;

-- Bottom 5 products by revenue

SELECT TOP 5
    P.EnglishProductName AS Product_Name,
    SUM(SalesAmount) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimProduct AS P
    ON CST.ProductKey = P.ProductKey
GROUP BY P.EnglishProductName
ORDER BY SUM(SalesAmount) ASC;

-- Sales by product category

SELECT
    Cat.EnglishProductCategoryName AS Product_Category,
    SUM(CST.SalesAmount) AS Sales_By_Category
FROM Complete_Sales_Table AS CST
LEFT JOIN DimProduct AS Prod
    ON CST.ProductKey = Prod.ProductKey
LEFT JOIN DimProductSubcategory AS SubCat
    ON Prod.ProductSubcategoryKey = SubCat.ProductSubcategoryKey
LEFT JOIN DimProductCategory AS Cat
    ON Cat.ProductCategoryKey = SubCat.ProductCategoryKey
GROUP BY Cat.EnglishProductCategoryName
ORDER BY Sales_By_Category DESC;

-- Sales by product subcategory

SELECT
	Prod_SubCat.EnglishProductSubcategoryName As Product_Subcategory,
	ROUND (SUM (CST.SalesAmount),2) AS Sales_BY_Product_Subcategory
FROM Complete_Sales_Table CST
LEFT JOIN DimProduct Prod
	ON CST.ProductKey = Prod.ProductKey
LEFT JOIN DimProductSubcategory Prod_SubCat
	ON Prod.ProductSubcategoryKey = Prod_SubCat.ProductSubcategoryKey
LEFT JOIN DimProductCategory ProdCat
	ON ProdCat.ProductCategoryKey = Prod_SubCat.ProductCategoryKey
GROUP BY Prod_SubCat.EnglishProductSubcategoryName
ORDER BY Sales_BY_Product_Subcategory DESC

-- ----------------------------
-- Time Analysis
-- ----------------------------

-- Sales or Revenue by Each Year

SELECT
    YEAR(OrderDate) AS Sales_Year,
    SUM(SalesAmount) AS Revenue
FROM Complete_Sales_Table
GROUP BY YEAR(OrderDate)
ORDER BY Revenue DESC;

-- Year-over-Year growth or decline

WITH Yearly_Sales AS (
    SELECT
        YEAR(OrderDate) AS Sales_Year,
        SUM(SalesAmount) AS Yearly_Sales
    FROM Complete_Sales_Table
    GROUP BY YEAR(OrderDate)
)
SELECT
    Sales_Year,
    Yearly_Sales,
    LAG(Yearly_Sales) OVER (ORDER BY Sales_Year) AS Previous_Year,
    CONCAT(
        (Yearly_Sales - LAG(Yearly_Sales) OVER (ORDER BY Sales_Year))
        / LAG(Yearly_Sales) OVER (ORDER BY Sales_Year) * 100,
        '%'
    ) AS YoY_Change
FROM Yearly_Sales
WHERE Sales_Year IN (2011,2012,2013) 
ORDER BY Sales_Year;

-- Total Sales by Each Month of every Year

SELECT
	YEAR (OrderDate) AS Sales_Year,
	MONTH (OrderDate) AS Month_Number,
	DATENAME (MONTH, OrderDate) AS Month_Name,
	SUM (SalesAmount) AS Total_Sales
FROM Complete_Sales_Table
GROUP BY 
	YEAR (OrderDate), 
	MONTH (OrderDate), 
	DATENAME (MONTH, OrderDate)
ORDER BY
	YEAR (OrderDate) DESC,
	MONTH (OrderDate) ASC;


-- Month-over-Month growth or decline

WITH Monthly_Sales AS (
SELECT
	YEAR (OrderDate) AS Sales_Year,
	MONTH (OrderDate) AS Sales_Month,
	SUM (SalesAmount) AS Monthly_TotalSales
FROM Complete_Sales_Table
GROUP BY 
	YEAR (OrderDate), 
	MONTH (OrderDate)
)

SELECT
	Sales_Year,
	Sales_Month,
	Monthly_TotalSales,
	LAG(Monthly_TotalSales,1) OVER (ORDER BY Sales_Year, Sales_Month) AS PreviousMonth_TotalSales,
	CONCAT((Monthly_TotalSales - LAG(Monthly_TotalSales,1) OVER (ORDER BY Sales_Year, Sales_Month)) / LAG(Monthly_TotalSales,1) OVER (ORDER BY Sales_Year, Sales_Month) * 100, '%') AS MoM_PercentageChange
FROM Monthly_Sales
ORDER BY Sales_Year, Sales_Month

-- ----------------------------
-- Geography Analysis
-- ----------------------------

-- Customers by country

SELECT
    Geo.EnglishCountryRegionName AS Country,
    COUNT(CustomerKey) AS Customer_Count
FROM DimCustomer AS Cus
LEFT JOIN DimGeography AS Geo
    ON Cus.GeographyKey = Geo.GeographyKey
GROUP BY Geo.EnglishCountryRegionName
ORDER BY Customer_Count DESC;

-- Sales by country

SELECT
    ST.SalesTerritoryCountry AS Country,
    SUM(CST.SalesAmount) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimSalesTerritory AS ST
    ON ST.SalesTerritoryKey = CST.SalesTerritoryKey
GROUP BY ST.SalesTerritoryCountry
ORDER BY Total_Sales DESC;

-- Top 10 cities by revenue

SELECT TOP 10
    Geo.City AS City,
    ROUND(SUM(CST.SalesAmount), 2) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimSalesTerritory AS ST
    ON ST.SalesTerritoryKey = CST.SalesTerritoryKey
LEFT JOIN DimGeography AS Geo
    ON ST.SalesTerritoryKey = Geo.SalesTerritoryKey
GROUP BY Geo.City
ORDER BY Total_Sales DESC;

-- Bottom 10 cities by revenue

SELECT TOP 10
    Geo.City AS City,
    ROUND(SUM(CST.SalesAmount), 2) AS Total_Sales
FROM Complete_Sales_Table AS CST
LEFT JOIN DimSalesTerritory AS ST
    ON ST.SalesTerritoryKey = CST.SalesTerritoryKey
LEFT JOIN DimGeography AS Geo
    ON ST.SalesTerritoryKey = Geo.SalesTerritoryKey
GROUP BY Geo.City
ORDER BY Total_Sales ASC;
