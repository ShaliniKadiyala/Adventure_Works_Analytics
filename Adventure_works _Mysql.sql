use adventure_works_project;


-- 0.UNION OF Fact_internet_sales AND Fact_internet_sales_new

create table fact_internet_sales_union as
select * from fact_internet_sales
union all
select * from fact_internet_sales_new;

select* from fact_internet_sales_union;



-- 1.LOOKUP THE PRODUCT NAME FROM THE PRODUCT SHEET TO SALES SHEET

select FISU.*, ProductName 
from fact_internet_sales_union FISU
left join mergeddimproduct MD
on FISU.ProductKey = MD.ProductKey;


-- 2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.

select FISU.*, ProductName,
       CONCAT(DC.FirstName, ' ', IFNULL(DC.MiddleName, ''), ' ', DC.LastName) AS CustomerFullName, 
       UnitPrice
from Fact_Internet_Sales_Union FISU
left join mergeddimproduct MD
on FISU.ProductKey = MD.ProductKey
left join Dimcustomer DC 
on FISU.customerKey = DC.customerKey;


-- 3. Calculate Date time Operations
    

    select
    -- [a]. Order date
    STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d') as OrderDate_new,
    -- [b]. Year
    YEAR(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) AS Year,
    -- [c]. MonthNo
    MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) AS MonthNo,
    -- [d]. MonthFullName
    MONTHNAME(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) AS MONTHFULLNAME,
    -- [e]. Quarter
    CASE 
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 10 AND 12 THEN 'Q4'
    END AS Quarter,
    -- [f]. Year-Month
    CONCAT(YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')), '-', 
	  DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%b')) AS YearMonth,
	-- [g]. WeekDayno
	DAYOFWEEK(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS WeekDayNo,
    -- [h]. WeekDayNo
    DAYNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS WeekDayName,
    -- [i]. FinancialMonth
    CASE
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 4 THEN 'FM-1'
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 5 THEN 'FM-2'
	  WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 6 THEN 'FM-3' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 7 THEN 'FM-4' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 8 THEN 'FM-5' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 9 THEN 'FM-6' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 10 THEN 'FM-7' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 11 THEN 'FM-8' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 12 THEN 'FM-9' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 1 THEN 'FM-10' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2 THEN 'FM-11' 
      WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 3 THEN 'FM-12' 
	END AS FinancialMonth,
    -- [j]. FinancialQuarter
    CASE
	WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 4 AND 6 THEN 'FQ-1'
    WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 7 AND 9 THEN 'FQ-2'
    WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 10 AND 12 THEN 'FQ-3'
    WHEN MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 1 AND 3 THEN 'FQ-4'
END AS FinancialQuarter
    FROM Fact_Internet_Sales_Union FISU;
    
    
    
-- 4. CALCULATE Sales Amount uning the columns (unit price,order quantity,unit discount)
    
    
select 
     FISU.productkey,MD.ProductName, 
	round(sum(FISU.UnitPrice * FISU.OrderQuantity * (1 - FISU.UnitPriceDiscountPct)) / 1000,2) AS SalesAmount,
    Round(sum(((FISU.ProductStandardCost * FISU.OrderQuantity))) /1000,2) AS ProductionCost
FROM Fact_Internet_Sales_Union FISU
left join mergeddimproduct MD
ON FISU.productkey = MD.productkey group by FISU.productkey,MD.ProductName order by SalesAmount desc;


-- 5.Top Products of subcategory

    select MD.ProductSubcategory as SubCatagory,
       ROUND(sum(FISU.UnitPrice * FISU.OrderQuantity * (1- FISU.UnitPriceDiscountPct)) , 2) as TotalSalesAmount_in_K
From
     Fact_internet_Sales_Union FISU
JOIN
     mergeddimproduct MD 
ON FISU.productKey = MD.productkey
GROUP BY 
	   MD.ProductSubcategory
ORDER BY 
	   TotalSalesAmount_in_K DESC
Limit 5 ;

    
    
-- 6. CALCULATE the Productioncost uning the columns(unit cost ,order quantity).


select
   FISU.productkey,MD.ProductName, 
	Round(sum(((FISU.ProductStandardCost * FISU.OrderQuantity))) /1000,2) AS ProductionCost
FROM Fact_Internet_Sales_Union FISU
left join mergeddimproduct MD
ON FISU.productkey = MD.productkey group by FISU.productkey,MD.ProductName order by ProductionCost desc;


-- 7. CALCULATE the profit.

select
     FISU.productkey,MD.ProductName, 
	(FISU.ProductStandardCost * FISU.OrderQuantity) AS ProductionCost,
round((FISU.UnitPrice-UnitPriceDiscountPct-ProductStandardCost) * OrderQuantity, 2) as Profit
from Fact_Internet_Sales_Union FISU
left join mergeddimproduct MD
ON FISU.productkey = MD.productkey;


-- 8.Create a table for month and sales (provide the Year as filter to select a particular Year)


Select 
    YEAR(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) AS Year,
    MONTHNAME(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) AS MonthFullName,
    CONCAT(FORMAT(SUM(FISU.UnitPrice * FISU.OrderQuantity * (1 - FISU.UnitPriceDiscountPct)) / 1000, 0), 'K') AS TotalSales_In_K
    FROM Fact_Internet_Sales_Union FISU 
    GROUP BY Year, MonthFullName
    ORDER BY YEAR, MonthFullName;
    
    call monthly_sales(2013);


-- 9. CALCULATE Year wise Sales

select 
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Year, 
    round(SUM(SalesAmount), 2) AS TotalSales
FROM Fact_Internet_Sales_Union FISU
GROUP BY Year
ORDER BY Year;


-- 10. CALCULATE Quarter wise Sales

select
CASE 
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(STR_TO_DATE(CAST(FISU.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 10 AND 12 THEN 'Q4'
    END AS Quarter,
SUM(SalesAmount) AS TotalSales
FROM Fact_Internet_Sales_Union FISU
GROUP BY Quarter
ORDER BY Quarter;


-- 11. Region wise Profit and Sales

select SalesTerritoryRegion as Region,
      round(sum((FISU.UnitPrice-UnitPriceDiscountPct-ProductStandardCost) * OrderQuantity),2)as Profit,
      round(SUM(SalesAmount),2) AS TotalSales
from fact_internet_sales_union FISU
left join dimsalesterritory DS
on FISU.SalesTerritoryKey = DS.SalesTerritoryKey Group by Region order by Profit desc;



    
    

