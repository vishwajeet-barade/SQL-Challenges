use gdb023;

/*1.  Provide the list of markets in which customer  "Atliq  Exclusive"  operates its 
business in the  APAC  region.*/

select distinct(market) as list_of_market
from dim_customer
where customer = 'Atliq Exclusive' and region = 'APAC' ;

/*2.  What is the percentage of unique product increase in 2021 vs. 2020? The 
final output contains these fields, 
unique_products_2020 
unique_products_2021 
percentage_chg */

with cte1 as (
select distinct(count(product_code)) as result1 from fact_gross_price where fiscal_year = 2020
) , cte2 as (
select distinct(count(product_code)) as result2 from fact_gross_price where fiscal_year = 2021
)
select result1 as unique_products_2020, result2 as unique_products_2021 ,(result2 - result1)*100/result1 as percentage_change
from cte1 ,cte2;

/*3.  Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 
2 fields, 
segment 
product_count */

select segment , count(distinct(product_code)) as product_count
from dim_product
group by segment
order by product_count desc;

/* 4.  Follow-up: Which segment had the most increase in unique products in 
2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference */

with cte1 as (
select fgp.product_code , fgp.fiscal_year , dp.segment 
from fact_gross_price as fgp
left join dim_product as dp
on fgp.product_code = dp.product_code
) ,cte2 as (
select segment , count(distinct(product_code)) as result1
from cte1
where fiscal_year = 2020
group by segment
order by result1 desc
) , cte3 as (
select segment , count(distinct(product_code)) as result2
from cte1
where fiscal_year = 2021
group by segment
order by result2 desc
)
select cte2.segment , cte2.result1 , cte3.result2 , (cte3.result2 - cte2.result1) as difference
from cte2
left join cte3
on cte2.segment = cte3.segment
order by difference desc;

/* 5.  Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost */

select * from fact_manufacturing_cost;
# for 2020 cost year

with cte as (
select * 
from fact_manufacturing_cost
where cost_year = 2020
) , cte2 as (
select product_code , manufacturing_cost
from cte
where manufacturing_cost = ( select max(manufacturing_cost) from cte)
UNION 
select product_code , manufacturing_cost
from cte
where manufacturing_cost = ( select min(manufacturing_cost) from cte)
)
select cte2.product_code , pr.product , cte2.manufacturing_cost
from cte2 
left join dim_product as pr
on cte2.product_code = pr.product_code;

# for 2021 cost year 

with cte as (
select * 
from fact_manufacturing_cost
where cost_year = 2021
) , cte2 as (
select product_code , manufacturing_cost
from cte
where manufacturing_cost = ( select max(manufacturing_cost) from cte)
UNION 
select product_code , manufacturing_cost
from cte
where manufacturing_cost = ( select min(manufacturing_cost) from cte)
)
select cte2.product_code , pr.product , cte2.manufacturing_cost
from cte2 
left join dim_product as pr
on cte2.product_code = pr.product_code;

/* 6.  Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage */

select * from fact_pre_invoice_deductions;

select fpid.customer_code ,dc.customer ,  fpid.pre_invoice_discount_pct
from fact_pre_invoice_deductions as fpid
left join dim_customer as dc
on fpid.customer_code = dc.customer_code
where fpid.pre_invoice_discount_pct > (select avg(pre_invoice_discount_pct) from fact_pre_invoice_deductions) and fpid.fiscal_year =2021 and dc.market = 'India'
order by pre_invoice_discount_pct
limit 5 ;

/* 7.  Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month  .  This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month 
Year 
Gross sales Amount */

select * from fact_gross_price;
select * from fact_sales_monthly;

with cte as (
select fsm.date , fsm.product_code , fsm.customer_code , fsm.sold_quantity , fgp.gross_price 
from fact_sales_monthly as fsm
left join fact_gross_price as fgp
on fsm.product_code = fgp.product_code and fsm.fiscal_year = fgp.fiscal_year
) , cte2 as (
select month(cte.date) as Month , year(cte.date) as Year , sum(cte.sold_quantity * cte.gross_price) as Gross_sales_amount
from cte 
left join dim_customer as dc
on cte.customer_code = dc.customer_code
where dc.customer = 'Atliq Exclusive'
group by Month ,Year
)
select * from cte2 where Gross_sales_amount = (select max(Gross_sales_amount) from cte2);

/* 8.  In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity */

select quarter(date) as Quarter , sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly 
where year(date) = 2020
group by Quarter
order by total_sold_quantity desc;

/* 9.  Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_mln 
percentage */

select * from fact_gross_price;
select * from fact_sales_monthly;
select distinct(channel) from dim_customer;

with cte1 as (
select fsm.customer_code , (fsm.sold_quantity *fgp.gross_price ) as gross_sales
from fact_sales_monthly as fsm
left join fact_gross_price as fgp
on fsm.product_code = fgp.product_code and fsm.fiscal_year = fgp.fiscal_year
where fsm.fiscal_year = 2021
) , cte2 as (
select dc.channel as channel , sum(gross_sales)/1000000 as gross_sales_mln 
from cte1 
left join dim_customer as dc
on cte1.customer_code = dc.customer_code
group by channel
) , cte3 as (
select sum(gross_sales)/1000000 as total_gross_sales 
from cte1
)
select cte2.channel , round(cte2.gross_sales_mln,1) as gross_sales_mln , round((cte2.gross_sales_mln/cte3.total_gross_sales),2) as percentage
from cte2 ,cte3;

/* 10.  Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these 
fields, 
division 
product_code 
product 
total_sold_quantity 
rank_order */ 

select *  from fact_sales_monthly where fiscal_year = 2021;
select * from dim_product;

with cte1 as (
select dp.division , fsm.product_code , dp.product , fsm.sold_quantity 
from fact_sales_monthly as fsm
left join dim_product as dp
on fsm.product_code = dp.product_code
where fsm.fiscal_year = 2021
) , cte2 as (
select division , product_code , sum(sold_quantity) as total_sold_quantity , rank() over(partition by division  order by sum(sold_quantity) desc) as rank_order
from cte1
group by division , product_code
)
select * 
from cte2
where rank_order<=3;




