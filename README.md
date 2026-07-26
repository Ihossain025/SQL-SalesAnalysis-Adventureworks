# SQL-EDA-SalesAnalysis-Adventureworks

**Database:** AdventureWorksDW2025  
**Tools:** SQL Server, SSMS  

---

## 🔍 Project Overview
This project performs **Exploratory Data Analysis (EDA)** using SQL on the AdventureWorks Data Warehouse.

**Project Scope / Focus Areas:**
- Sales performance  
- Customer behavior  
- Product analysis  
- Time & geography trends  

**🎯 Objectives**
- Understand *Database structure and relationships*  
- Analyze *customer demographics and behavior*  
- Evaluate *product and category performance*  
- Measure *key business KPIs*  
- Identify *YoY & MoM trends*
- Analyze *geographical performance* 

---

## 🗂️ Database Structure & Data Understanding [Database Exploration]

The dataset follows a Star Schema structure. Key Steps Performed:

- Identified tables, schemas, and structure
- Explored columns, data types, and constraints
- Distinguished Fact vs Dimension tables

Here are the identified relevant tables:

**Fact Tables**
-	FactInternetSales
-	FactResellerSales

**Dimension Tables**
-	DimCustomer
-	DimProduct
-	DimProductCategory
-	DimProductSubcategory
-	DimGeography
-	DimSalesTerritory

---

## ⚙️ Key Analysis [Dimensions, Measure, and Magnitude Analysis or Exploration]

### 👥 Customer
- Distribution by *country & city*  
- Demographics: *age, gender, education, occupation*  
- Metrics: *age, tenure, first purchase*  

### 📦 Product
- Category → Subcategory → Product hierarchy  
- Attributes: *size, color, product line*
- Top 5 and Bottom 5 Product Analysis
- Sales by Product Categories and Sub-Categories

### 📅 Time
- Sales trends (*Yearly & Monthly*)  
- Shipping performance  
- Date validation  

### Geography
- Top revenue-generating countries and cities`  
- Countries and Cities with a high customer base  

---

## 📊 Key Metrics (KPI) Determination 
- Total Customers  
- Total Orders  
- Total Sales  
- Order Quantity  
- Avg Product Price & Cost  

---

## 📈 Key Insights
- Sales demonstrated **consistent year-over-year growth across the full date range**, with acceleration in later periods. **Total Sales increased by 34.69% in 2012 compared to 2011 and 46.68% in 2013 compared to 2012**
- There is no strong signal that shows **our revenue depends on seasonality**, rather **our analysis finds that Month-over-Month Sales fluctuate a lot**
- **Product Categories “Bikes” and “Components” generate nearly 96% of our revenue**. The contribution from products falling into “Clothing” and “Accessories” is insignificant, around 4% combined. 
- **All our current customers are either old age or middle age. We don’t have any young customers (Age under 30) yet**. Opportunities exist to reach out to this specific group.
- Our customers come from only six countries. Huge opportunities exist to expand the business across other countries or continents.
- Overall, business is doing good in terms of sales or revenue, however **opportunities exist to optimize underperforming products as well as expand customer base and regions**.

---

## 💡 Skills Demonstrated
- SQL (*Basic Queries, Aggregations, Joins, Window Functions, Sub-query, CTEs, View*)  
- Data Analysis & Aggregation
- Database Structure & Data Model understanding  
- Business Insight Generation  

---

## Attachments
- AdventureWorksDataWarehouse2025.bak
- SQLquery.sql
- Summary_Findings.pdf
- Management_Summary.ppt/pdf

---

## 👤 Author

**Md. Iqbal Hossain**

Business & Data Analyst | Data Engineer | BI Analyst | Technical Consultant
 


