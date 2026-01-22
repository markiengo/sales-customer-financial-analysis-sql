-- Part 4: Part-to-Whole Analysis
-- Assess how each product category contributes to total sales
  -- Aggregate total sales by category to calculate contribution percentages
with category_sales as ( 
select
	category,
	sum(sales_amount) as total_sales
from sales as s
left join products as p
	on s.product_key = p.product_key 
group by category
)
select 
	category,
	total_sales, 
	sum(total_sales) over () as overall_sales,
	concat(round ((cast (total_sales as float) / sum(total_sales) over ()) *100, 2), '%') as percentage_of_total
from category_sales 
order by total_sales desc;
