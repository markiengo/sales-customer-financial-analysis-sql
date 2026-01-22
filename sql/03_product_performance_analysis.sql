-- Part 3: Product Performance Analysis
-- Evaluate yearly product sales performance relative to historical averages and prior-year results
-- Aggregate yearly sales by product to establish a performance baseline
with yearly_product_sales as (
	select 
		year(s.order_date) as order_year,
		p.product_name,
		sum(s.sales_amount) as current_sales
	from sales as s
	left join products as p 
	on s.product_key = p.product_key 
	where order_date is not null
	group by year(s.order_date), p.product_name
)
select 
	order_year,
	product_name, 
	current_sales, 
	avg(current_sales) over (partition by product_name) as avg_sales,
	current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
	case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg' 
		 when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
		 else 'avg' end avg_change,

	-- Year-over-year (YoY) performance comparison
	lag(current_sales) over (partition by product_name order by order_year asc) previousyear_sales,
	current_sales - lag(current_sales) over (partition by product_name order by order_year asc) as different_previous_year,
	case when current_sales - lag(current_sales) over (partition by product_name order by order_year asc) > 0 then 'Increase' 
		 when current_sales - lag(current_sales) over (partition by product_name order by order_year asc) < 0 then 'Decrease'
		 else 'No Change' end previous_year_change
from yearly_product_sales 
order by product_name, order_year;
