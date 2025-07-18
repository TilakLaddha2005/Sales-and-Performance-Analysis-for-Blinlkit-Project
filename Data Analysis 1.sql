---------------------------------------------------------------
-- 1. Yearly Average Sales Trend by Outlet Type

select 
outlet_type,
dense_rank() over(partition by outlet_type order by outlet_establishment_year) asc,
outlet_establishment_year as years,
avg(sales) as average_sales
from data_
group by outlet_type , outlet_establishment_year;

-- 2. Top 5 Selling Item Types by Total Sales

select 
item_type,
sum(sales) as total_sales
from data_
group by item_type
order by sum(sales) desc
limit 5;

-- 3. Sales Distribution Based on Rating Buckets

select 
case when rating > 4.5 then 'high'
     when rating > 4 then 'medium'
	 when rating > 3.5 then 'fine'
	 else 'low' end as review,
count(*) as total_orders,
cast(sum(sales) as decimal(10,2)) as total_sales
from data_
group by review
order by sum(sales) desc;

-- 4. YOY (Year-over-Year) Sales Analysis

select 
outlet_establishment_year as year,
cast(sum(sales) as decimal(10,2)) as total_sales ,
cast(lag(sum(sales)) over(order by outlet_establishment_year) as decimal(10,2)) as prev_year_sales,
(cast(((sum(sales) - lag(sum(sales)) over(order by outlet_establishment_year)) * 100 
/ lag(sum(sales)) over(order by outlet_establishment_year)) as decimal(10,2))) as yoy_analysis  
from data_
group by outlet_establishment_year

-- 5. Detect Underperforming Outlets (Below Avg Sales per Outlet Type)

select 
outlet_type,
sum(sales) as total_sales,
avg(sum(sales)) over(partition by outlet_type) as avg_sales_by_type,
case when sum(sales) < avg(sum(sales)) over(partition by outlet_type) then 'underperforming'
     else 'performing' end as performance
from data_
group by outlet_type;

-- 6. Find Items with Consistently High Ratings and High Sales

select 
item_identifier,
cast(avg(rating) as decimal(10,2)) as avg_rating,
cast(sum(sales) as decimal(10,2)) as totaL_sales
from data_
group by item_identifier 
having avg(rating) >= 4.0 and sum(sales) > (select avg(sales) from data_)
order by sum(sales) desc limit 5;

-- 7. Sales Variability (Standard Deviation) by Outlet

SELECT 
  Outlet_Identifier,
  STDDEV(Sales) AS Sales_Std_Dev
FROM data_
GROUP BY Outlet_Identifier
ORDER BY Sales_Std_Dev DESC;

-- 8. Top Gainers and Decliners: Outlet Performance YoY Delta

with yearly_sales as(
select 
outlet_type,
outlet_establishment_year as year,
cast(sum(sales) as decimal(10,2)) as yearly_sales
from data_ 
group by outlet_type , outlet_establishment_year)

select *,
lag(yearly_sales) over(partition by outlet_type order by year) as prev_year_sales,
yearly_sales - lag(yearly_sales) over(partition by outlet_type order by year) as sales_delta
from yearly_sales
order by Sales_Delta desc nulls last;

-- 9. Outlet Sales Contribution Compared to Market Average

select 
outlet_identifier,
sum(sales) as outlet_revenue,
(select avg(sales) from data_) as market_avg_sales,
case when (sum(sales) > (select avg(sales) from data_)) then 'above market avg'
     else 'below market avg' end as market_analysis
from data_
group by outlet_identifier;

-- 10. Identify Products with Sales Drop Despite High Rating

with item_data as(
select 
item_identifier,
avg(sales) as avg_sales,
avg(rating) as avg_rating
from data_
group by item_identifier)

select *
from item_data
where avg_rating > 4 and avg_sales < (select avg(sales) from data_)
order by avg_sales desc limit 7;

---------------------------------------------------------------