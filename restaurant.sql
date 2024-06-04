create database restaurant_db;
use restaurant_db;
select * from restaurant;

/*Convertung order_date from text to date format*/
select str_to_date(left(order_date, 10), "%d-%c-%Y")
from order_details;
alter table order_details
add column orderdate date;

set sql_safe_updates = 0;

update order_details
set orderdate = str_to_date(left(order_date, 10), "%d-%c-%Y");

select order_date, orderdate
from order_details;

alter table order_details
add column order_time time;

update order_details
set order_time = convert(right(order_date,5), time);

alter table order_details
drop order_date;

select * from order_details;

use restaurant_db;

/*Restaurant*/
select count(distinct restaurant_id)
from restaurant;

/*Cuisines*/
select count(distinct cuisine)
from restaurant;

/*orders*/
select count(distinct order_id)
from order_details;

/*7. category wise sales, orders, rating*/
select category, count(distinct restaurant_id) as noof_restaurants, count(order_id) as noof_orders,
                                              round(avg(food_rating), 2) as f_rating, 
                                              round(avg(delivery_rating), 2) as d_rating
from restaurant inner join order_details using (restaurant_id) 
group by category
order by noof_orders desc;

/*8 number of restaurants in each zone*/
select zone, count(DISTINCT restaurant_id) as no_of_restaurants
from restaurant
group by zone
order by count(restaurant_id) desc;

/*8 no of orders by zone*/
select zone, count(DISTINCT order_id) as no_of_orders
from order_details o inner join restaurant using(restaurant_id)
group by zone
order by count(order_id) desc;

/*8. which customer ordered the most*/
select customer_name, count(DISTINCT order_id) as no_of_orders
from restaurant inner join order_details using (restaurant_id)
group by customer_name
order by no_of_orders desc
limit 1;

/*9 most ordered cuisine*/
with t as (select cuisine, count(order_id) as cnt, rank() over(order by count(order_id) desc) as rnk
from restaurant inner join order_details using (restaurant_id)
group by cuisine
order by count(order_id) desc) select cuisine, cnt from t where rnk = 1;
 
/*9 zonewise most ordered cuisine*/
with t as (select zone, cuisine, count(order_id) as orders
from restaurant inner join order_details using(restaurant_id)
group by zone, cuisine
order by orders), a as (select *, rank() over(partition by zone order by orders desc) as rnk from t)
select zone, cuisine, orders from a where rnk = 1;

/*10. top 5 restaurants delivery rating and their avg delivery time*/
select restaurant_name, round(avg(delivery_time),0) as avg_time,
                       round(avg(delivery_rating),2) as d_rating
from restaurant r inner join order_details o using(restaurant_id)
group by restaurant_name
order by d_rating asc
limit 5;

alter table order_details  /*Renamed coulmn delivery time taken */
rename column `delivery_time_taken (mins)` to delivery_time;

/*10. top 5 restaurant by food rating*/
select restaurant_name, round(avg(food_rating),1) as f_rating
from restaurant inner join order_details using(restaurant_id)
group by restaurant_name
order by f_rating asc
limit 5;

/*11. rush hours*/
with t as (select order_id, time_format(order_time, "%h %p") as o_time from order_details) 
select o_time, count(order_id) as orders from t
group by o_time
order by orders desc;

/*11. Number of orders received by zones during rush hour by each zone and category.*/
with k as (select category, zone, time_format(order_time, "%h %p") as o_time, count(order_id) as noof_orders
from order_details inner join restaurant using(restaurant_id)
group by zone, category, o_time)
select *
from k 
where o_time = "02 pm"
order by category, noof_orders desc;

select distinct customer_name, count(distinct order_id) as no_of_orders
from restaurant inner join order_details using (restaurant_id)
group by customer_name
order by no_of_orders desc;
 
/*Restaurants in each category*/
select category, count(distinct restaurant_id)
from restaurant
group by category;

/*res with max and min orders*/
(select restaurant_name, count(order_id) as noof_Orders
from restaurant inner join order_details using (restaurant_id) 
group by restaurant_name
order by noof_Orders desc
limit 1)
union 
(select restaurant_name, count(order_id) as noof_Orders
from restaurant inner join order_details using (restaurant_id) 
group by restaurant_name
order by noof_Orders asc
limit 1);

/*zone by avg sales*/
select zone, round(avg(order_amt),2) as avg_sales
from restaurant inner join order_details using (restaurant_id) 
group by zone
order by avg_sales desc;

/*category wise avg-sales*/
with k as (select distinct category, sum(order_amt) as total_sales
from restaurant inner join order_details using (restaurant_id)
group by category
order by total_sales desc), m as (select sum(total_sales) as sales from k) 
select category, round((total_sales/ sales), 2) as percent_sales
from m, k;

select count(order_id)
from order_details;

select category, count(distinct restaurant_id)
from restaurant
group by category;
