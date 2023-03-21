{
    "metadata": {
        "kernelspec": {
            "name": "SQL",
            "display_name": "SQL",
            "language": "sql"
        },
        "language_info": {
            "name": "sql",
            "version": ""
        }
    },
    "nbformat_minor": 2,
    "nbformat": 4,
    "cells": [
        {
            "cell_type": "markdown",
            "source": [
                "**Q4.1:**"
            ],
            "metadata": {
                "azdata_cell_guid": "a8a84413-2902-490c-83bd-513dd0d8f530"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "WITH sales AS (\r\n",
                "    SELECT ProductName,\r\n",
                "           SalesTerritoryRegion,\r\n",
                "           SUM(SalesAmount) AS total_sales\r\n",
                "    FROM f_sales\r\n",
                "    LEFT JOIN d_sales_territory ON f_sales.SalesTerritoryKey = d_sales_territory.SalesTerritoryKey\r\n",
                "    LEFT JOIN d_product ON f_sales.ProductKey = d_product.ProductKey\r\n",
                "    GROUP BY ProductName, SalesTerritoryRegion\r\n",
                "    )\r\n",
                "\r\n",
                "WITH ranked_sales AS (\r\n",
                "    SELECT ProductName,\r\n",
                "           SalesTerritoryRegion,\r\n",
                "           total_sales,\r\n",
                "           RANK() OVER (PARTITION BY SalesTerritoryRegion ORDER BY total_sales DESC) AS sales_rank\r\n",
                "    FROM sales\r\n",
                "    )\r\n",
                "\r\n",
                "SELECT ProductName,\r\n",
                "       SalesTerritoryRegion,\r\n",
                "       total_sales\r\n",
                "FROM ranked_sales\r\n",
                "WHERE sales_rank <= 3;"
            ],
            "metadata": {
                "azdata_cell_guid": "a23c793c-1d1a-4510-8b63-2ea5a67d3520",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "**Q4.2:**"
            ],
            "metadata": {
                "azdata_cell_guid": "aca4927d-eab9-45bf-b4eb-9fa012255cd3"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "WITH purchases AS (\r\n",
                "    SELECT CustomerKey,\r\n",
                "           SalesTerritoryRegion,\r\n",
                "           OrderDate,\r\n",
                "           ROW_NUMBER() OVER (PARTITION BY CustomerKey ORDER BY OrderDate) AS purchase_number\r\n",
                "    FROM f_sales\r\n",
                "    LEFT JOIN d_sales_territory ON f_sales.SalesTerritoryKey = d_sales_territory.SalesTerritoryKey\r\n",
                "    )\r\n",
                "\r\n",
                "WITH first_second_purchases AS (\r\n",
                "    SELECT CustomerKey,\r\n",
                "           SalesTerritoryRegion,\r\n",
                "           MIN(CASE WHEN purchase_number = 1 THEN OrderDate END) AS first_purchase,\r\n",
                "           MIN(CASE WHEN purchase_number = 2 THEN OrderDate END) AS second_purchase\r\n",
                "    FROM purchases\r\n",
                "    WHERE purchase_number IN (1, 2)\r\n",
                "    GROUP BY CustomerKey, SalesTerritoryRegion\r\n",
                "    )   \r\n",
                "\r\n",
                "SELECT SalesTerritoryRegion,\r\n",
                "       AVG(DATEDIFF(day, first_purchase, second_purchase)) AS avg_days_between_first_second_purchase\r\n",
                "FROM first_second_purchases\r\n",
                "GROUP BY SalesTerritoryRegion;"
            ],
            "metadata": {
                "azdata_cell_guid": "b117db27-d78b-4717-b837-7fbc86827445",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "**Q4.3:**"
            ],
            "metadata": {
                "language": "sql",
                "azdata_cell_guid": "12a7b18d-437e-4522-9526-553a8cd58db6"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "WITH customer_age AS (\r\n",
                "    SELECT  CustomerKey, \r\n",
                "            DATEDIFF(YY, BirthYear, 2014) AS age\r\n",
                "    FROM d_customer\r\n",
                "    )\r\n",
                "    \r\n",
                "WITH  customer_age_group AS (\r\n",
                "    SELECT  CustomerKey,\r\n",
                "            CASE\r\n",
                "                WHEN age < 25 THEN '<25'\r\n",
                "                WHEN age BETWEEN 25 AND 50 THEN '25-50'\r\n",
                "                ELSE '>50'\r\n",
                "            END AS age_group\r\n",
                "    FROM customer_age\r\n",
                "    )\r\n",
                "\r\n",
                "SELECT age_group,\r\n",
                "       MEDIAN(SalesAmount) AS median_revenue\r\n",
                "FROM customer_age_group\r\n",
                "RIGHT JOIN f_sales ON customer_age_group.CustomerKey = f_sales.CustomerKey\r\n",
                "GROUP BY age_group;"
            ],
            "metadata": {
                "azdata_cell_guid": "32c3723c-1755-43db-98f0-e1223dc7ff3a",
                "language": "sql",
                "tags": []
            },
            "outputs": [],
            "execution_count": null
        }
    ]
}