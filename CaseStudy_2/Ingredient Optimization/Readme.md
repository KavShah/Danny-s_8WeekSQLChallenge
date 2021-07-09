# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study #2 Part 3 - Ingredient Optimization
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
|Pizza		|StandardToppings 											     	  |
|-----------|---------------------------------------------------------------------|
|Meatlovers |Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami|
|Vegetarian |Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce		      |

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
|Extra|	Added|
|-----|------|
|Bacon|3	 |

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
|Exclusion|Excluded|
|---------|--------|
|Cheese	  |3	   |

---

### **Q4 Generate an order item for each record in the customers_orders table in the format of one of the following:
	**Meat Lovers
	**Meat Lovers - Exclude Beef
	**Meat Lovers - Extra Bacon
	**Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**
```SQL
-- Example Query:
WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') THEN NULL
      ELSE exclusions
    end AS exclusions,
    CASE
      WHEN extras IN ('', 'null') THEN NULL
      ELSE extras
    end AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
),
-- when using the regexp_split_to_table function only records where there are
-- non-null records remain so we will need to union them back in!
cte_extras_exclusions AS (
    SELECT
      order_id,
      customer_id,
      pizza_id,
      REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS exclusions_topping_id,
      REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS extras_topping_id,
      order_time,
      original_row_number
    FROM cte_cleaned_customer_orders
  -- here we add back in the null extra/exclusion rows
  -- does it make any difference if we use UNION or UNION ALL?
  UNION
    SELECT
      order_id,
      customer_id,
      pizza_id,
      NULL AS exclusions_topping_id,
      NULL AS extras_topping_id,
      order_time,
      original_row_number
    FROM cte_cleaned_customer_orders
    WHERE exclusions IS NULL AND extras IS NULL
),
cte_complete_dataset AS (
  SELECT
    base.order_id,
    base.customer_id,
    base.pizza_id,
    names.pizza_name,
    base.order_time,
    base.original_row_number,
    STRING_AGG(exclusions.topping_name, ', ') AS exclusions,
    STRING_AGG(extras.topping_name, ', ') AS extras
  FROM cte_extras_exclusions AS base
  INNER JOIN pizza_runner.pizza_names AS names
    ON base.pizza_id = names.pizza_id
  LEFT JOIN pizza_runner.pizza_toppings AS exclusions
    ON base.exclusions_topping_id = exclusions.topping_id
  LEFT JOIN pizza_runner.pizza_toppings AS extras
    ON base.extras_topping_id = extras.topping_id
  GROUP BY
    base.order_id,
    base.customer_id,
    base.pizza_id,
    names.pizza_name,
    base.order_time,
    base.original_row_number
),
cte_parsed_string_outputs AS (
SELECT
  order_id,
  customer_id,
  pizza_id,
  order_time,
  original_row_number,
  pizza_name,
  CASE WHEN exclusions IS NULL THEN '' ELSE ' - Exclude ' || exclusions end AS exclusions,
  CASE WHEN extras IS NULL THEN '' ELSE ' - Extra ' || extras end AS extras
FROM cte_complete_dataset
),
final_output AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    pizza_name || exclusions || extras AS order_item
  FROM cte_parsed_string_outputs
)
SELECT
  order_id,
  customer_id,
  pizza_id,
  order_time,
  order_item
FROM final_output
ORDER BY original_row_number;
```
**Result: Done in Postgres, need to find a way around regexp_split_to_table for sql server**

| order_id | customer_id | pizza_id | order_time               | order_item                                                      |
| -------- | ----------- | -------- | ------------------------ | --------------------------------------------------------------- |
| 1        | 101         | 1        | 2020-01-01T18:05:02.000Z | Meatlovers                                                      |
| 2        | 101         | 1        | 2020-01-01T19:00:52.000Z | Meatlovers                                                      |
| 3        | 102         | 1        | 2020-01-02T12:51:23.000Z | Meatlovers                                                      |
| 3        | 102         | 2        | 2020-01-02T12:51:23.000Z | Vegetarian                                                      |
| 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | 2        | 2020-01-04T13:23:46.000Z | Vegetarian - Exclude Cheese                                     |
| 5        | 104         | 1        | 2020-01-08T21:00:29.000Z | Meatlovers - Extra Bacon                                        |
| 6        | 101         | 2        | 2020-01-08T21:03:13.000Z | Vegetarian                                                      |
| 7        | 105         | 2        | 2020-01-08T21:20:29.000Z | Vegetarian - Extra Bacon                                        |
| 8        | 102         | 1        | 2020-01-09T23:54:33.000Z | Meatlovers                                                      |
| 9        | 103         | 1        | 2020-01-10T11:22:59.000Z | Meatlovers - Exclude Cheese - Extra Chicken, Bacon              |
| 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers                                                      |
| 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |


---

### **Q5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	**For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```SQL
WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', 'null') THEN NULL
      ELSE extras
    END AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
),
-- split the toppings using our previous solution
cte_regular_toppings AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes
),
-- now we can should left join our regular toppings with all pizzas orders
cte_base_toppings AS (
  SELECT
    cte_cleaned_customer_orders.order_id,
    cte_cleaned_customer_orders.customer_id,
    cte_cleaned_customer_orders.pizza_id,
    cte_cleaned_customer_orders.order_time,
    cte_cleaned_customer_orders.original_row_number,
    cte_regular_toppings.topping_id
  FROM cte_cleaned_customer_orders
  LEFT JOIN cte_regular_toppings
    ON cte_cleaned_customer_orders.pizza_id = cte_regular_toppings.pizza_id
),
-- now we can generate CTEs for exclusions and extras by the original row number
cte_exclusions AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE exclusions IS NOT NULL
),
cte_extras AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE extras IS NOT NULL
),
-- now we can perform an except and a union all on the respective CTEs
cte_combined_orders AS (
  SELECT * FROM cte_base_toppings
  EXCEPT
  SELECT * FROM cte_exclusions
  UNION ALL
  SELECT * FROM cte_extras
),
-- aggregate the count of topping ID and join onto pizza toppings
cte_joined_toppings AS (
  SELECT
    t1.order_id,
    t1.customer_id,
    t1.pizza_id,
    t1.order_time,
    t1.original_row_number,
    t1.topping_id,
    t2.pizza_name,
    t3.topping_name,
    COUNT(t1.*) AS topping_count
  FROM cte_combined_orders AS t1
  INNER JOIN pizza_runner.pizza_names AS t2
    ON t1.pizza_id = t2.pizza_id
  INNER JOIN pizza_runner.pizza_toppings AS t3
    ON t1.topping_id = t3.topping_id
  GROUP BY
    t1.order_id,
    t1.customer_id,
    t1.pizza_id,
    t1.order_time,
    t1.original_row_number,
    t1.topping_id,
    t2.pizza_name,
    t3.topping_name
)
SELECT

  order_id,
  customer_id,
  pizza_id,
  order_time,
  original_row_number,
  pizza_name || ': ' ||
  -- this logic is quite intense!
   STRING_AGG(
    CASE
      WHEN topping_count > 1 THEN  topping_count || 'x ' || topping_name
      ELSE  topping_name
      END,
    ', '
  ) AS ingredients_list
FROM cte_joined_toppings
GROUP BY
  order_id,
  customer_id,
  pizza_id,
  order_time,
  original_row_number,
  pizza_name;

```
**Result:**

| order_id | customer_id | pizza_id | order_time               | original_row_number | ingredients_list                                                                     |
| -------- | ----------- | -------- | ------------------------ | ------------------- | ------------------------------------------------------------------------------------ |
| 1        | 101         | 1        | 2020-01-01T18:05:02.000Z | 1                   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 2        | 101         | 1        | 2020-01-01T19:00:52.000Z | 2                   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 3        | 102         | 1        | 2020-01-02T12:51:23.000Z | 3                   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 3        | 102         | 2        | 2020-01-02T12:51:23.000Z | 4                   | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce               |
| 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | 5                   | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | 6                   | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 4        | 103         | 2        | 2020-01-04T13:23:46.000Z | 7                   | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                       |
| 5        | 104         | 1        | 2020-01-08T21:00:29.000Z | 8                   | Meatlovers: 2x Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | 101         | 2        | 2020-01-08T21:03:13.000Z | 9                   | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce               |
| 7        | 105         | 2        | 2020-01-08T21:20:29.000Z | 10                  | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce        |
| 8        | 102         | 1        | 2020-01-09T23:54:33.000Z | 11                  | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 9        | 103         | 1        | 2020-01-10T11:22:59.000Z | 12                  | Meatlovers: 2x Bacon, BBQ Sauce, Beef, 2x Chicken, Mushrooms, Pepperoni, Salami      |
| 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | 13                  | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | 14                  | Meatlovers: 2x Bacon, Beef, 2x Cheese, Chicken, Pepperoni, Salami                    |

---


**Answer: Postgres Query**


---

### **Q6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
```SQL

 ``` 
**Result:**

**Answer: Still Working on It**
