# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)

# Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/picW1.png" width=50% height=50%>

## Table Of Contents
* [Problem Statement](#problem-statement)
* [Dataset](#dataset)
* [Case Study Questions](#case-study-questions)
* [Solution](#solutions)
* [Limitations](#limitations)
  
  
 <br /> 

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

 <br /> 

## Dataset
Danny has shared with you 3 key datasets for this case study:

* **```sales```**

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 <br /> 

* **```menu```**


The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

 <br /> 

* **```members```**

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 <br /> 

## Case Study Questions
<p align="center">


1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 <br /> 

## Solutions

### **Q1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT
  	s.customer_id,
    sum(m.price) as Total_spent
FROM sales s join menu m 
on s.product_id=m.product_id
group by customer_id
order by 2 desc;
;
```

**Result:**
| customer_id | Total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**Answer:**
> * **Customer A** spent **$76**
> * **Customer B** spent **$74**
> * **Customer C** spent **$36**

---

### **Q2. How many days has each customer visited the restaurant?**
```sql
select customer_id,
count(distinct order_date) as Visits
from sales
group by customer_id
order by 2 desc;
```
**Result:**
|customer_id|Visits|
|-----------|------------|
|B          |6           |
|A          |4           |
|C          |2           |

**Answer:**
> * **Customer B** has visited **6 days**
> * **Customer A** has visited **4 days**
> * **Customer C** has visited **2 days**

---

### **Q3. What was the first item from the menu purchased by each customer?**
<span style="color:grey"> Access [**here**](#question-3-what-was-the-first-item-from-the-menu-purchased-by-each-customer) to view the limitations of this question</span>


```sql
With q1 as(
select customer_id, product_name,
row_number() over(partition by customer_id order by order_date, s.product_id) as rk
from sales s join menu m
on s.product_id=m.product_id)
select customer_id, product_name from q1
where rk = 1;
```

**Result:**
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

**Answer:**
> First item purchased by:
> * **Customer A** is **sushi**
> * **Customer B** is **curry**
> * **Customer C** is **ramen**

---

### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
select product_name,
count(s.product_id) as ordered
from sales s join menu m
on s.product_id=m.product_id
group by product_name
order by ordered desc
limit 1;
```

**Result:**
|product_name|ordered|
|------------|-----------|
|ramen       |8          |

**Answer:**

> Most purchased item was **ramen**, which was ordered **8 times**

---

### **Q5. Which item was the most popular for each customer?**
<span style="color:grey"> Access [**here**](#question-5-which-item-was-the-most-popular-for-each-customer) to view the limitations of this question</span>
```sql
with q1 as
(select customer_id, product_name,
count(s.product_id) as counts
from sales s join menu m
on s.product_id=m.product_id
group by customer_id, product_name
order by customer_id, counts desc)
, q2 as
(select customer_id, product_name, counts,
rank() over(partition by customer_id order by counts desc) as rk
 from q1
)
select customer_id, product_name, counts as times_ordered
from q2 where rk = 1;
```

**Result:**
| customer_id | product_name | times_ordered |
| ----------- | ------------ | ------------- |
| A           | ramen        | 3             |
| B           | ramen        | 2             |
| B           | curry        | 2             |
| B           | sushi        | 2             |
| C           | ramen        | 3             |

**Answer:**
> Most popular item for:
> * **Customer A** was **Ramen** 
> * **Customer B** was a tie between **all three menu items**
> * **Customer C** was **ramen** 

---

### **Q6. Which item was purchased first by the customer after they became a member?**
<span style="color:grey"> Access [**here**](#question-6-which-item-was-purchased-first-by-the-customer-after-they-became-a-member) to view the limitations of this question</span>
<span style="color:red"> 


```sql
with q1 as(
select s.customer_id, order_date, product_id
from sales s join members m
on s.customer_id=m.customer_id
where s.order_date >= m.join_date)
, q2 as (
select q1.customer_id, product_name,
  rank() over (partition by q1.customer_id order by q1.order_date) as rk
  from q1 join menu me
  on q1.product_id = me.product_id
)
select customer_id, product_name
from q2
where rk=1;
```

**Result:**
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

**Answer:**
> First product ordered after becoming a member for:
> * **Customer A** is **curry** 
> * **Customer B** is **sushi**
> 
> (*Customer C is not included in the list since he/she didn't join the membership program*)

<br /> 

---

### **Q7. Which item was purchased just before the customer became a member?**
<span style="color:grey"> Access [**here**](#question-7-which-item-was-purchased-just-before-the-customer-became-a-member) to view the limitations of this question</span>

```sql
with q1 as(
select s.customer_id, order_date, product_id
from sales s join members m
on s.customer_id=m.customer_id
where s.order_date < m.join_date)
, q2 as (
select q1.customer_id, product_name,
  rank() over (partition by q1.customer_id order by q1.order_date desc) as rk
  from q1 join menu me
  on q1.product_id = me.product_id
)
select customer_id, product_name
from q2
where rk=1;
```

**Result:**
| customer_id | product_name | 
| ----------- | ------------ | 
| A           | sushi        | 
| A           | curry        | 
| B           | sushi        | 

**Answer:**
> Last item purchased before becoming a member for:
> * **Customer A** was either <ins>**curry**</ins> or <ins>**sushi**</ins>. <span style="color:red"> *Access [here]() to view limitations of this question*</span> 
> * **Customer B** was **sushi**

---

### **Q8. What is the total items and amount spent for each member before they became a member?**
```sql
select s.customer_id, count(s.product_id) as BeforeMemberordered, sum(price) as BeforeMembertotal
from sales s join members m
on s.customer_id=m.customer_id
join menu me 
on s.product_id=me.product_id
where s.order_date < m.join_date
group by 1;
```

**Result:**
| customer_id | BeforeMemberordered | BeforeMembertotal |
| ----------- | ------------------- | ----------------- |
| A           | 2         			| 25           		|
| B           | 3          			| 40           		|

**Answer:**
* **Customer A** spent **$25** on **2 items** before becoming members
* **Customer B** spent **$40** on **3 items** before becoming members

---

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
select customer_id,
sum(case when s.product_id = 1 then price*20
	else price*10 end) as RewardPoints
from sales s join menu m
on s.product_id=m.product_id
group by 1;
```

**Result:**
| customer_id | RewardPointsoints |
| ----------- | ----------------- |
| A           | 860          	  |
| B           | 940          	  |
| C			  | 360			 	  |	
**Answer:**
* **Customer A** has **860 pts**
* **Customer B** has **940 pts**
* **Customer C** has **360 pts**

---

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

<span style="color:grey"> Access [**here**](#question-10-in-the-first-week-after-a-customer-joins-the-program-including-their-join-date-they-earn-2x-points-on-all-items-not-just-sushi---how-many-points-do-customer-a-and-b-have-at-the-end-of-january) to view the limitations of this question</span>

If we combine the condition from [**question 9**](#q9-if-each-1-spent-equates-to-10-points-and-sushi-has-a-2x-points-multiplier---how-many-points-would-each-customer-have) and the condition in this question, we will have 2 point calculation cases under:
- **Normal condition:** when **```product_name = 'sushi'```** = points X2, **```else```** = points X1
- **Conditions within the first week of membership:** when all menu items are awarded X2 points


```sql
select s.customer_id,sum(
case when (order_date >= join_date) and (order_date < join_date + integer '7')  then price*20
	else (case when s.product_id=1 then price*20
         else price*10 end) end) as RewardPoints
from sales s join menu m
on s.product_id=m.product_id
join members me on s.customer_id=me.customer_id
where order_date <= date '2021-01-31'
group by 1;
```
**Result:**
| customer_id | RewardPointsoints |
| ----------- | ----------------- |
| A           | 1370         	  |
| B           | 820          	  |
**Answer:**
* **Customer A** has **1370 pts**
* **Customer B** has **820 pts**

 <br /> 
---

## Bonus Questions
### **Q11. Join All The Things. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

**Recreate the following table output using the available data:**

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |


```sql
select s.customer_id, order_date, product_name, price,
case when order_date < join_date then 'N'
	when order_date >= join_date then 'Y'
    else 'N' end as Member
from sales s join menu m
on s.product_id=m.product_id
left join members me 
on s.customer_id=me.customer_id
order by customer_id, order_date;
```

### **Q12. Rank All The Things. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

**Recreate the following table output using the available data:**

| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |


```sql
with q1 as(
select s.customer_id, order_date, product_name, price,
case when order_date < join_date then 'N'
	when order_date >= join_date then 'Y'
    else 'N' end as Member
from sales s join menu m
on s.product_id=m.product_id
left join members me 
on s.customer_id=me.customer_id)
select *, 
case when Member = 'N' then Null
	else rank() over(partition by q1.customer_id, q1.Member order by order_date)
    end as ranking
from q1
order by customer_id, order_date;
```

<br />

---
 ## Limitations
 
> This section includes all the limitations in terms of my understanding regarding the question and on the limited data information in response to the question 3, 5, 6, 7 and 10:

### **Question 3: What was the first item from the menu purchased by each customer?**
[View solution](#q3-what-was-the-first-item-from-the-menu-purchased-by-each-customer)

The limition of this question includes:

* Since the **```order_date```** information does not include details of the purchase time (hours, minute, second, etc.) and those orders purchased **on the same day** are sorted based on the **```product_id```** instead of time element, it is difficult for me to know which product is purchased first on the same day.

That's why, in this question I will sort the first purchase order by the **```product_id```**

---

### **Question 5: Which item was the most popular for each customer?**
[View solution](#q5-which-item-was-the-most-popular-for-each-customer)

The limition of this question includes:
* Since there is <span style="color:red">**no extra information**</span> to provide further conditions for **sorting popular items** for each customer, thus, those products have the same highest purchase counts are considered to be all popular

---

### **Question 6: Which item was purchased first by the customer after they became a member?**
[View solution](#q6-which-item-was-purchased-first-by-the-customer-after-they-became-a-member)

The limition of this question includes:

* Since it is not clear that those orders made during the **join_date** was <ins>**after**</ins> or <ins>**before**</ins> the customer joined in the membership program because of the lack of **```order_date```** and **```join_date```** information (does not include details of the purchase time), I will assume these orders were made after the customer had already joined the program. 
---


### **Question 7: Which item was purchased just before the customer became a member?**
[View solution](#q7-which-item-was-purchased-just-before-the-customer-became-a-member)

The limition of this question includes:
* Since the **```order_date```** information does not include details of the purchase time (hours, minute, second, etc.) and those orders purchased **on the same day** are sorted based on the **```product_id```** instead of time element, it is difficult for me to know which product is last purchased before the customer join in the membership program. 
 
Therefore, the result can be either 1 of those orders made during the last day before the **```join_date```**

---


### **Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
[View solution](#q10-in-the-first-week-after-a-customer-joins-the-program-including-their-join-date-they-earn-2x-points-on-all-items-not-just-sushi---how-many-points-do-customer-a-and-b-have-at-the-end-of-january)

The limition of this question includes:
* Since it is not clear that the points in this question is only calculated **after the customer joins in the membership program** or not, I will also include the total points before the **```join_date```**.
