# SQL Project: Sales & Product Data Analysis :

Overview

This project involves analyzing sales, customer, and product data using SQL. The dataset consists of multiple fact and dimension tables that provide insights into 
manufacturing costs, sales performance, pricing, and customer segmentation.

![image](https://github.com/user-attachments/assets/6d65632a-4ddf-46ed-a2ef-c0b54a9f2d34)

## Data Model ##
The project follows a star schema with the following tables:

## Fact Tables:

fact_sales_monthly

Contains transaction data including customer_code, fiscal_year, and sold_quantity.
fact_manufacturing_cost

Stores manufacturing cost data with attributes like manufacturing_cost and cost_year, linked to product_code.
fact_gross_price

Holds product price data per fiscal_year and product_code.
fact_pre_invoice_discount

Includes discount percentages per customer_code and fiscal_year.
## Dimension Tables

dim_product
Contains product details like product_code, product_name, segment, variant, etc.
dim_customer
Stores customer-related details like customer_code, customer_name, market, platform, region, and sub_zone.

Objective
The main goal of the project is to solve various business requests using SQL queries. The focus areas include:

checkout ad-hoc-requests.pdf
