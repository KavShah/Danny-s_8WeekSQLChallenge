# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study #2 - Pizza Metrics
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/W2.png" width=50% height=50%>

## Table Of Contents
  - [Case Study's Question](#case-studys-questions)
  - [Solution](#solutions)

 <br /> 

## Case Study's Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

 <br /> 

## Solutions (Have not considered cancelled orders)

### **Q1. How many pizzas were ordered?**
```sql
with q1 as(select count(*) as Pizzas_ordered from
dbo.customer_orders co left join master.dbo.runner_orders ro
on co.order_id=ro.order_id),
q2 as(select count(*) as Pizzas_cancelled from
dbo.customer_orders co left join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is NULL)
select * from q1,q2;
```
**Result:**
Pizzas_ordered	Pizzas_cancelled
14		2
**Answer:**


---

### **Q2. How many unique customer orders were made?**
```sql
select count(distinct co.order_id) as Unique_Customer from customer_orders co
left join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where ro.pickup_time is not NULL;
```

**Result:**
Unique_Customer
8

**Answer**:


---

### **Q3. How many successful orders were delivered by each runner?**
```sql
select runner_id, count(order_id) as Successful_Delivery
from runner_orders
where pickup_time is not NULL
group by runner_id;
```

**Result:**
runner_id	Successful_Delivery
1	4
2	3
3	1
**Answer:**

---

### **Q4. How many of each type of pizza was delivered?**
```SQL
select cast(pizza_name as nvarchar(25)) as Pizza, count(co.order_id) as Times_Delivered from
runner_orders ro join customer_orders co
on ro.order_id = co.order_id
join pizza_names pn on co.pizza_id=pn.pizza_id
where ro.pickup_time is not null
group by cast(pizza_name as nvarchar(25));
```

**Result:**
Pizza	Times_Delivered
Meatlovers	9
Vegetarian	3

**Answer**:
---

### **Q5. How many Vegetarian and Meatlovers were ordered by each customer?**
```SQL
select co.customer_id, cast(pizza_name as nvarchar(25)) as Pizza, count(co.order_id) as Times_Delivered from
runner_orders ro join customer_orders co
on ro.order_id = co.order_id
join pizza_names pn on co.pizza_id=pn.pizza_id
where ro.pickup_time is not null
group by co.customer_id, cast(pizza_name as nvarchar(25));
```
**Result:**
customer_id	Pizza	Times_Delivered
101		Meatlovers	2
102		Meatlovers	2
102		Vegetarian	1
103		Meatlovers	2
103		Vegetarian	1
104		Meatlovers	3
105		Vegetarian	1
**Answer:**


---

### **Q6. What was the maximum number of pizzas delivered in a single order?**
```SQL
select top 1 ro.order_id, cast(pickup_time as date) as Pickup_Date, count(pizza_id) as ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by ro.order_id, cast(pickup_time as date)
order by ordered desc;
 ``` 
**Result:**
order_id	Pickup_Date	ordered
4	2020-01-04	3
**Answer:**


---

### **Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```SQL
select customer_id, case when exclusions is not null or extras is not null then 'At least 1 change' else 'No change' end,
count(co.order_id) 
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by customer_id, case when exclusions is not null or extras is not null then 'At least 1 change' else 'No change' end;
```

**Result:**
| customer_id | changes | no_change |
101	No change	2
102	No change	3
103	At least 1 change	3
104	At least 1 change	2
104	No change	1
105	At least 1 change	1

**Answer:**


---

### **Q8. How many pizzas were delivered that had both exclusions and extras?**
```SQL
select 
count(co.order_id) as ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null and exclusions is not null and extras is not null;
```  
**Result:**
ordered
 1           

**Answer:**


---

### **Q9. What was the total volume of pizzas ordered for each hour of the day?**
```SQL
select DATEPART(hour, order_time) as ordered_hour, count(*) as Times_Ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by DATEPART(hour, order_time);
```
**Result:**
ordered_hour	Times_Ordered
13	3
18	3
19	1
21	2
23	3
**Answer:**


---

### **Q10. What was the volume of orders for each day of the week?**
```SQL
select datename(WEEKDAY, order_time) as Day_Ordered, count(*) as Times_Ordered
from runner_orders ro join customer_orders co
on ro.order_id = co.order_id
where pickup_time is not null
group by DATEname(WEEKDAY, order_time);
```

**Result:**
Day_Ordered	Times_Ordered
Saturday		5
Thursday		3
Wednesday	4

**Answer:**


---
<p>&copy; 2021 Leah Nguyen</p>
