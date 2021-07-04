# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study #3 - Ingredient Optimization
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/W2.png" width=50% height=50%>

## Table Of Contents
  - [Case Study's Question](#case-studys-questions)
  - [Solution](#solutions)

 <br /> 

## Case Study's Questions

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	Meat Lovers
	Meat Lovers - Exclude Beef
	Meat Lovers - Extra Bacon
	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
 
 <br /> 

## Solutions

### **Q1. What are the standard ingredients for each pizza?**
```sql
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
```
**Result:**
Pizza		StandardToppings
Meatlovers	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
Vegetarian	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce

**Answer:**


---

### **Q2 What was the most commonly added extra?**
```sql
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
```

**Result:**
Extra	Added
Bacon	3
**Answer**:


---

### **Q3 What was the most common exclusion?**
```sql
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
```

**Result:**
Exclusion	Excluded
Cheese		3
**Answer: **

---

### **Q4 Generate an order item for each record in the customers_orders table in the format of one of the following:
	**Meat Lovers
	**Meat Lovers - Exclude Beef
	**Meat Lovers - Extra Bacon
	**Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**
```SQL
insert into customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
values
  ('11', '106', '1', null, null, '20200113 18:05:02'),
  ('12', '107', '1', '3', null, '20200114 19:00:52'),
  ('13', '108', '1', null, '1', '20200116 23:00:23'),
  ('13', '108', '1', '1, 4', '6, 9', '20200116 23:00:23');

  delete from customer_orders where order_id in (11,12,13);
```

---

### **Q5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	**For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```SQL
select ROW_NUMBER()over(order by order_id) as row_num, *
  into #test1
  from customer_orders;

  select *
  into #ext
  from #test1
 CROSS APPLY STRING_SPLIT(extras, ',');

  select *
  into #excl
  from #test1
CROSS APPLY STRING_SPLIT(exclusions, ',');

  select ROW_NUMBER()over(order by pizza_id) as row_num, *
  into #test2
  from pizza_recipes;

  select *
  into #pizTop
  from #test2
CROSS APPLY STRING_SPLIT(toppings, ',');



 select  stand.row_num, stand.customer_id, stand.order_id, stand.StandardToppings, ex.ExtraToppings, exc.ExcludeToppings
 from
 ( select t1.row_num, customer_id, order_id, string_agg(convert(varchar,topping_name), ', ') As StandardToppings from
  #test1 t1 join #piztop pt
  on t1.pizza_id=pt.pizza_id
  join pizza_toppings pt1 on pt.value=pt1.topping_id
  group by t1.row_num, customer_id, order_id
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

```
**Result:**
row_num	customer_id	order_id	StandardToppings	ExtraToppings	ExcludeToppings
1	101	1	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	NULL
2	101	2	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	NULL
3	102	3	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	NULL
4	102	3	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce	NULL	NULL
5	103	4	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	Cheese
6	103	4	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	Cheese
7	103	4	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce	NULL	Cheese
8	104	5	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	Bacon	NULL
9	101	6	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce	NULL	NULL
10	105	7	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce	Bacon	NULL
11	102	8	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	NULL
12	103	9	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	Bacon, Chicken	Cheese
13	104	10	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	NULL	NULL
14	104	10	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	Bacon, Cheese	BBQ Sauce, Mushrooms
**Answer: Still Working On It**


---

### **Q6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
```SQL

 ``` 
**Result:**

**Answer: Still Working on It**
