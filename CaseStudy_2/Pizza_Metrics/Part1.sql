--A. Pizza Metrics
--1How many pizzas were ordered?
--2How many unique customer orders were made?
--3How many successful orders were delivered by each runner?
--4How many of each type of pizza was delivered?
--5How many Vegetarian and Meatlovers were ordered by each customer?
--6What was the maximum number of pizzas delivered in a single order?
--7For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--8How many pizzas were delivered that had both exclusions and extras?
--9What was the total volume of pizzas ordered for each hour of the day?
--10What was the volume of orders for each day of the week?
use master;
--Q1 How many pizzas were ordered?
with q1 as(select count(*) as Pizzas_ordered from
dbo.customer_orders co left join master.dbo.runner_orders ro
on co.order_id=ro.order_id),
q2 as(select count(*) as Pizzas_cancelled from
dbo.customer_orders co left join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is NULL)
select * from q1,q2;

--Q2 How many unique customer orders were made? Assumption. If the order has been cancelled it wasn't counted
select count(distinct co.order_id) as Unique_Customer from customer_orders co
left join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is not NULL;

--Q3 How many successful orders were delivered by each runner?
select runner_id, count(order_id) as Successful_Delivery
from runner_orders
where pickup_time is not NULL
group by runner_id;

--Q4 How many of each type of pizza was delivered?
select cast(pizza_name as nvarchar(25)) as Pizza, count(co.order_id) as Times_Delivered from
runner_orders ro join customer_orders co
on ro.order_id = co.order_id
join pizza_names pn on co.pizza_id=pn.pizza_id
where ro.pickup_time is not null
group by cast(pizza_name as nvarchar(25));

--Q5 How many Vegetarian and Meatlovers were ordered by each customer?
select co.customer_id, cast(pizza_name as nvarchar(25)) as Pizza, count(co.order_id) as Times_Delivered from
runner_orders ro join customer_orders co
on ro.order_id = co.order_id
join pizza_names pn on co.pizza_id=pn.pizza_id
where ro.pickup_time is not null
group by co.customer_id, cast(pizza_name as nvarchar(25));

--Q6 What was the maximum number of pizzas delivered in a single order?
select top 1 ro.order_id, cast(pickup_time as date) as Pickup_Date, count(pizza_id) as ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by ro.order_id, cast(pickup_time as date)
order by ordered desc;

--Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, case when exclusions is not null or extras is not null then 'At least 1 change' else 'No change' end,
count(co.order_id) 
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by customer_id, case when exclusions is not null or extras is not null then 'At least 1 change' else 'No change' end;


--Q8 How many pizzas were delivered that had both exclusions and extras?
select 
count(co.order_id) as ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null and exclusions is not null and extras is not null;
--group by customer_id, case when exclusions is not null or extras is not null then 'At least 1 change' else 'No change' end

--Q9 What was the total volume of pizzas ordered for each hour of the day?
select DATEPART(hour, order_time) as ordered_hour, count(*) as Times_Ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by DATEPART(hour, order_time);

--Q10 What was the volume of orders for each day of the week?
select datename(WEEKDAY, order_time) as Day_Ordered, count(*) as Times_Ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by DATEname(WEEKDAY, order_time);