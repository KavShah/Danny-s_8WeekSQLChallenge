--B. Runner and Customer Experience
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)??
--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? ??
--Is there any relationship between the number of pizzas and how long the order takes to prepare?
--What was the average distance travelled for each customer?
--What was the difference between the longest and shortest delivery times for all orders?
--What was the average speed for each runner for each delivery and do you notice any trend for these values?
--What is the successful delivery percentage for each runner?

--Q1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT FLOOR(DATEDIFF(day,'2021-01-01', registration_date) / 7 + 1)  AS week_num , 
       COUNT(*) AS number_of_runners
FROM runners
GROUP BY FLOOR(DATEDIFF(day,'2021-01-01', registration_date ) / 7 + 1); 

--Q2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, avg(DATEDIFF(MINUTE,order_time,pickup_time)) as Average_Mins 
from dbo.customer_orders co join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where pickup_time is not null
group by runner_id;

--Q3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
with q1 as(
select ro.order_id, count(co.pizza_id) as Pizzas_Ordered
from dbo.customer_orders co join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is not NULL
group by ro.order_id),
q2 as(
select distinct ro.order_id, DATEDIFF(MINUTE,order_time,pickup_time) as Prepare_Time
from dbo.customer_orders co join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is not NULL
)
select q1.order_id, q1.Pizzas_ordered, q2.prepare_time
from q1 join q2 on q1.order_id=q2.order_id;

--Q4 What was the average distance travelled for each customer?
select customer_id, Avg(CONVERT(float, distance)) as 'AVGDistance_Covered(kms)'
from runner_orders ro join customer_orders co
on ro.order_id=co.order_id
where pickup_time is not null
group by customer_id
order by 1;

--Q5 What was the difference between the longest and shortest delivery times for all orders?
select max(convert(int,duration))-min(convert(int,duration)) as difference_between_delivery 
from runner_orders;

--Q6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
select order_id, runner_id,  Round(Avg(convert(float,distance)/convert(float,duration)*60),2) as 'Average_Speed(Kph)' from runner_orders
where pickup_time is not null
group by order_id, runner_id
order by 2;

--Q7 What is the successful delivery percentage for each runner?
with q1 as(select runner_id, count(order_id) as o1
from runner_orders
where pickup_time is not null
group by runner_id)
,
q2 as (select runner_id, count(order_id) as o2
from runner_orders
group by runner_id)
select q1.runner_id, (convert(float,q1.o1)/q2.o2)*100 as 'Sucessful Deliveries'
from q1 join q2
on q1.runner_id=q2.runner_id ;

