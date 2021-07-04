# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study # - Pricing and Rating
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/W2.png" width=50% height=50%>

## Table Of Contents
  - [Case Study's Question](#case-studys-questions)
  - [Solution](#solutions)

 <br /> 

## Case Study's Questions
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
	Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	--customer_id
	--order_id
	--runner_id
	--rating
	--order_time
	--pickup_time
	--Time between order and pickup
	--Delivery duration
	--Average speed
	--Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
 
 <br /> 

## Solutions

### **Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```sql
select pizza_id, case when pizza_id=1 then 12*count(pizza_id)
else 10*count(pizza_id) end as Total
from customer_orders co join runner_orders ro
on co.order_id=ro.order_id
where cancellation is null
group by pizza_id;
```
**Result:**
pizza_id	Total
1			108
2			30

**Answer:**


---

### **Q2 What if there was an additional $1 charge for any pizza extras?
		**Add cheese is $1 extra**
```sql
select co.pizza_id, co.order_id, value as ext 
into #tmp
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
cross apply string_split(extras, ',')
where ro.cancellation is null;

select pizza_id, case when pizza_id=1 and ext = 4  then  12*count(pizza_id)+1
when pizza_id=1 and ext is not null then 12*count(pizza_id)+1
when pizza_id=2 and ext = 4  then  10*count(pizza_id)+1
else 10*count(pizza_id)+1
end as Total
from #tmp
group by pizza_id, ext;
```

**Result:**

**Answer**: Still Working on Query


---

### **Q3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
		**how would you design an additional table for this new dataset - 
		**generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**
```sql
CREATE TABLE rating(
                    customer_id int, 
					runner_id int, 
                    order_id int,
					pizza_id int,
					rating int
);

------------
INSERT INTO rating(
                   customer_id, 
				   runner_id,
				   pizza_id,
                   order_id
) 
   SELECT DISTINCT customer_id, 
		     runner_id,
			 co.pizza_id,
	       co.order_id 

FROM customer_orders co 
JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE cancellation IS NULL;

------------
UPDATE rating
SET rating = CASE 
         WHEN order_id IN (2,10) THEN 4
	     WHEN order_id = 3 THEN 1
	     WHEN order_id = 1 THEN 5
	     WHEN order_id IN (7,8) THEN 3
	     WHEN order_id = 4 THEN 4
	     WHEN order_id = 5 THEN 2
	     END;

```

**Result:**
customer_id	runner_id	order_id	pizza_id	rating
101				1		1			1			5
101				1		2			1			4
102				1		3			1			1
102				1		3			2			1
102				2		8			1			3
103				2		4			1			4
103				2		4			2			4
104				1		10			1			4
104				3		5			1			2
105				2		7			2			3
**Answer: **

---

### **Q4 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    **customer_id
    **order_id
    **runner_id
    **rating
    **order_time
    **pickup_time
    **Time between order and pickup
    **Delivery duration
    **Average speed
    **Total number of pizzas**
```SQL
Create TABLE stats      (customer_id int,
						 pizza_id int,
					     order_id int, 
					     runner_id int, 
                         rating int, 
						 order_time datetime, 
				         pickup_time datetime, 
						 time_between_order_and_pickup decimal(5,2),
                         delivery_duration decimal(5,2), 
                         average_speed decimal(5,2), 
						 total_number_of_pizzas int);

----------------------
INSERT INTO stats (
                         customer_id, 
						 pizza_id,
					     order_id,
					     runner_id, 
					     order_time, 
                         pickup_time, 
						 delivery_duration,
						 average_speed, 
						 total_number_of_pizzas, 
						 rating
)
                                           
                      SELECT DISTINCT 
					  rat.customer_id,
					  rat.pizza_id,
                      rat.order_id, 
					  rat.runner_id, 
				      co.order_time, 
                      ro.pickup_time, 
                      ro.duration,
                ROUND(avg((convert(float,distance) / convert(float,duration))*60), 2) AS average_speed, 
		         COUNT(co.pizza_id) AS total_number_of_pizzas, 
                                            rat.rating
                                            
FROM customer_orders co
JOIN rating rat
ON rat.customer_id = co.customer_id AND rat.order_id = co.order_id
JOIN runner_orders ro
ON rat.runner_id = ro.runner_id AND rat.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.order_id, rat.customer_id, rat.pizza_id, rat.order_id, rat.runner_id, co.order_time, ro.pickup_time, ro.duration, rat.rating;


UPDATE stats 
SET time_between_order_and_pickup = datediff(minute ,order_time, pickup_time);

```
**Result**
customer_id	pizza_id	order_id	runner_id	order_time				pickup_time				duration	average_speed	total_number_of_pizzas	rating
101				1			1		1			2020-01-01 18:05:02.000	2020-01-01 18:15:34.000	32				37.5		1						5
101				1			2		1			2020-01-01 19:00:52.000	2020-01-01 19:10:54.000	27				44.44		1						4
102				1			3		1			2020-01-02 23:51:23.000	2020-01-03 00:12:37.000	20				39			2						1
102				2			3		1			2020-01-02 23:51:23.000	2020-01-03 00:12:37.000	20				39			2						1
103				1			4		2			2020-01-04 13:23:46.000	2020-01-04 13:53:03.000	40				34.5		3						4
103				2			4		2			2020-01-04 13:23:46.000	2020-01-04 13:53:03.000	40				34.5		3						4
104				1			5		3			2020-01-08 21:00:29.000	2020-01-08 21:10:57.000	15				40			1						2
105				2			7		2			2020-01-08 21:20:29.000	2020-01-08 21:30:45.000	25				60			1						3
102				1			8		2			2020-01-09 23:54:33.000	2020-01-10 00:15:02.000	15				92			1						3
104				1			10		1			2020-01-11 18:34:49.000	2020-01-11 18:50:20.000	10				60			2						4
---

### **Q5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
		**How much money does Pizza Runner have left over after these deliveries?**
```SQL
WITH sal AS (

	     SELECT SUM(CASE 
			WHEN convert(varchar,piz_nam.pizza_name) = 'Meatlovers' THEN 12
                        WHEN convert(varchar,piz_nam.pizza_name) = 'Vegetarian' THEN 10 
		        END) AS sales, 
			SUM(convert(int,run_ord.distance)) as dist
	     FROM customer_orders cus_ord
	     JOIN pizza_names piz_nam
	     ON cus_ord.pizza_id = piz_nam.pizza_id
	     JOIN runner_orders run_ord
	     ON run_ord.order_id = cus_ord.order_id 
	     AND run_ord.cancellation IS NULL),
       
    expen AS (
		 SELECT SUM(convert(int,run_ord.distance)) * 0.30 AS expenses
	     FROM runner_orders run_ord)
SELECT ROUND((sales - expenses), 2) AS profit
FROM sal, expen;


```
**Result:**
profit
94.80
**Answer:**

