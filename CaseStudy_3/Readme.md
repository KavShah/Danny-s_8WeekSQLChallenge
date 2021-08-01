# [8-Week SQL Challenge](https://github.com/KavShah/Danny-s_8WeekSQLChallenge)


# 🥑 Case Study #3 - Foodie-Fi
<p align="center">
<img src="https://github.com/KavShah/Danny-s_8WeekSQLChallenge/blob/main/Image/W3.png" width=50% height=50%>

## 📕 Table Of Contents
  - 🛠️ [Problem Statement](#problem-statement)
  - 📂 [Dataset](#dataset)
  - 🧙‍♂️ [Case Study Questions](#case-study-questions)
  - 🚀 [Solutions](#-solutions)

## 🛠️ Problem Statement

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## 📂 Dataset
Danny has shared with you 2 key datasets for this case study:

* ### **```plan```**

The plan table shows which plans customer can choose to join Foodie-Fi when they first sign up.

* **Trial:** can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel

* **Basic plan:** limited access and can only stream user videos
* **Pro plan** no watch time limits and video are downloadable with 2 subscription options: **monthly** and **annually**


<details>
<summary>
View table
</summary>

| "plan_id" | "plan_name"     | "price" |
|-----------|-----------------|---------|
| 0         | "trial"         | 0.00    |
| 1         | "basic monthly" | 9.90    |
| 2         | "pro monthly"   | 19.90   |
| 3         | "pro annual"    | 199.00  |
| 4         | "churn"         | NULL    |


</details>

---

* ### **```subscriptions```**

Customer subscriptions show the exact date where their specific ```plan_id``` starts.



If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the ```start_date``` in the ```subscriptions``` table will reflect the date that the actual plan changes.

In this part, I will display the first 20 rows of this dataset since the original one is super long:

<details>
<summary>
View table
</summary>

| "customer_id" | "plan_id" | "start_date" |
|---------------|-----------|--------------|
| 1             | 0         | "2020-08-01" |
| 1             | 1         | "2020-08-08" |
| 2             | 0         | "2020-09-20" |
| 2             | 3         | "2020-09-27" |
| 3             | 0         | "2020-01-13" |
| 3             | 1         | "2020-01-20" |
| 4             | 0         | "2020-01-17" |
| 4             | 1         | "2020-01-24" |
| 4             | 4         | "2020-04-21" |
| 5             | 0         | "2020-08-03" |
| 5             | 1         | "2020-08-10" |
| 6             | 0         | "2020-12-23" |
| 6             | 1         | "2020-12-30" |
| 6             | 4         | "2021-02-26" |
| 7             | 0         | "2020-02-05" |
| 7             | 1         | "2020-02-12" |
| 7             | 2         | "2020-05-22" |
| 8             | 0         | "2020-06-11" |
| 8             | 1         | "2020-06-18" |
| 8             | 2         | "2020-08-03" |


</details>


## 🧙‍♂️ Case Study Questions

### A. **Customer Journey**
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!


## B. **Data Analysis Questions**

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of **```trial```** plan **```start_date```** values for our dataset - use the start of the month as the group by value
3. What plan **```start_date```** values occur after the year 2020 for our dataset? Show the breakdown by count of events for each **```plan_name```**
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 **```plan_name```** values at **```2020-12-31```**?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


## C. **Challenge Payment Question**
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments
Example outputs for this table might look like the following:

|customer_id|plan_id|plan_name	  |payment_date|   amount  |payment_order|
|-----------|-------|-------------|------------|-----------|-------------|
|1			|	1	|basic monthly|	2020-08-08 |	9.90   |	1        |
|1			|	1	|basic monthly|	2020-09-08 |	9.90   |	2        |
|1			|	1	|basic monthly|	2020-10-08 |	9.90   |	3        |
|1			|	1	|basic monthly|	2020-11-08 |	9.90   |	4        |
|1			|	1	|basic monthly|	2020-12-08 |	9.90   |	5        |
|2			|	3	|pro annual	  |	2020-09-27 |	199.00 |	1        |
|13			|	1	|basic monthly|	2020-12-22 |	9.90   |	1        |
|15			|	2	|pro monthly  |	2020-03-24 |	19.90  |	1        |
|15			|	2	|pro monthly  |	2020-04-24 |	19.90  |	2        |
|16			|	1	|basic monthly|	2020-06-07 |	9.90   |	1        |
|16			|	1	|basic monthly|	2020-07-07 |	9.90   |	2        |
|16			|	1	|basic monthly|	2020-08-07 |	9.90   |	3        |
|16			|	1	|basic monthly|	2020-09-07 |	9.90   |	4        |
|16			|	1	|basic monthly|	2020-10-07 |	9.90   |	5        |
|16			|	3	|pro annual	  |	2020-10-21 |	189.10 |	6        |
|18			|	2	|pro monthly  |	2020-07-13 |	19.90  |	1        |
|18			|	2	|pro monthly  |	2020-08-13 |	19.90  |	2        |
|18			|	2	|pro monthly  |	2020-09-13 |	19.90  |	3        |
|18			|	2	|pro monthly  |	2020-10-13 |	19.90  |	4        |
|18			|	2	|pro monthly  |	2020-11-13 |	19.90  |	5        |
|18			|	2	|pro monthly  |	2020-12-13 |	19.90  |	6        |
|19			|	2	|pro monthly  |	2020-06-29 |	19.90  |	1        |
|19			|	2	|pro monthly  |	2020-07-29 |	19.90  |	2        |
|19			|	2	|pro monthly  |	2020-08-29 |	19.90  |	3        |
|19			|	3	|pro annual	  |	2020-08-29 |	199.00 |	3        |


## D. **Outside The Box Questions**

The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

How would you calculate the rate of growth for Foodie-Fi?
What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
What are some key customer journeys or experiences that you would analyse further to improve customer retention?
If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?


---
## 🚀 Solutions
---
### Part A - **Customer Journey**
**Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
**Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!**
```SQL
    SELECT
      customer_id,
      subscriptions.plan_id,
      plan_name,
      start_date
    FROM foodie_fi.subscriptions
    INNER JOIN foodie_fi.plans
    ON subscriptions.plan_id = plans.plan_id
    WHERE customer_id IN (1, 2, 13, 15, 16, 18, 19, 25, 39, 42)
    order by 1, 2;
```
**Result:**

| customer_id | plan_id | plan_name     | start_date               |
| ----------- | ------- | ------------- | ------------------------ |
| 1           | 0       | trial         | 2020-08-01T00:00:00.000Z |
| 1           | 1       | basic monthly | 2020-08-08T00:00:00.000Z |
| 2           | 0       | trial         | 2020-09-20T00:00:00.000Z |
| 2           | 3       | pro annual    | 2020-09-27T00:00:00.000Z |
| 13          | 0       | trial         | 2020-12-15T00:00:00.000Z |
| 13          | 1       | basic monthly | 2020-12-22T00:00:00.000Z |
| 13          | 2       | pro monthly   | 2021-03-29T00:00:00.000Z |
| 15          | 0       | trial         | 2020-03-17T00:00:00.000Z |
| 15          | 2       | pro monthly   | 2020-03-24T00:00:00.000Z |
| 15          | 4       | churn         | 2020-04-29T00:00:00.000Z |
| 16          | 0       | trial         | 2020-05-31T00:00:00.000Z |
| 16          | 1       | basic monthly | 2020-06-07T00:00:00.000Z |
| 16          | 3       | pro annual    | 2020-10-21T00:00:00.000Z |
| 18          | 0       | trial         | 2020-07-06T00:00:00.000Z |
| 18          | 2       | pro monthly   | 2020-07-13T00:00:00.000Z |
| 19          | 0       | trial         | 2020-06-22T00:00:00.000Z |
| 19          | 2       | pro monthly   | 2020-06-29T00:00:00.000Z |
| 19          | 3       | pro annual    | 2020-08-29T00:00:00.000Z |
| 25          | 0       | trial         | 2020-05-10T00:00:00.000Z |
| 25          | 1       | basic monthly | 2020-05-17T00:00:00.000Z |
| 25          | 2       | pro monthly   | 2020-06-16T00:00:00.000Z |
| 39          | 0       | trial         | 2020-05-28T00:00:00.000Z |
| 39          | 1       | basic monthly | 2020-06-04T00:00:00.000Z |
| 39          | 2       | pro monthly   | 2020-08-25T00:00:00.000Z |
| 39          | 4       | churn         | 2020-09-10T00:00:00.000Z |
| 42          | 0       | trial         | 2020-10-27T00:00:00.000Z |
| 42          | 1       | basic monthly | 2020-11-03T00:00:00.000Z |
| 42          | 2       | pro monthly   | 2021-04-28T00:00:00.000Z |
--------

## Part B. **Data Analysis Questions**

1. **How many customers has Foodie-Fi ever had?**

```SQL
    SELECT count(distinct customer_id) as totalCustCount FROM foodie_fi.subscriptions;
```
**Result:**
| totalcustcount |
| -------------- |
| 1000           |

---
2. **What is the monthly distribution of **```trial```** plan **```start_date```** values for our dataset - use the start of the month as the group by value**

```SQL
    select DATE_TRUNC('month', start_date)::DATE as Months, count(customer_id)
    from foodie_fi.subscriptions
    where plan_id=0
    group by Months
    order by Months;
```
**Result:**
| months                   | count |
| ------------------------ | ----- |
| 2020-01-01T00:00:00.000Z | 88    |
| 2020-02-01T00:00:00.000Z | 68    |
| 2020-03-01T00:00:00.000Z | 94    |
| 2020-04-01T00:00:00.000Z | 81    |
| 2020-05-01T00:00:00.000Z | 88    |
| 2020-06-01T00:00:00.000Z | 79    |
| 2020-07-01T00:00:00.000Z | 89    |
| 2020-08-01T00:00:00.000Z | 88    |
| 2020-09-01T00:00:00.000Z | 87    |
| 2020-10-01T00:00:00.000Z | 79    |
| 2020-11-01T00:00:00.000Z | 75    |
| 2020-12-01T00:00:00.000Z | 84    |

---
3. **What plan **```start_date```** values occur after the year 2020 for our dataset? Show the breakdown by count of events for each **```plan_name```**

```SQL
    SELECT p.plan_id, plan_name,
      COUNT(*) AS events
    FROM foodie_fi.subscriptions s
    INNER JOIN foodie_fi.plans p
      ON s.plan_id = p.plan_id
    WHERE start_date > '2020-12-31'
    GROUP BY plan_name, p.plan_id
    ORDER BY p.plan_id;
```
**Result:**
| plan_id | plan_name     | events |
| ------- | ------------- | ------ |
| 1       | basic monthly | 8      |
| 2       | pro monthly   | 60     |
| 3       | pro annual    | 63     |
| 4       | churn         | 71     |

---
4. **What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```SQL
    SELECT
      SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_customers,
      ROUND(
        100.0 * SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) /
          COUNT(DISTINCT customer_id)
      ,1) AS percentage
    FROM foodie_fi.subscriptions;
```
**Result:**
| churn_customers | percentage |
| --------------- | ---------- |
| 307             | 30.7       |

---
5. **How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

```SQL
    with q1 as
    (SELECT customer_id, plan_id, lead(plan_id, 1) over(partition by customer_id order by plan_id) plan
    FROM foodie_fi.subscriptions
    order by 1)
    select 
      SUM(CASE WHEN plan_id = 0 and plan = 4 THEN 1 ELSE 0 END) AS churn_customers,
      round(
        100.0 * SUM(CASE WHEN plan_id = 0 and plan = 4 THEN 1 ELSE 0 END) /
          COUNT(DISTINCT customer_id)
      ) AS percentage
    FROM q1;
```
**Result:**
| churn_customers | percentage |
| --------------- | ---------- |
| 92              | 9          |

---
6. **What is the number and percentage of customer plans after their initial free trial?**

```SQL
    with q1 as
    (SELECT customer_id, plan_id, lead(plan_id, 1) over(partition by customer_id order by plan_id) plan
    FROM foodie_fi.subscriptions
    order by 1)
    select plan_name, SUM(CASE WHEN q1.plan_id = 0 THEN 1 ELSE 0 END) AS customers,
    round(
        100.0 * SUM(CASE WHEN q1.plan_id = 0 THEN 1 ELSE 0 END) /
        (select count(DISTINCT customer_id) from foodie_fi.subscriptions)
    ) AS percentage
    from q1 join foodie_fi.plans p
    on q1.plan=p.plan_id
    group by plan_name;
```
**Result:**
| plan_name     | customers | percentage |
| ------------- | --------- | ---------- |
| pro annual    | 37        | 4          |
| churn         | 92        | 9          |
| pro monthly   | 325       | 33         |
| basic monthly | 546       | 55         |

---
7. **What is the customer count and percentage breakdown of all 5 **```plan_name```** values at **```2020-12-31```**?

```SQL
    with q1 as
    (select customer_id, s.plan_id, plan_name, 
    rank() over(partition by customer_id order by s.plan_id desc) AS customersrk
    from foodie_fi.subscriptions s join foodie_fi.plans p
    on s.plan_id=p.plan_id
    where start_date <= '2020-12-31')
    select plan_name, SUM(CASE WHEN q1.customersrk = 1 THEN 1 ELSE 0 END) AS customers,
    round(
        100.0 * SUM(CASE WHEN q1.customersrk = 1 THEN 1 ELSE 0 END) /
        (select count(DISTINCT customer_id) from foodie_fi.subscriptions)
    ,1) AS percentage
    from q1
    group by plan_name;
```
**Result:**
| plan_name     | customers | percentage |
| ------------- | --------- | ---------- |
| pro annual    | 195       | 19.5       |
| trial         | 19        | 1.9        |
| churn         | 236       | 23.6       |
| pro monthly   | 326       | 32.6       |
| basic monthly | 224       | 22.4       |

---
8. **How many customers have upgraded to an annual plan in 2020?**

```SQL
    with q1 as
    (SELECT customer_id, plan_id, start_date
    FROM foodie_fi.subscriptions
    order by 1)
    select 
    SUM(CASE WHEN plan_id = 3 THEN 1 ELSE 0 END) AS upgrade_customers
    FROM q1
    where start_date between '2020-01-01' AND '2020-12-31';
```
**Result:**
| upgrade_customers |
| ----------------- |
| 195               |

---
9. **How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

```SQL
    WITH q1 AS (
    SELECT customer_id, start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 3
    ),
    q2 AS (
    SELECT customer_id, start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0
    )
    SELECT
    Round
    (AVG(
     DATE_PART(
    'day', q1.start_date::TIMESTAMP -
            q2.start_date::TIMESTAMP)
    ))
    FROM q1
     JOIN q2 on q1.customer_id=q2.customer_id;
```
**Result:**
| AverageDays |
| ----------- |
| 105   	  |

---
10. **Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

```SQL
    WITH q1 AS (
    SELECT customer_id, start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 3
    ),
    q2 AS (
    SELECT customer_id, start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0
    )
    SELECT 
    case when Round(DATE_PART('day', q1.start_date::TIMESTAMP - q2.start_date::TIMESTAMP)) Between 0 and 30 then '0-30'
     when Round(DATE_PART('day', q1.start_date::TIMESTAMP -
            q2.start_date::TIMESTAMP)) Between 30 and 60 then '31-60'
     when Round(DATE_PART('day', q1.start_date::TIMESTAMP -
            q2.start_date::TIMESTAMP)) Between 60 and 90 then '61-90'
     when Round(DATE_PART('day', q1.start_date::TIMESTAMP -
            q2.start_date::TIMESTAMP)) Between 90 and 120 then '91-120'
    else '120+' end As DayDist, count(*) as cst
    FROM q1
    JOIN q2 on q1.customer_id=q2.customer_id
    group by DayDist;
```
**Result:**
| daydist | cst |
| ------- | --- |
| 0-30    | 49  |
| 120+    | 116 |
| 31-60   | 24  |
| 61-90   | 34  |
| 91-120  | 35  |

---
11. **How many customers upgraded from a pro monthly to a basic monthly plan in 2020?**

```SQL
    with q1 as
    (SELECT customer_id, plan_id, start_date,
     rank() over(partition by customer_id order by start_date) as rk
    FROM foodie_fi.subscriptions
     where start_date between '2020-01-01' and '2020-12-31'
    order by 3),
    q2 as(                      
    select customer_id, rk from q1 where plan_id = 2),
    q3 as(                      
    select customer_id, rk from q1 where plan_id = 1)
    
     
    select SUM(CASE WHEN q3.rk < q2.rk THEN 1 ELSE 0 END) AS upgrade_customers
    FROM q2 join q3 on q2.customer_id=q3.customer_id ;
```
| upgrade_customers |
| ----------------- |
| 163               |

---
## C. **Challenge Payment Question** : UPDATING