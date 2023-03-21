/*
**Q4.1**
*/

WITH sales AS (
    SELECT ProductName,
           SalesTerritoryRegion,
           SUM(SalesAmount) AS total_sales
    FROM f_sales
    LEFT JOIN d_sales_territory ON f_sales.SalesTerritoryKey = d_sales_territory.SalesTerritoryKey
    LEFT JOIN d_product ON f_sales.ProductKey = d_product.ProductKey
    GROUP BY ProductName, SalesTerritoryRegion
    )

WITH ranked_sales AS (
    SELECT ProductName,
           SalesTerritoryRegion,
           total_sales,
           RANK() OVER (PARTITION BY SalesTerritoryRegion ORDER BY total_sales DESC) AS sales_rank
    FROM sales
    )

SELECT ProductName,
       SalesTerritoryRegion,
       total_sales
FROM ranked_sales
WHERE sales_rank <= 3;

/*
**Q4.2**
*/

WITH purchases AS (
    SELECT CustomerKey,
           SalesTerritoryRegion,
           OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerKey ORDER BY OrderDate) AS purchase_number
    FROM f_sales
    LEFT JOIN d_sales_territory ON f_sales.SalesTerritoryKey = d_sales_territory.SalesTerritoryKey
    )

WITH first_second_purchases AS (
    SELECT CustomerKey,
           SalesTerritoryRegion,
           MIN(CASE WHEN purchase_number = 1 THEN OrderDate END) AS first_purchase,
           MIN(CASE WHEN purchase_number = 2 THEN OrderDate END) AS second_purchase
    FROM purchases
    WHERE purchase_number IN (1, 2)
    GROUP BY CustomerKey, SalesTerritoryRegion
    )   

SELECT SalesTerritoryRegion,
       AVG(DATEDIFF(day, first_purchase, second_purchase)) AS avg_days_between_first_second_purchase
FROM first_second_purchases
GROUP BY SalesTerritoryRegion;



/*
**Q4.3**
*/

WITH customer_age AS (
    SELECT  CustomerKey, 
            DATEDIFF(YY, BirthYear, 2014) AS age
    FROM d_customer
    )

WITH  customer_age_group AS (
    SELECT  CustomerKey,
            CASE
                WHEN age < 25 THEN '<25'
                WHEN age BETWEEN 25 AND 50 THEN '25-50'
                ELSE '>50'
            END AS age_group
    FROM customer_age
    )

SELECT age_group,
       MEDIAN(SalesAmount) AS median_revenue
FROM customer_age_group
RIGHT JOIN f_sales ON customer_age_group.CustomerKey = f_sales.CustomerKey
GROUP BY age_group;