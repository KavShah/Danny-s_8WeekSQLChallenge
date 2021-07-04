--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
--What was the most commonly added extra?
--What was the most common exclusion?
--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

--Q1 What are the standard ingredients for each pizza?
with q1 as
(SELECT Pizza_Id, value  
FROM Pizza_recipes  
    CROSS APPLY STRING_SPLIT(Toppings, ','))
select cast(pr.pizza_name as varchar) as Pizza, string_agg(convert(varchar,topping_name), ', ') As StandardToppings
from pizza_names pr join q1
on pr.pizza_id=q1.pizza_id
join pizza_toppings pt on
q1.value=pt.topping_id
group by cast(pr.pizza_name as varchar);

--Q2 What was the most commonly added extra?
with q1 as (
select co.order_id, value from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
cross apply string_split(extras, ',')
where pickup_time is not null and extras is not null)

select top 1 convert(varchar,topping_name) as Extra, count(q1.value) as Added
from q1 join pizza_toppings pt
on q1.value=pt.topping_id
group by convert(varchar,topping_name)
order by Added desc;

--Q3 What was the most common exclusion?
with q1 as (
select co.order_id, value from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
cross apply string_split(exclusions, ',')
where pickup_time is not null and exclusions is not null)

select top 1 convert(varchar,topping_name) as Exclusion, count(q1.value) as Excluded
from q1 join pizza_toppings pt
on q1.value=pt.topping_id
group by convert(varchar,topping_name)
order by Excluded desc;

--Q4 Generate an order item for each record in the customers_orders table in the format of one of the following:
--	Meat Lovers
--	Meat Lovers - Exclude Beef
--	Meat Lovers - Extra Bacon
--	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

insert into customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
values
  ('11', '106', '1', null, null, '20200113 18:05:02'),
  ('12', '107', '1', '3', null, '20200114 19:00:52'),
  ('13', '108', '1', null, '1', '20200116 23:00:23'),
  ('13', '108', '1', '1, 4', '6, 9', '20200116 23:00:23');

  delete from customer_orders where order_id in (11,12,13)

--Q5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

--drop table #test
  select  * 
  into #piztop
  from #test2
 --CROSS APPLY STRING_SPLIT(exclusions, ',') 
 --CROSS APPLY STRING_SPLIT(extras, ',')
CROSS APPLY STRING_SPLIT(toppings, ',')
	select * from #test1--2
  select * from #excl
  select * from #ext
  select * from #pizTop

 select  stand.row_num, stand.customer_id, stand.order_id, stand.StandardToppings, ex.ExtraToppings, exc.ExcludeToppings,
 case when ex.ExtraToppings is null and exc.ExcludeToppings is null then stand.StandardToppings  else null  end as 'Overall'
 ----when  ex.ExtraToppings is null and exc.ExcludeToppings is not null then
 ----(
 --(select row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As StandardToppings from
 -- #test1 t1 join #piztop pt
 -- on t1.pizza_id=pt.pizza_id
 -- join pizza_toppings pt1 on pt.value=pt1.topping_id
 -- group by row_num, customer_id, order_id
 --) as stand
 -- left join
 -- (select row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As ExtraToppings from #ext e
 -- join pizza_toppings pt1 on e.value=pt1.topping_id
 --  group by row_num, customer_id, order_id) as ex on stand.Row_Num=ex.Row_Num
 
 --)
 --)
 from
 ( select row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As StandardToppings from
  #test1 t1 join #piztop pt
  on t1.pizza_id=pt.pizza_id
  join pizza_toppings pt1 on pt.value=pt1.topping_id
  group by row_num, customer_id, order_id
 ) as stand
  left join
  (select row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As ExtraToppings from #ext e
  join pizza_toppings pt1 on e.value=pt1.topping_id
   group by row_num, customer_id, order_id) as ex on stand.Row_Num=ex.Row_Num 
     left join
  (select row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As ExcludeToppings from #excl e1
  join pizza_toppings pt1 on e1.value=pt1.topping_id
   group by row_num, customer_id, order_id) as exc on stand.Row_Num=exc.Row_Num

  order by stand.row_num
  

select t1.row_num, t1.customer_id, t1.order_id, string_agg(convert(varchar,topping_name), ', ') as exclude
 --, string_agg(convert(varchar,topping_name), ', ') As StandardToppings 
 from
  #test1 t1 join #piztop pt
  on t1.pizza_id=pt.pizza_id
  join pizza_toppings pt1 on pt.value=pt1.topping_id
  join #excl e
  on t1.Row_Num=e.Row_Num --and e.pizza_id=pt.pizza_id
  where pt.value != e.value
   group by t1.row_num, t1.customer_id, t1.order_id


