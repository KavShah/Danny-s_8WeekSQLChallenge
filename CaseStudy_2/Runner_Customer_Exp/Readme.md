# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study #2 Part 2 - Pizza Metrics
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/W2.png" width=50% height=50%>

## Table Of Contents
  - [Case Study's Question](#case-studys-questions)
  - [Solution](#solutions)

 <br /> 

## Case Study's Questions

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)??
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? ??
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?
 
 <br /> 

## Solutions

### **Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?**
```sql
SELECT FLOOR(DATEDIFF(day,'2021-01-01', registration_date) / 7 + 1)  AS week_num , 
       COUNT(*) AS number_of_runners
FROM runners
GROUP BY FLOOR(DATEDIFF(day,'2021-01-01', registration_date ) / 7 + 1);
```
**Result:**
|week_num|number_of_runners|
|--------|-----------------|
|1       |2				   |
|2		 |1				   |
|3		 |1				   |

---

### **Q2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
select runner_id, avg(DATEDIFF(MINUTE,order_time,pickup_time)) as Average_Mins 
from dbo.customer_orders co join master.dbo.runner_orders ro
on co.order_id=ro.order_id
where pickup_time is not null
group by runner_id;
```

**Result:**
|runner_id|Average_Mins|
|---------|------------|
|1        |15		   |
|2		  |24		   |
|3		  |10		   |

---

### **Q3 Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
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
```

**Result:**
|order_id|Pizzas_ordered|prepare_time|
|--------|--------------|------------|
|1       |1				|10          |
|2       |1				|10          |
|3       |2				|21          |
|4       |3				|30          |
|5       |1				|10          |
|7       |1				|10          |
|8       |1				|21          |
|10      |2				|16          |

**Answer: Yes, There is relation. 1 Pizza ~ 10 mins**

---

### **Q4 What was the average distance travelled for each customer?**
```SQL
select customer_id, Avg(CONVERT(float, distance)) as 'AVGDistance_Covered(kms)'
from runner_orders ro join customer_orders co
on ro.order_id=co.order_id
where pickup_time is not null
group by customer_id
order by 1;
```

**Result:**
|customer_id|AVGDistance_Covered(kms)|
|-----------|------------------------|
|101        |29.5		   			 |
|102		|18.33		   			 |
|103	    |40		   				 |
|104		|11.67					 |
|105		|25						 |
	
---

### **Q5 What was the difference between the longest and shortest delivery times for all orders?**
```SQL
select max(convert(int,duration))-min(convert(int,duration)) as difference_between_delivery 
from runner_orders;

```
**Result:**
|difference_between_delivery (mins)|
|----------------------------------|
|30								   |
**Answer:**


---

### **Q6 What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```SQL
select order_id, runner_id,  Round(Avg(convert(float,distance)/convert(float,duration)*60),2) as 'Average_Speed(Kph)' from runner_orders
where pickup_time is not null
group by order_id, runner_id
order by 2;
 ``` 
**Result:**
|order_id|runner_id|Average_Speed(Kph)|
|--------|---------|------------------|
|1       |1		   |37.5          	  |
|2       |1	   	   |44.44          	  |
|3       |1		   |39           	  |
|10      |1		   |60          	  |
|4       |2		   |34.5          	  |
|7       |2		   |60          	  |
|8       |2		   |92          	  |
|5       |3		   |40          	  |

**Answer: Runner 1 has constant speed except for order_id 10 and doesn't seem to have any connection with time.
		**Runner 2 has increasing speed and is connected to time, the later the delivery the faster the speed.**


---

### **Q7 What is the successful delivery percentage for each runner?**
```SQL
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
```

**Result:**
|runner_id|Sucessful Deliveries|
|---------|--------------------|
|1        |100		   		   |
|2		  |75		   		   |
|3		  |50		   		   |

---