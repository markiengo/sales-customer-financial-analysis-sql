/* Purpose:
- Analyze sales and customer trends over time
- Establish baseline monthly performance metrics
*/

-- Part 1: Monthly trend analysis
-- Evaluate sales, customer volume, and quantity trends over time

use DataWarehouseAnalytics;
GO
-- =========================================================
-- Monthly Sales and Customer Trends
-- =========================================================
-- Aggregates core metrics by month to observe growth patterns and seasonality in sales and customer activity

select 
	datetrunc(month, order_date) as order_month,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
	from sales
where order_date is not null
group by datetrunc(month, order_date)
order by datetrunc(month, order_date) asc;

-- Alternative date formatting approach for presenting time-based aggregates
select 
	format(order_date, 'yyyy-MMM') as order_year,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
	from sales
where order_date is not null
group by format(order_date, 'yyyy-MMM')
order by format(order_date, 'yyyy-MMM');

-- Part 2: Cumulative Analysis
-- Assess cumulative revenue growth across months
select
	order_month,
	total_sales,
	sum(total_sales) over (partition by order_month order by total_sales) as running_total_sales
from (
select 
	datetrunc(month, order_date) as order_month, -- monthly time grain for aggregation
	sum(sales_amount) as total_sales,
	avg(price) as avg_o
from sales
where order_date is not null
group by datetrunc(month, order_date)
) t;

-- Rank months by total sales to identify peak and lower-performing periods
select 
	order_date, 
	total_sales,
	rank() over (order by total_sales desc) as ranking_total_sales_by_month
from 
(
select 
	datetrunc(month, order_date) as order_date, 
	sum(sales_amount) as total_sales
from sales 
where order_date is not null
group by datetrunc(month, order_date)
) t;
