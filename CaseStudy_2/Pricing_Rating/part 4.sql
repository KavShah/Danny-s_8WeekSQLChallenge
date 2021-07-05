--D. Pricing and Ratings
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
--What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
--Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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
--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

--Q1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select pizza_id, case when pizza_id=1 then 12*count(pizza_id)
else 10*count(pizza_id) end as Total
from customer_orders co join runner_orders ro
on co.order_id=ro.order_id
where cancellation is null
group by pizza_id;


--Q2 What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
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



/* 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
 how would you design an additional table for this new dataset - 
 generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. */
 
 
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

------------------------------------------------------------

 /*4 Using your newly generated table - can you join all of the information together to form a table which has the following information 
 for successful deliveries?
    customer_id
    order_id
    runner_id
    rating
    order_time
    pickup_time
    Time between order and pickup
    Delivery duration
    Average speed
    Total number of pizzas
*/


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
                ROUND(avg((convert(float,distance) / convert(float,duration))*60),2) AS average_speed, 
		         COUNT(co.pizza_id) AS total_number_of_pizzas, 
                                            rat.rating
                                            
FROM customer_orders co
JOIN rating rat
ON rat.customer_id = co.customer_id AND rat.order_id = co.order_id
JOIN runner_orders ro
ON rat.runner_id = ro.runner_id AND rat.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.order_id, rat.customer_id, rat.pizza_id, rat.order_id, rat.runner_id, co.order_time, ro.pickup_time, ro.duration, rat.rating;

------------------------
UPDATE stats 
SET time_between_order_and_pickup = datediff(minute ,order_time, pickup_time);

------------------------------------------------------------

/* 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries? */

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


--BONUS Qs
  --If Danny wants to expand his range of pizzas - 
  --how would this impact the existing data design? 
  --Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

  INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (3, 'Supreme Pizza');

  INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

  select * from pizza_names;
  select * from pizza_recipes;