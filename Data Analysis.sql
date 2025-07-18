---------------------------------------------------------------

-- created a table 
create table data_(
Item_Fat_Content varchar(50),
Item_Identifier varchar(50),
Item_Type varchar(100),
Outlet_Establishment_Year int,
Outlet_Identifier varchar(50),
Outlet_Location_Type varchar(50),
Outlet_Size varchar(50),
Outlet_Type varchar(100),
Item_Visibility float,
Item_Weight float,
Sales float,
Rating float
);

---------------------------------------------------------------

-- data overview
select * from data_;

---------------------------------------------------------------

-- data cleaning

update data_
set item_fat_content = 
case 
when item_fat_content in ('LF', 'low fat' , 'lf') then 'Low Fat'
when item_fat_content = 'reg' then 'Regular' else item_fat_content end 

---------------------------------------------------------------

-- kpi's 

-- total sales in millions

select cast(sum(data_.sales) / 1000000 as decimal(10,2)) as total_revenue_millions
from data_;

-- avg sales

select cast(avg(data_.sales) as decimal(10,0)) as avg_sales
from data_;

-- number of total orders

select count(*) as total_orders
from data_;

-- avg rating 

select cast(avg(rating) as decimal(10,1)) as avg_rating
from data_;

---------------------------------------------------------------

----- insights --------

-- all metrics by fat content

select item_fat_content ,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast(avg(sales) as decimal(10,2)) as avg_sales,
count(*) as total_orders,
cast(avg(rating) as decimal(10,2)) as avg_rating
from data_
group by item_fat_content ;

-- all metrics by item_type

select item_type ,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast(avg(sales) as decimal(10,2)) as avg_sales,
count(*) as total_orders,
cast(avg(rating) as decimal(10,2)) as avg_rating
from data_
group by item_type;

-- fat content by outlet for total sales

select outlet_identifier , dense_rank() over(partition by outlet_identifier order by sum(sales)),
item_fat_content , 
cast(sum(sales) as decimal(10,2)) as total_sales
from data_
group by outlet_identifier , item_fat_content

-- all metrics by outlet establishment

select outlet_establishment_year ,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast(avg(sales) as decimal(10,2)) as avg_sales,
count(*) as total_orders,
cast(avg(rating) as decimal(10,2)) as avg_rating
from data_
group by outlet_establishment_year
order by cast(sum(sales) as decimal(10,2));

-- percentage of sales by outlet size 

select 
outlet_size,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast((sum(sales) * 100 / (select sum(sales) from data_)) as decimal(10,2)) as pct_sales 
from data_
group by outlet_size
order by cast(sum(sales) as decimal(10,2)) desc;

-- all metrics by outlet location

select 
outlet_location_type,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast(avg(sales) as decimal(10,2)) as avg_sales,
count(*) as total_orders,
cast(avg(rating) as decimal(10,2)) as avg_rating
from data_
group by outlet_location_type
order by cast(sum(sales) as decimal(10,2)) desc;

-- all metrics by outlet type 

select 
outlet_type,
cast(sum(sales) as decimal(10,2)) as total_sales,
cast(avg(sales) as decimal(10,2)) as avg_sales,
count(*) as total_orders,
cast(avg(rating) as decimal(10,2)) as avg_rating
from data_
group by outlet_type
order by cast(sum(sales) as decimal(10,2)) desc;

---------------------------------------------------------------

