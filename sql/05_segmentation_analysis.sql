-- Part 5: Segmentation Analysis
-- Segment products and customers into meaningful groups to support comparative analysis
  -- Segment products into cost-based bands to understand distribution across price ranges
with product_segment as (
select 
	product_key,
	product_name,
	cost,
	case when cost < 100 then 'Below 100'
		 when cost between 100 and 500 then '100-500'
		 when cost between 500 and 1000 then '500-1000'
	else 'Above 1000' end cost_range
from products 
)
select
	cost_range, 
	count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc;

-- Segment customers based on spending behavior and relationship duration
-- Categories reflect relative customer value and lifecycle stage

with customer_spending as (
select 
	c.customer_key, 
	sum(s.sales_amount) as total_spending, 
	min(order_date) as first_order, 
	max(order_date) as last_order,
	datediff(month, min(order_date), max(order_date)) as lifespan
from sales as s
left join customers as c
	on s.customer_key = c.customer_key 
group by c.customer_key
)
select 
	customer_segment,
	count(customer_key) as total_customers 
from (
select 
	customer_key, 
	total_spending, 
	lifespan, 
	case when total_spending >= 5000 and lifespan >= 12 then 'VIP'
		 when total_spending <= 5000 and lifespan >= 12 then 'Regular'
		 else 'New' end customer_segment
from customer_spending ) t 
group by customer_segment
order by total_customers desc; 
