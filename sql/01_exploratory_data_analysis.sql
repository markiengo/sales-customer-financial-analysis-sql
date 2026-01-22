/*
01_data_exploration_and_quality.sql

Purpose:
- Explore database schema and core dimensions
- Perform data quality validation on sales data
- Establish baseline financial and customer metrics
*/

use DataWarehouseAnalytics;
go

-- Step 1: database exploration
	select * from INFORMATION_SCHEMA.tables 
	-- columns
	select * from INFORMATION_SCHEMA.columns
	where table_name = 'gold.dim_customers';

-- Step 2: Data quality checks
	-- completeness checks of critical fields
	-- critical fields defined by: defines the level of detail, required to join tables, used to calculate metrics, anchor time, or affect your analysis
	select 
		sum(case when order_number is null then 1 else 0 end) as null_order_number,
		sum(case when product_key is null then 1 else 0 end) as null_product_key,
		sum(case when customer_key is null then 1 else 0 end) as null_customer_key,
		sum(case when order_date is null then 1 else 0 end) as null_order_date, 
		sum(case when quantity <= 0 then 1 else 0 end) as bad_quantity,
		sum(case when price <= 0 then 1 else 0 end) as bad_price, 
		sum(case when sales_amount <= 0 then 1 else 0 end) as bad_sales
	from sales; 

	-- Assess impact of missing values on rows, revenue, and units
	select count(*) as total_rows, sum(sales_amount) as total_revenue, sum(quantity) as total_quantity from sales
	select count(*) as rows_with_null_date, sum(sales_amount) as revenue_with_null_date, sum(quantity) as units_with_null_date
	from sales 
	where order_date is null;

/*
Data quality handling principles:
- Avoid assumptions or silent backfilling
- Always assess the business impact before excluding data

Approach:
- Low impact: safely exclude from analysis
- Material revenue impact: identify a reasonable proxy and document the decision
- High impact with no proxy: exclude from affected KPIs but retain in overall totals
*/


-- Step 3: dimensions exploration
	-- explore where our customers come from 
	select distinct country from customers; 

	-- explore all categories -> subcategory -> product
	select distinct category, subcategory, product_name from products
	order by 1,2,3;

-- Step 4: date exploration 
	-- date of first and last order 
	select min(order_date) as first_order, max(order_date) as last_order,
	datediff(month, min(order_date), max(order_date)) as order_range_month
	from sales;

	-- youngest and oldest customer
	select min(birthdate) as oldest_birthdate,
	datediff(year, min(birthdate), getdate()) as age_old,
	max(birthdate) as youngest_birthdate,
	datediff(year, max(birthdate), getdate()) as age_young
	from customers;

-- Step 5: measures exploration 
-- Key metrics: highest level of aggregations
	-- total sales
	select sum(sales_amount) as total_sales from sales;

	-- quantity of items sold
	select sum(quantity) as total_quantity from sales;

	-- ASP: average selling price by product 
	select sum(sales_amount) / sum(quantity) as average_selling_price 
	from sales 
	
	-- total number of orders
	select count (distinct order_number) as total_orders from sales; -- some orders have multiple products

	-- total number of products
	select count(product_key) as total_products from products;
	select count (distinct product_key) as total_products from products; -- for double check

	-- total number of customers: this is just high-level reach
	select count(customer_key) as total_customers from customers;

	-- total number of customers that has placed an order, not every customer is a converted sale
	select count(distinct customer_key) as total_converted_customers from sales; 

	-- generate a report
	select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from sales
	union all 
	select 'Total Quantity', sum(quantity) from sales
	union all 
	select 'Average Selling Price', (sum(sales_amount) / sum(quantity)) as average_selling_price from sales 
	union all 
	select 'Total orders', count (distinct order_number) from sales
	union all 
	select 'Total products', count(product_key) from products
	union all
	select 'Total converted customers', count(distinct customer_key) from sales; 

-- Step 6: Magnitudes by Dimensions. 
	-- total converted customers by countries
	select c.country, count(distinct s.customer_key) as total_customers from sales as s
	join customers as c
	on c.customer_key = s.customer_key 
	group by country
	order by total_customers desc; 

	-- total customers by gender
	select gender, count(*) as total_customers from customers
	group by gender 
	order by total_customers desc; 

	-- total products by category 
	select category, count(*) as total_products from products
	group by category 
	order by total_products desc;

	-- average costs by category
	select category, avg(cost) as average_costs from products
	group by category 
	order by average_costs desc;

	-- asp by category and products
	select category, product_name, sum(sales_amount) / sum(quantity) as average_selling_price
	from sales as s
	join products as p
	on p.product_key = s.product_key
	group by p.category, p.product_name
	order by p.category asc, average_selling_price desc;

	-- total revenue by category - replace syntax for products
	select category, sum(s.sales_amount) as total_revenue
	from products as p
	join sales as s
	on p.product_key = s.product_key
	group by category 
	order by total_revenue desc; 

	-- total revenue and number of purchases by customer
	select concat(c.first_name, ' ', c.last_name) as customer_full, sum(s.sales_amount) as total_revenue,
	count(s.customer_key) as number_of_purchases
	from customers as c
	join sales as s
	on c.customer_key = s.customer_key
	group by s.customer_key, c.first_name, c.last_name
	order by total_revenue desc, number_of_purchases desc;

	-- total items sold + total revenue by country
	select c.country, count(s.product_key) as total_items_sold, sum(s.sales_amount) as total_revenue
	from sales as s
	join customers as c
	on s.customer_key = c.customer_key
	group by c.country
	order by total_revenue desc, total_items_sold desc;

-- Step 7: ranking dimensions by measure
	-- top 5 revenue by products (optional: with rank)
	with product_revenue as (
	select p.product_name, sum(s.sales_amount) as total_revenue
	from sales as s
	join products as p 
	on p.product_key = s.product_key
	group by p.product_name
	)
	select product_name, total_revenue, rank() over (order by total_revenue desc) as revenue_rank
	from product_revenue;

	-- bottom 5 revenue by products
	select p.product_name, sum(s.sales_amount) as total_revenue
	from sales as s 
	join products as p
	on p.product_key = s.product_key
	group by p.product_name
	order by total_revenue asc;

	-- top 5 customers by revenue
	with product_revenue as (
	select c.first_name as 'First Name', c.last_name as 'Last Name', sum(s.sales_amount) as total_revenue
	from sales as s
	join customers as c 
	on c.customer_key = s.customer_key
	group by c.first_name, c.last_name
	)
	select [First Name], [Last Name], total_revenue, rank() over (order by total_revenue desc) as revenue_rank
	from product_revenue;

	-- bottom 5 customers by number of purchases
	with order_numbers as (
	select c.first_name as 'First Name', c.last_name as 'Last Name', count(s.order_number) as total_orders
	from sales as s
	join customers as c 
	on c.customer_key = s.customer_key
	group by c.customer_key, c.first_name, c.last_name
	)
	select top 5 [First Name], [Last Name], total_orders, rank() over (order by total_orders asc) as order_rank
	from order_numbers;
