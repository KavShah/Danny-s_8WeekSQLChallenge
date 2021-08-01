

**Query #1**

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

---
**Query #2**

    SELECT count(distinct customer_id) as totalCustCount FROM foodie_fi.subscriptions;

| totalcustcount |
| -------------- |
| 1000           |

---
**Query #3**

    select DATE_TRUNC('month', start_date)::DATE as Months, count(customer_id)
    from foodie_fi.subscriptions
    where plan_id=0
    group by Months
    order by Months;

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
**Query #4**

    SELECT p.plan_id, plan_name,
      COUNT(*) AS events
    FROM foodie_fi.subscriptions s
    INNER JOIN foodie_fi.plans p
      ON s.plan_id = p.plan_id
    WHERE start_date > '2020-12-31'
    GROUP BY plan_name, p.plan_id
    ORDER BY p.plan_id;

| plan_id | plan_name     | events |
| ------- | ------------- | ------ |
| 1       | basic monthly | 8      |
| 2       | pro monthly   | 60     |
| 3       | pro annual    | 63     |
| 4       | churn         | 71     |

---
**Query #5**

    SELECT
      SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_customers,
      ROUND(
        100.0 * SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) /
          COUNT(DISTINCT customer_id)
      ,1) AS percentage
    FROM foodie_fi.subscriptions;

| churn_customers | percentage |
| --------------- | ---------- |
| 307             | 30.7       |

---
**Query #6**

    with q1 as
    (SELECT customer_id, plan_id, lead(plan_id, 1) over(partition by customer_id order by plan_id) plan
    FROM foodie_fi.subscriptions
    order by 1)
    select 
      SUM(CASE WHEN plan_id = 0 and plan = 4 THEN 1 ELSE 0 END) AS churn_customers,
      ceil(
        100.0 * SUM(CASE WHEN plan_id = 0 and plan = 4 THEN 1 ELSE 0 END) /
          COUNT(DISTINCT customer_id)
      ) AS percentage
    FROM q1;

| churn_customers | percentage |
| --------------- | ---------- |
| 92              | 10         |

---
**Query #7**

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

| plan_name     | customers | percentage |
| ------------- | --------- | ---------- |
| pro annual    | 37        | 4          |
| churn         | 92        | 9          |
| pro monthly   | 325       | 33         |
| basic monthly | 546       | 55         |

---
**Query #8**

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

| plan_name     | customers | percentage |
| ------------- | --------- | ---------- |
| pro annual    | 195       | 19.5       |
| trial         | 19        | 1.9        |
| churn         | 236       | 23.6       |
| pro monthly   | 326       | 32.6       |
| basic monthly | 224       | 22.4       |

---
**Query #9**

    with q1 as
    (SELECT customer_id, plan_id, start_date
    FROM foodie_fi.subscriptions
    order by 1)
    select 
    SUM(CASE WHEN plan_id = 3 THEN 1 ELSE 0 END) AS upgrade_customers
    FROM q1
    where start_date between '2020-01-01' AND '2020-12-31';

| upgrade_customers |
| ----------------- |
| 195               |

---
**Query #10**

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

| round |
| ----- |
| 105   |

---
**Query #11**

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
    case when Round(DATE_PART('day', q1.start_date::TIMESTAMP -  				               q2.start_date::TIMESTAMP)) Between 0 and 30 then '0-30'
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

| daydist | cst |
| ------- | --- |
| 0-30    | 49  |
| 120+    | 116 |
| 31-60   | 24  |
| 61-90   | 34  |
| 91-120  | 35  |

---
**Query #12**

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
    
     
    select SUM(CASE WHEN q3.rk < q2.rk THEN 1 ELSE 0 END) AS dngrade_customers
    FROM q2 join q3 on q2.customer_id=q3.customer_id ;

| dngrade_customers |
| ----------------- |
| 163               |

---
**Query #13**

    select customer_id, s.plan_id, 
    lead(s.plan_id) over(partition by customer_id order by start_date) as leadPlan,
    start_date,
    lead(s.start_date) over(partition by customer_id order by start_date) as leadDate
    ,plan_name, price
    from foodie_fi.subscriptions s join foodie_fi.plans p
    on s.plan_id=p.plan_id
    where s.plan_id <> 0   
    order by customer_id;

| customer_id | plan_id | leadplan | start_date               | leaddate                 | plan_name     | price  |
| ----------- | ------- | -------- | ------------------------ | ------------------------ | ------------- | ------ |
| 1           | 1       |          | 2020-08-08T00:00:00.000Z |                          | basic monthly | 9.90   |
| 2           | 3       |          | 2020-09-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 3           | 1       |          | 2020-01-20T00:00:00.000Z |                          | basic monthly | 9.90   |
| 4           | 1       | 4        | 2020-01-24T00:00:00.000Z | 2020-04-21T00:00:00.000Z | basic monthly | 9.90   |
| 4           | 4       |          | 2020-04-21T00:00:00.000Z |                          | churn         |        |
| 5           | 1       |          | 2020-08-10T00:00:00.000Z |                          | basic monthly | 9.90   |
| 6           | 1       | 4        | 2020-12-30T00:00:00.000Z | 2021-02-26T00:00:00.000Z | basic monthly | 9.90   |
| 6           | 4       |          | 2021-02-26T00:00:00.000Z |                          | churn         |        |
| 7           | 1       | 2        | 2020-02-12T00:00:00.000Z | 2020-05-22T00:00:00.000Z | basic monthly | 9.90   |
| 7           | 2       |          | 2020-05-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 8           | 1       | 2        | 2020-06-18T00:00:00.000Z | 2020-08-03T00:00:00.000Z | basic monthly | 9.90   |
| 8           | 2       |          | 2020-08-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 9           | 3       |          | 2020-12-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 10          | 2       |          | 2020-09-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 11          | 4       |          | 2020-11-26T00:00:00.000Z |                          | churn         |        |
| 12          | 1       |          | 2020-09-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 13          | 1       | 2        | 2020-12-22T00:00:00.000Z | 2021-03-29T00:00:00.000Z | basic monthly | 9.90   |
| 13          | 2       |          | 2021-03-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 14          | 1       |          | 2020-09-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 15          | 2       | 4        | 2020-03-24T00:00:00.000Z | 2020-04-29T00:00:00.000Z | pro monthly   | 19.90  |
| 15          | 4       |          | 2020-04-29T00:00:00.000Z |                          | churn         |        |
| 16          | 1       | 3        | 2020-06-07T00:00:00.000Z | 2020-10-21T00:00:00.000Z | basic monthly | 9.90   |
| 16          | 3       |          | 2020-10-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 17          | 1       | 3        | 2020-08-03T00:00:00.000Z | 2020-12-11T00:00:00.000Z | basic monthly | 9.90   |
| 17          | 3       |          | 2020-12-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 18          | 2       |          | 2020-07-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 19          | 2       | 3        | 2020-06-29T00:00:00.000Z | 2020-08-29T00:00:00.000Z | pro monthly   | 19.90  |
| 19          | 3       |          | 2020-08-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 20          | 1       | 3        | 2020-04-15T00:00:00.000Z | 2020-06-05T00:00:00.000Z | basic monthly | 9.90   |
| 20          | 3       |          | 2020-06-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 21          | 1       | 2        | 2020-02-11T00:00:00.000Z | 2020-06-03T00:00:00.000Z | basic monthly | 9.90   |
| 21          | 2       | 4        | 2020-06-03T00:00:00.000Z | 2020-09-27T00:00:00.000Z | pro monthly   | 19.90  |
| 21          | 4       |          | 2020-09-27T00:00:00.000Z |                          | churn         |        |
| 22          | 2       |          | 2020-01-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 23          | 3       |          | 2020-05-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 24          | 2       | 3        | 2020-11-17T00:00:00.000Z | 2021-04-17T00:00:00.000Z | pro monthly   | 19.90  |
| 24          | 3       |          | 2021-04-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 25          | 1       | 2        | 2020-05-17T00:00:00.000Z | 2020-06-16T00:00:00.000Z | basic monthly | 9.90   |
| 25          | 2       |          | 2020-06-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 26          | 2       |          | 2020-12-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 27          | 2       |          | 2020-08-31T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 28          | 3       |          | 2020-07-07T00:00:00.000Z |                          | pro annual    | 199.00 |
| 29          | 2       |          | 2020-01-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 30          | 1       |          | 2020-05-06T00:00:00.000Z |                          | basic monthly | 9.90   |
| 31          | 2       | 3        | 2020-06-29T00:00:00.000Z | 2020-11-29T00:00:00.000Z | pro monthly   | 19.90  |
| 31          | 3       |          | 2020-11-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 32          | 1       | 2        | 2020-06-19T00:00:00.000Z | 2020-07-18T00:00:00.000Z | basic monthly | 9.90   |
| 32          | 2       |          | 2020-07-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 33          | 2       | 4        | 2020-09-10T00:00:00.000Z | 2021-02-05T00:00:00.000Z | pro monthly   | 19.90  |
| 33          | 4       |          | 2021-02-05T00:00:00.000Z |                          | churn         |        |
| 34          | 1       | 2        | 2020-12-27T00:00:00.000Z | 2021-03-26T00:00:00.000Z | basic monthly | 9.90   |
| 34          | 2       |          | 2021-03-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 35          | 2       |          | 2020-09-10T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 36          | 2       |          | 2020-03-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 37          | 1       | 2        | 2020-08-12T00:00:00.000Z | 2020-11-11T00:00:00.000Z | basic monthly | 9.90   |
| 37          | 2       |          | 2020-11-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 38          | 2       | 3        | 2020-10-09T00:00:00.000Z | 2020-11-09T00:00:00.000Z | pro monthly   | 19.90  |
| 38          | 3       |          | 2020-11-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 39          | 1       | 2        | 2020-06-04T00:00:00.000Z | 2020-08-25T00:00:00.000Z | basic monthly | 9.90   |
| 39          | 2       | 4        | 2020-08-25T00:00:00.000Z | 2020-09-10T00:00:00.000Z | pro monthly   | 19.90  |
| 39          | 4       |          | 2020-09-10T00:00:00.000Z |                          | churn         |        |
| 40          | 1       | 2        | 2020-01-29T00:00:00.000Z | 2020-03-25T00:00:00.000Z | basic monthly | 9.90   |
| 40          | 2       |          | 2020-03-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 41          | 2       |          | 2020-05-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 42          | 1       | 2        | 2020-11-03T00:00:00.000Z | 2021-04-28T00:00:00.000Z | basic monthly | 9.90   |
| 42          | 2       |          | 2021-04-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 43          | 1       | 2        | 2020-08-20T00:00:00.000Z | 2020-12-18T00:00:00.000Z | basic monthly | 9.90   |
| 43          | 2       |          | 2020-12-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 44          | 3       |          | 2020-03-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 45          | 1       | 2        | 2020-02-18T00:00:00.000Z | 2020-08-12T00:00:00.000Z | basic monthly | 9.90   |
| 45          | 2       |          | 2020-08-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 46          | 1       | 2        | 2020-04-26T00:00:00.000Z | 2020-07-06T00:00:00.000Z | basic monthly | 9.90   |
| 46          | 2       | 3        | 2020-07-06T00:00:00.000Z | 2020-08-06T00:00:00.000Z | pro monthly   | 19.90  |
| 46          | 3       |          | 2020-08-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 47          | 1       | 3        | 2020-06-13T00:00:00.000Z | 2020-10-26T00:00:00.000Z | basic monthly | 9.90   |
| 47          | 3       |          | 2020-10-26T00:00:00.000Z |                          | pro annual    | 199.00 |
| 48          | 1       | 4        | 2020-01-18T00:00:00.000Z | 2020-06-01T00:00:00.000Z | basic monthly | 9.90   |
| 48          | 4       |          | 2020-06-01T00:00:00.000Z |                          | churn         |        |
| 49          | 2       | 3        | 2020-05-01T00:00:00.000Z | 2020-08-01T00:00:00.000Z | pro monthly   | 19.90  |
| 49          | 3       |          | 2020-08-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 50          | 2       |          | 2020-07-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 51          | 1       | 3        | 2020-01-26T00:00:00.000Z | 2020-03-09T00:00:00.000Z | basic monthly | 9.90   |
| 51          | 3       | 4        | 2020-03-09T00:00:00.000Z | 2021-03-09T00:00:00.000Z | pro annual    | 199.00 |
| 51          | 4       |          | 2021-03-09T00:00:00.000Z |                          | churn         |        |
| 52          | 1       | 4        | 2020-06-07T00:00:00.000Z | 2020-07-05T00:00:00.000Z | basic monthly | 9.90   |
| 52          | 4       |          | 2020-07-05T00:00:00.000Z |                          | churn         |        |
| 53          | 1       |          | 2020-01-25T00:00:00.000Z |                          | basic monthly | 9.90   |
| 54          | 2       |          | 2020-05-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 55          | 1       | 3        | 2020-10-29T00:00:00.000Z | 2021-03-01T00:00:00.000Z | basic monthly | 9.90   |
| 55          | 3       |          | 2021-03-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 56          | 3       |          | 2020-01-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 57          | 2       |          | 2020-03-10T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 58          | 1       | 3        | 2020-07-11T00:00:00.000Z | 2020-09-24T00:00:00.000Z | basic monthly | 9.90   |
| 58          | 3       |          | 2020-09-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 59          | 1       | 4        | 2020-11-06T00:00:00.000Z | 2021-04-29T00:00:00.000Z | basic monthly | 9.90   |
| 59          | 4       |          | 2021-04-29T00:00:00.000Z |                          | churn         |        |
| 60          | 1       |          | 2020-06-24T00:00:00.000Z |                          | basic monthly | 9.90   |
| 61          | 1       | 3        | 2020-09-07T00:00:00.000Z | 2021-02-13T00:00:00.000Z | basic monthly | 9.90   |
| 61          | 3       |          | 2021-02-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 62          | 1       | 2        | 2020-10-19T00:00:00.000Z | 2021-01-02T00:00:00.000Z | basic monthly | 9.90   |
| 62          | 2       | 4        | 2021-01-02T00:00:00.000Z | 2021-02-23T00:00:00.000Z | pro monthly   | 19.90  |
| 62          | 4       |          | 2021-02-23T00:00:00.000Z |                          | churn         |        |
| 63          | 1       | 4        | 2020-06-04T00:00:00.000Z | 2020-06-18T00:00:00.000Z | basic monthly | 9.90   |
| 63          | 4       |          | 2020-06-18T00:00:00.000Z |                          | churn         |        |
| 64          | 1       | 2        | 2020-03-15T00:00:00.000Z | 2020-04-03T00:00:00.000Z | basic monthly | 9.90   |
| 64          | 2       | 4        | 2020-04-03T00:00:00.000Z | 2020-04-27T00:00:00.000Z | pro monthly   | 19.90  |
| 64          | 4       |          | 2020-04-27T00:00:00.000Z |                          | churn         |        |
| 65          | 1       | 2        | 2020-05-19T00:00:00.000Z | 2020-10-09T00:00:00.000Z | basic monthly | 9.90   |
| 65          | 2       |          | 2020-10-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 66          | 1       | 3        | 2020-08-06T00:00:00.000Z | 2020-10-04T00:00:00.000Z | basic monthly | 9.90   |
| 66          | 3       |          | 2020-10-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 67          | 2       |          | 2020-08-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 68          | 3       |          | 2020-04-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 69          | 1       | 2        | 2020-03-14T00:00:00.000Z | 2020-04-14T00:00:00.000Z | basic monthly | 9.90   |
| 69          | 2       |          | 2020-04-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 70          | 1       | 2        | 2020-07-13T00:00:00.000Z | 2021-01-06T00:00:00.000Z | basic monthly | 9.90   |
| 70          | 2       |          | 2021-01-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 71          | 2       | 4        | 2020-07-30T00:00:00.000Z | 2020-12-08T00:00:00.000Z | pro monthly   | 19.90  |
| 71          | 4       |          | 2020-12-08T00:00:00.000Z |                          | churn         |        |
| 72          | 2       | 4        | 2020-12-17T00:00:00.000Z | 2021-02-01T00:00:00.000Z | pro monthly   | 19.90  |
| 72          | 4       |          | 2021-02-01T00:00:00.000Z |                          | churn         |        |
| 73          | 1       | 2        | 2020-03-31T00:00:00.000Z | 2020-05-13T00:00:00.000Z | basic monthly | 9.90   |
| 73          | 2       | 3        | 2020-05-13T00:00:00.000Z | 2020-10-13T00:00:00.000Z | pro monthly   | 19.90  |
| 73          | 3       |          | 2020-10-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 74          | 1       | 3        | 2020-05-31T00:00:00.000Z | 2020-10-01T00:00:00.000Z | basic monthly | 9.90   |
| 74          | 3       |          | 2020-10-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 75          | 1       | 2        | 2020-07-21T00:00:00.000Z | 2020-11-19T00:00:00.000Z | basic monthly | 9.90   |
| 75          | 2       |          | 2020-11-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 76          | 3       |          | 2020-09-07T00:00:00.000Z |                          | pro annual    | 199.00 |
| 77          | 2       | 3        | 2020-04-25T00:00:00.000Z | 2020-10-25T00:00:00.000Z | pro monthly   | 19.90  |
| 77          | 3       |          | 2020-10-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 78          | 2       | 4        | 2020-09-10T00:00:00.000Z | 2021-02-19T00:00:00.000Z | pro monthly   | 19.90  |
| 78          | 4       |          | 2021-02-19T00:00:00.000Z |                          | churn         |        |
| 79          | 2       |          | 2020-08-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 80          | 2       | 4        | 2020-09-30T00:00:00.000Z | 2021-01-17T00:00:00.000Z | pro monthly   | 19.90  |
| 80          | 4       |          | 2021-01-17T00:00:00.000Z |                          | churn         |        |
| 81          | 2       | 4        | 2020-06-05T00:00:00.000Z | 2020-10-20T00:00:00.000Z | pro monthly   | 19.90  |
| 81          | 4       |          | 2020-10-20T00:00:00.000Z |                          | churn         |        |
| 82          | 1       |          | 2020-05-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 83          | 1       | 2        | 2020-05-25T00:00:00.000Z | 2020-10-29T00:00:00.000Z | basic monthly | 9.90   |
| 83          | 2       | 3        | 2020-10-29T00:00:00.000Z | 2021-04-29T00:00:00.000Z | pro monthly   | 19.90  |
| 83          | 3       |          | 2021-04-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 84          | 1       | 4        | 2020-06-21T00:00:00.000Z | 2020-07-07T00:00:00.000Z | basic monthly | 9.90   |
| 84          | 4       |          | 2020-07-07T00:00:00.000Z |                          | churn         |        |
| 85          | 1       |          | 2020-08-20T00:00:00.000Z |                          | basic monthly | 9.90   |
| 86          | 3       |          | 2020-07-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 87          | 2       | 3        | 2020-08-15T00:00:00.000Z | 2020-09-15T00:00:00.000Z | pro monthly   | 19.90  |
| 87          | 3       |          | 2020-09-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 88          | 2       |          | 2021-01-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 89          | 2       | 4        | 2020-03-12T00:00:00.000Z | 2020-09-02T00:00:00.000Z | pro monthly   | 19.90  |
| 89          | 4       |          | 2020-09-02T00:00:00.000Z |                          | churn         |        |
| 90          | 1       | 2        | 2020-12-02T00:00:00.000Z | 2021-03-28T00:00:00.000Z | basic monthly | 9.90   |
| 90          | 2       | 3        | 2021-03-28T00:00:00.000Z | 2021-04-28T00:00:00.000Z | pro monthly   | 19.90  |
| 90          | 3       |          | 2021-04-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 91          | 2       | 4        | 2020-09-15T00:00:00.000Z | 2021-03-04T00:00:00.000Z | pro monthly   | 19.90  |
| 91          | 4       |          | 2021-03-04T00:00:00.000Z |                          | churn         |        |
| 92          | 1       |          | 2020-11-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 93          | 2       | 4        | 2020-03-21T00:00:00.000Z | 2020-08-30T00:00:00.000Z | pro monthly   | 19.90  |
| 93          | 4       |          | 2020-08-30T00:00:00.000Z |                          | churn         |        |
| 94          | 2       |          | 2020-12-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 95          | 1       | 2        | 2020-11-09T00:00:00.000Z | 2021-03-16T00:00:00.000Z | basic monthly | 9.90   |
| 95          | 2       |          | 2021-03-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 96          | 1       | 3        | 2020-08-29T00:00:00.000Z | 2021-01-23T00:00:00.000Z | basic monthly | 9.90   |
| 96          | 3       |          | 2021-01-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 97          | 1       |          | 2020-11-05T00:00:00.000Z |                          | basic monthly | 9.90   |
| 98          | 1       | 2        | 2020-01-12T00:00:00.000Z | 2020-01-22T00:00:00.000Z | basic monthly | 9.90   |
| 98          | 2       | 4        | 2020-01-22T00:00:00.000Z | 2020-04-05T00:00:00.000Z | pro monthly   | 19.90  |
| 98          | 4       |          | 2020-04-05T00:00:00.000Z |                          | churn         |        |
| 99          | 4       |          | 2020-12-12T00:00:00.000Z |                          | churn         |        |
| 100         | 1       | 2        | 2020-06-09T00:00:00.000Z | 2020-09-11T00:00:00.000Z | basic monthly | 9.90   |
| 100         | 2       |          | 2020-09-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 101         | 1       | 3        | 2020-06-15T00:00:00.000Z | 2020-07-20T00:00:00.000Z | basic monthly | 9.90   |
| 101         | 3       |          | 2020-07-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 102         | 1       | 2        | 2020-06-09T00:00:00.000Z | 2020-06-18T00:00:00.000Z | basic monthly | 9.90   |
| 102         | 2       | 4        | 2020-06-18T00:00:00.000Z | 2020-12-01T00:00:00.000Z | pro monthly   | 19.90  |
| 102         | 4       |          | 2020-12-01T00:00:00.000Z |                          | churn         |        |
| 103         | 2       | 4        | 2020-07-31T00:00:00.000Z | 2020-10-28T00:00:00.000Z | pro monthly   | 19.90  |
| 103         | 4       |          | 2020-10-28T00:00:00.000Z |                          | churn         |        |
| 104         | 2       |          | 2020-04-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 105         | 1       | 3        | 2020-09-27T00:00:00.000Z | 2020-10-22T00:00:00.000Z | basic monthly | 9.90   |
| 105         | 3       |          | 2020-10-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 106         | 3       |          | 2020-08-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 107         | 1       | 2        | 2020-01-19T00:00:00.000Z | 2020-03-23T00:00:00.000Z | basic monthly | 9.90   |
| 107         | 2       |          | 2020-03-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 108         | 4       |          | 2020-09-17T00:00:00.000Z |                          | churn         |        |
| 109         | 1       | 2        | 2020-10-19T00:00:00.000Z | 2021-03-20T00:00:00.000Z | basic monthly | 9.90   |
| 109         | 2       |          | 2021-03-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 110         | 2       |          | 2020-05-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 111         | 3       |          | 2020-09-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 112         | 2       | 4        | 2020-10-27T00:00:00.000Z | 2021-01-08T00:00:00.000Z | pro monthly   | 19.90  |
| 112         | 4       |          | 2021-01-08T00:00:00.000Z |                          | churn         |        |
| 113         | 1       | 2        | 2020-04-17T00:00:00.000Z | 2020-09-13T00:00:00.000Z | basic monthly | 9.90   |
| 113         | 2       | 4        | 2020-09-13T00:00:00.000Z | 2020-11-01T00:00:00.000Z | pro monthly   | 19.90  |
| 113         | 4       |          | 2020-11-01T00:00:00.000Z |                          | churn         |        |
| 114         | 1       | 3        | 2020-06-12T00:00:00.000Z | 2020-09-13T00:00:00.000Z | basic monthly | 9.90   |
| 114         | 3       |          | 2020-09-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 115         | 3       |          | 2020-08-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 116         | 1       | 4        | 2020-05-30T00:00:00.000Z | 2020-09-15T00:00:00.000Z | basic monthly | 9.90   |
| 116         | 4       |          | 2020-09-15T00:00:00.000Z |                          | churn         |        |
| 117         | 1       | 3        | 2020-05-29T00:00:00.000Z | 2020-11-14T00:00:00.000Z | basic monthly | 9.90   |
| 117         | 3       |          | 2020-11-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 118         | 1       | 4        | 2020-01-31T00:00:00.000Z | 2020-06-30T00:00:00.000Z | basic monthly | 9.90   |
| 118         | 4       |          | 2020-06-30T00:00:00.000Z |                          | churn         |        |
| 119         | 1       | 3        | 2020-11-16T00:00:00.000Z | 2021-02-27T00:00:00.000Z | basic monthly | 9.90   |
| 119         | 3       |          | 2021-02-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 120         | 2       | 3        | 2020-05-21T00:00:00.000Z | 2020-09-21T00:00:00.000Z | pro monthly   | 19.90  |
| 120         | 3       |          | 2020-09-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 121         | 1       | 3        | 2020-06-25T00:00:00.000Z | 2020-10-07T00:00:00.000Z | basic monthly | 9.90   |
| 121         | 3       |          | 2020-10-07T00:00:00.000Z |                          | pro annual    | 199.00 |
| 122         | 4       |          | 2020-04-06T00:00:00.000Z |                          | churn         |        |
| 123         | 1       | 4        | 2020-03-19T00:00:00.000Z | 2020-05-15T00:00:00.000Z | basic monthly | 9.90   |
| 123         | 4       |          | 2020-05-15T00:00:00.000Z |                          | churn         |        |
| 124         | 1       | 3        | 2020-03-24T00:00:00.000Z | 2020-06-20T00:00:00.000Z | basic monthly | 9.90   |
| 124         | 3       |          | 2020-06-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 125         | 1       | 4        | 2020-08-14T00:00:00.000Z | 2020-12-03T00:00:00.000Z | basic monthly | 9.90   |
| 125         | 4       |          | 2020-12-03T00:00:00.000Z |                          | churn         |        |
| 126         | 1       |          | 2020-09-22T00:00:00.000Z |                          | basic monthly | 9.90   |
| 127         | 2       | 4        | 2020-05-30T00:00:00.000Z | 2020-08-11T00:00:00.000Z | pro monthly   | 19.90  |
| 127         | 4       |          | 2020-08-11T00:00:00.000Z |                          | churn         |        |
| 128         | 4       |          | 2020-01-26T00:00:00.000Z |                          | churn         |        |
| 129         | 1       |          | 2020-07-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 130         | 2       |          | 2020-09-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 131         | 3       |          | 2020-10-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 132         | 1       | 4        | 2020-10-25T00:00:00.000Z | 2021-01-07T00:00:00.000Z | basic monthly | 9.90   |
| 132         | 4       |          | 2021-01-07T00:00:00.000Z |                          | churn         |        |
| 133         | 1       | 3        | 2020-04-05T00:00:00.000Z | 2020-07-11T00:00:00.000Z | basic monthly | 9.90   |
| 133         | 3       |          | 2020-07-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 134         | 2       |          | 2020-07-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 135         | 4       |          | 2020-12-30T00:00:00.000Z |                          | churn         |        |
| 136         | 4       |          | 2020-08-23T00:00:00.000Z |                          | churn         |        |
| 137         | 2       |          | 2020-08-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 138         | 1       | 2        | 2020-11-02T00:00:00.000Z | 2020-12-25T00:00:00.000Z | basic monthly | 9.90   |
| 138         | 2       | 3        | 2020-12-25T00:00:00.000Z | 2021-01-25T00:00:00.000Z | pro monthly   | 19.90  |
| 138         | 3       |          | 2021-01-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 139         | 2       |          | 2020-07-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 140         | 1       |          | 2021-01-01T00:00:00.000Z |                          | basic monthly | 9.90   |
| 141         | 1       | 3        | 2020-04-26T00:00:00.000Z | 2020-10-18T00:00:00.000Z | basic monthly | 9.90   |
| 141         | 3       |          | 2020-10-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 142         | 2       |          | 2020-06-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 143         | 1       | 4        | 2020-12-27T00:00:00.000Z | 2021-03-03T00:00:00.000Z | basic monthly | 9.90   |
| 143         | 4       |          | 2021-03-03T00:00:00.000Z |                          | churn         |        |
| 144         | 1       | 2        | 2020-09-11T00:00:00.000Z | 2021-02-09T00:00:00.000Z | basic monthly | 9.90   |
| 144         | 2       |          | 2021-02-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 145         | 2       |          | 2020-01-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 146         | 1       | 2        | 2020-07-12T00:00:00.000Z | 2020-10-28T00:00:00.000Z | basic monthly | 9.90   |
| 146         | 2       | 4        | 2020-10-28T00:00:00.000Z | 2020-12-18T00:00:00.000Z | pro monthly   | 19.90  |
| 146         | 4       |          | 2020-12-18T00:00:00.000Z |                          | churn         |        |
| 147         | 2       |          | 2020-12-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 148         | 2       |          | 2020-03-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 149         | 1       |          | 2020-12-26T00:00:00.000Z |                          | basic monthly | 9.90   |
| 150         | 2       |          | 2020-02-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 151         | 1       | 2        | 2020-09-14T00:00:00.000Z | 2020-09-17T00:00:00.000Z | basic monthly | 9.90   |
| 151         | 2       |          | 2020-09-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 152         | 1       | 2        | 2020-10-21T00:00:00.000Z | 2021-03-08T00:00:00.000Z | basic monthly | 9.90   |
| 152         | 2       |          | 2021-03-08T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 153         | 2       |          | 2020-12-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 154         | 1       | 2        | 2020-03-25T00:00:00.000Z | 2020-05-01T00:00:00.000Z | basic monthly | 9.90   |
| 154         | 2       |          | 2020-05-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 155         | 4       |          | 2020-09-20T00:00:00.000Z |                          | churn         |        |
| 156         | 4       |          | 2020-01-26T00:00:00.000Z |                          | churn         |        |
| 157         | 1       | 3        | 2020-04-30T00:00:00.000Z | 2020-05-11T00:00:00.000Z | basic monthly | 9.90   |
| 157         | 3       |          | 2020-05-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 158         | 1       | 2        | 2020-03-09T00:00:00.000Z | 2020-05-09T00:00:00.000Z | basic monthly | 9.90   |
| 158         | 2       |          | 2020-05-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 159         | 2       |          | 2020-09-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 160         | 1       |          | 2020-11-23T00:00:00.000Z |                          | basic monthly | 9.90   |
| 161         | 4       |          | 2020-12-24T00:00:00.000Z |                          | churn         |        |
| 162         | 4       |          | 2020-03-01T00:00:00.000Z |                          | churn         |        |
| 163         | 2       |          | 2020-12-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 164         | 2       | 4        | 2020-12-04T00:00:00.000Z | 2020-12-24T00:00:00.000Z | pro monthly   | 19.90  |
| 164         | 4       |          | 2020-12-24T00:00:00.000Z |                          | churn         |        |
| 165         | 1       | 3        | 2020-10-12T00:00:00.000Z | 2020-11-08T00:00:00.000Z | basic monthly | 9.90   |
| 165         | 3       |          | 2020-11-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 166         | 1       | 4        | 2020-07-10T00:00:00.000Z | 2020-09-22T00:00:00.000Z | basic monthly | 9.90   |
| 166         | 4       |          | 2020-09-22T00:00:00.000Z |                          | churn         |        |
| 167         | 2       |          | 2020-05-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 168         | 2       |          | 2020-03-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 169         | 4       |          | 2020-04-14T00:00:00.000Z |                          | churn         |        |
| 170         | 1       | 2        | 2020-04-25T00:00:00.000Z | 2020-08-28T00:00:00.000Z | basic monthly | 9.90   |
| 170         | 2       | 3        | 2020-08-28T00:00:00.000Z | 2020-12-28T00:00:00.000Z | pro monthly   | 19.90  |
| 170         | 3       |          | 2020-12-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 171         | 2       |          | 2020-12-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 172         | 1       | 4        | 2020-12-12T00:00:00.000Z | 2021-02-15T00:00:00.000Z | basic monthly | 9.90   |
| 172         | 4       |          | 2021-02-15T00:00:00.000Z |                          | churn         |        |
| 173         | 2       |          | 2020-07-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 174         | 1       | 3        | 2020-02-08T00:00:00.000Z | 2020-07-10T00:00:00.000Z | basic monthly | 9.90   |
| 174         | 3       |          | 2020-07-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 175         | 2       | 4        | 2020-08-22T00:00:00.000Z | 2020-11-23T00:00:00.000Z | pro monthly   | 19.90  |
| 175         | 4       |          | 2020-11-23T00:00:00.000Z |                          | churn         |        |
| 176         | 1       |          | 2020-09-20T00:00:00.000Z |                          | basic monthly | 9.90   |
| 177         | 2       | 4        | 2020-05-08T00:00:00.000Z | 2020-09-09T00:00:00.000Z | pro monthly   | 19.90  |
| 177         | 4       |          | 2020-09-09T00:00:00.000Z |                          | churn         |        |
| 178         | 4       |          | 2020-02-29T00:00:00.000Z |                          | churn         |        |
| 179         | 2       | 4        | 2020-06-20T00:00:00.000Z | 2020-09-25T00:00:00.000Z | pro monthly   | 19.90  |
| 179         | 4       |          | 2020-09-25T00:00:00.000Z |                          | churn         |        |
| 180         | 1       | 2        | 2020-11-07T00:00:00.000Z | 2021-01-17T00:00:00.000Z | basic monthly | 9.90   |
| 180         | 2       |          | 2021-01-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 181         | 2       |          | 2020-02-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 182         | 1       | 4        | 2020-10-03T00:00:00.000Z | 2021-02-25T00:00:00.000Z | basic monthly | 9.90   |
| 182         | 4       |          | 2021-02-25T00:00:00.000Z |                          | churn         |        |
| 183         | 2       |          | 2020-10-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 184         | 1       |          | 2020-02-23T00:00:00.000Z |                          | basic monthly | 9.90   |
| 185         | 2       |          | 2020-12-10T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 186         | 2       | 4        | 2020-10-07T00:00:00.000Z | 2021-02-05T00:00:00.000Z | pro monthly   | 19.90  |
| 186         | 4       |          | 2021-02-05T00:00:00.000Z |                          | churn         |        |
| 187         | 3       |          | 2020-09-26T00:00:00.000Z |                          | pro annual    | 199.00 |
| 188         | 1       |          | 2020-02-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 189         | 2       |          | 2020-12-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 190         | 1       | 3        | 2020-04-27T00:00:00.000Z | 2020-09-04T00:00:00.000Z | basic monthly | 9.90   |
| 190         | 3       |          | 2020-09-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 191         | 2       |          | 2020-01-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 192         | 1       |          | 2020-08-05T00:00:00.000Z |                          | basic monthly | 9.90   |
| 193         | 1       | 2        | 2020-05-26T00:00:00.000Z | 2020-09-21T00:00:00.000Z | basic monthly | 9.90   |
| 193         | 2       | 3        | 2020-09-21T00:00:00.000Z | 2020-10-21T00:00:00.000Z | pro monthly   | 19.90  |
| 193         | 3       |          | 2020-10-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 194         | 2       | 4        | 2020-11-27T00:00:00.000Z | 2021-01-13T00:00:00.000Z | pro monthly   | 19.90  |
| 194         | 4       |          | 2021-01-13T00:00:00.000Z |                          | churn         |        |
| 195         | 2       | 3        | 2020-02-15T00:00:00.000Z | 2020-06-15T00:00:00.000Z | pro monthly   | 19.90  |
| 195         | 3       |          | 2020-06-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 196         | 2       |          | 2020-03-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 197         | 2       | 4        | 2020-05-24T00:00:00.000Z | 2020-07-01T00:00:00.000Z | pro monthly   | 19.90  |
| 197         | 4       |          | 2020-07-01T00:00:00.000Z |                          | churn         |        |
| 198         | 1       | 4        | 2020-11-18T00:00:00.000Z | 2021-03-16T00:00:00.000Z | basic monthly | 9.90   |
| 198         | 4       |          | 2021-03-16T00:00:00.000Z |                          | churn         |        |
| 199         | 2       |          | 2020-12-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 200         | 2       |          | 2020-04-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 201         | 1       |          | 2020-03-14T00:00:00.000Z |                          | basic monthly | 9.90   |
| 202         | 2       |          | 2020-07-08T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 203         | 1       | 3        | 2020-08-31T00:00:00.000Z | 2020-09-19T00:00:00.000Z | basic monthly | 9.90   |
| 203         | 3       |          | 2020-09-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 204         | 1       | 4        | 2020-06-17T00:00:00.000Z | 2020-10-05T00:00:00.000Z | basic monthly | 9.90   |
| 204         | 4       |          | 2020-10-05T00:00:00.000Z |                          | churn         |        |
| 205         | 1       | 3        | 2020-11-09T00:00:00.000Z | 2021-03-13T00:00:00.000Z | basic monthly | 9.90   |
| 205         | 3       |          | 2021-03-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 206         | 1       | 3        | 2020-03-24T00:00:00.000Z | 2020-09-02T00:00:00.000Z | basic monthly | 9.90   |
| 206         | 3       |          | 2020-09-02T00:00:00.000Z |                          | pro annual    | 199.00 |
| 207         | 1       |          | 2020-05-27T00:00:00.000Z |                          | basic monthly | 9.90   |
| 208         | 2       | 3        | 2020-06-19T00:00:00.000Z | 2020-09-19T00:00:00.000Z | pro monthly   | 19.90  |
| 208         | 3       |          | 2020-09-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 209         | 2       |          | 2020-08-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 210         | 2       | 4        | 2020-02-16T00:00:00.000Z | 2020-06-21T00:00:00.000Z | pro monthly   | 19.90  |
| 210         | 4       |          | 2020-06-21T00:00:00.000Z |                          | churn         |        |
| 211         | 1       | 3        | 2020-10-17T00:00:00.000Z | 2020-10-18T00:00:00.000Z | basic monthly | 9.90   |
| 211         | 3       |          | 2020-10-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 212         | 1       |          | 2020-03-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 213         | 3       |          | 2020-08-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 214         | 1       | 2        | 2020-02-10T00:00:00.000Z | 2020-05-07T00:00:00.000Z | basic monthly | 9.90   |
| 214         | 2       | 4        | 2020-05-07T00:00:00.000Z | 2020-08-21T00:00:00.000Z | pro monthly   | 19.90  |
| 214         | 4       |          | 2020-08-21T00:00:00.000Z |                          | churn         |        |
| 215         | 2       | 3        | 2020-04-23T00:00:00.000Z | 2020-07-23T00:00:00.000Z | pro monthly   | 19.90  |
| 215         | 3       |          | 2020-07-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 216         | 2       |          | 2020-09-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 217         | 2       |          | 2020-12-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 218         | 1       | 4        | 2020-12-09T00:00:00.000Z | 2021-04-24T00:00:00.000Z | basic monthly | 9.90   |
| 218         | 4       |          | 2021-04-24T00:00:00.000Z |                          | churn         |        |
| 219         | 2       | 3        | 2020-10-29T00:00:00.000Z | 2021-04-29T00:00:00.000Z | pro monthly   | 19.90  |
| 219         | 3       |          | 2021-04-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 220         | 4       |          | 2020-06-15T00:00:00.000Z |                          | churn         |        |
| 221         | 1       | 3        | 2020-10-04T00:00:00.000Z | 2021-03-29T00:00:00.000Z | basic monthly | 9.90   |
| 221         | 3       |          | 2021-03-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 222         | 1       | 4        | 2020-09-05T00:00:00.000Z | 2020-12-25T00:00:00.000Z | basic monthly | 9.90   |
| 222         | 4       |          | 2020-12-25T00:00:00.000Z |                          | churn         |        |
| 223         | 1       | 3        | 2020-08-08T00:00:00.000Z | 2021-01-31T00:00:00.000Z | basic monthly | 9.90   |
| 223         | 3       |          | 2021-01-31T00:00:00.000Z |                          | pro annual    | 199.00 |
| 224         | 2       | 3        | 2020-02-02T00:00:00.000Z | 2020-05-02T00:00:00.000Z | pro monthly   | 19.90  |
| 224         | 3       |          | 2020-05-02T00:00:00.000Z |                          | pro annual    | 199.00 |
| 225         | 4       |          | 2021-01-03T00:00:00.000Z |                          | churn         |        |
| 226         | 1       | 2        | 2020-11-08T00:00:00.000Z | 2020-11-24T00:00:00.000Z | basic monthly | 9.90   |
| 226         | 2       |          | 2020-11-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 227         | 2       | 3        | 2020-03-09T00:00:00.000Z | 2020-08-09T00:00:00.000Z | pro monthly   | 19.90  |
| 227         | 3       |          | 2020-08-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 228         | 2       | 3        | 2020-10-09T00:00:00.000Z | 2021-02-09T00:00:00.000Z | pro monthly   | 19.90  |
| 228         | 3       |          | 2021-02-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 229         | 1       | 4        | 2020-07-31T00:00:00.000Z | 2021-01-24T00:00:00.000Z | basic monthly | 9.90   |
| 229         | 4       |          | 2021-01-24T00:00:00.000Z |                          | churn         |        |
| 230         | 4       |          | 2020-04-15T00:00:00.000Z |                          | churn         |        |
| 231         | 1       | 2        | 2020-05-20T00:00:00.000Z | 2020-07-09T00:00:00.000Z | basic monthly | 9.90   |
| 231         | 2       |          | 2020-07-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 232         | 1       | 2        | 2020-09-02T00:00:00.000Z | 2021-02-03T00:00:00.000Z | basic monthly | 9.90   |
| 232         | 2       |          | 2021-02-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 233         | 1       | 3        | 2020-08-07T00:00:00.000Z | 2020-10-29T00:00:00.000Z | basic monthly | 9.90   |
| 233         | 3       |          | 2020-10-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 234         | 2       |          | 2020-01-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 235         | 1       | 2        | 2020-08-27T00:00:00.000Z | 2020-10-17T00:00:00.000Z | basic monthly | 9.90   |
| 235         | 2       |          | 2020-10-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 236         | 1       |          | 2020-06-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 237         | 1       | 2        | 2020-11-14T00:00:00.000Z | 2021-03-24T00:00:00.000Z | basic monthly | 9.90   |
| 237         | 2       |          | 2021-03-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 238         | 1       | 3        | 2020-11-03T00:00:00.000Z | 2020-12-23T00:00:00.000Z | basic monthly | 9.90   |
| 238         | 3       |          | 2020-12-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 239         | 1       | 4        | 2020-08-22T00:00:00.000Z | 2020-10-20T00:00:00.000Z | basic monthly | 9.90   |
| 239         | 4       |          | 2020-10-20T00:00:00.000Z |                          | churn         |        |
| 240         | 1       | 3        | 2020-01-21T00:00:00.000Z | 2020-03-03T00:00:00.000Z | basic monthly | 9.90   |
| 240         | 3       | 4        | 2020-03-03T00:00:00.000Z | 2021-03-03T00:00:00.000Z | pro annual    | 199.00 |
| 240         | 4       |          | 2021-03-03T00:00:00.000Z |                          | churn         |        |
| 241         | 1       | 3        | 2020-10-10T00:00:00.000Z | 2020-11-11T00:00:00.000Z | basic monthly | 9.90   |
| 241         | 3       |          | 2020-11-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 242         | 2       |          | 2020-10-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 243         | 1       |          | 2020-09-11T00:00:00.000Z |                          | basic monthly | 9.90   |
| 244         | 2       |          | 2020-03-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 245         | 4       |          | 2020-04-04T00:00:00.000Z |                          | churn         |        |
| 246         | 1       |          | 2020-02-03T00:00:00.000Z |                          | basic monthly | 9.90   |
| 247         | 1       | 2        | 2020-07-14T00:00:00.000Z | 2020-08-20T00:00:00.000Z | basic monthly | 9.90   |
| 247         | 2       |          | 2020-08-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 248         | 1       |          | 2020-11-16T00:00:00.000Z |                          | basic monthly | 9.90   |
| 249         | 2       |          | 2020-02-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 250         | 2       | 3        | 2020-06-22T00:00:00.000Z | 2020-09-22T00:00:00.000Z | pro monthly   | 19.90  |
| 250         | 3       |          | 2020-09-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 251         | 4       |          | 2020-03-16T00:00:00.000Z |                          | churn         |        |
| 252         | 1       | 2        | 2020-11-15T00:00:00.000Z | 2020-12-23T00:00:00.000Z | basic monthly | 9.90   |
| 252         | 2       |          | 2020-12-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 253         | 2       | 4        | 2020-05-22T00:00:00.000Z | 2020-10-12T00:00:00.000Z | pro monthly   | 19.90  |
| 253         | 4       |          | 2020-10-12T00:00:00.000Z |                          | churn         |        |
| 254         | 4       |          | 2020-07-30T00:00:00.000Z |                          | churn         |        |
| 255         | 2       | 3        | 2020-04-05T00:00:00.000Z | 2020-10-05T00:00:00.000Z | pro monthly   | 19.90  |
| 255         | 3       |          | 2020-10-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 256         | 1       | 2        | 2020-07-20T00:00:00.000Z | 2020-11-23T00:00:00.000Z | basic monthly | 9.90   |
| 256         | 2       |          | 2020-11-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 257         | 2       | 3        | 2020-01-22T00:00:00.000Z | 2020-04-22T00:00:00.000Z | pro monthly   | 19.90  |
| 257         | 3       | 4        | 2020-04-22T00:00:00.000Z | 2021-04-22T00:00:00.000Z | pro annual    | 199.00 |
| 257         | 4       |          | 2021-04-22T00:00:00.000Z |                          | churn         |        |
| 258         | 1       | 3        | 2020-06-26T00:00:00.000Z | 2020-07-06T00:00:00.000Z | basic monthly | 9.90   |
| 258         | 3       |          | 2020-07-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 259         | 1       | 2        | 2020-11-16T00:00:00.000Z | 2021-02-13T00:00:00.000Z | basic monthly | 9.90   |
| 259         | 2       |          | 2021-02-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 260         | 2       |          | 2020-09-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 261         | 2       | 3        | 2020-03-19T00:00:00.000Z | 2020-05-19T00:00:00.000Z | pro monthly   | 19.90  |
| 261         | 3       |          | 2020-05-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 262         | 1       |          | 2020-05-21T00:00:00.000Z |                          | basic monthly | 9.90   |
| 263         | 2       | 4        | 2020-07-17T00:00:00.000Z | 2020-07-20T00:00:00.000Z | pro monthly   | 19.90  |
| 263         | 4       |          | 2020-07-20T00:00:00.000Z |                          | churn         |        |
| 264         | 2       | 4        | 2020-09-19T00:00:00.000Z | 2020-12-07T00:00:00.000Z | pro monthly   | 19.90  |
| 264         | 4       |          | 2020-12-07T00:00:00.000Z |                          | churn         |        |
| 265         | 1       | 4        | 2020-06-20T00:00:00.000Z | 2020-07-14T00:00:00.000Z | basic monthly | 9.90   |
| 265         | 4       |          | 2020-07-14T00:00:00.000Z |                          | churn         |        |
| 266         | 1       | 3        | 2020-07-27T00:00:00.000Z | 2020-12-04T00:00:00.000Z | basic monthly | 9.90   |
| 266         | 3       |          | 2020-12-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 267         | 1       | 3        | 2020-09-26T00:00:00.000Z | 2020-10-10T00:00:00.000Z | basic monthly | 9.90   |
| 267         | 3       |          | 2020-10-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 268         | 1       | 4        | 2020-10-14T00:00:00.000Z | 2020-11-07T00:00:00.000Z | basic monthly | 9.90   |
| 268         | 4       |          | 2020-11-07T00:00:00.000Z |                          | churn         |        |
| 269         | 1       | 2        | 2020-08-05T00:00:00.000Z | 2020-12-06T00:00:00.000Z | basic monthly | 9.90   |
| 269         | 2       |          | 2020-12-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 270         | 2       | 3        | 2020-07-12T00:00:00.000Z | 2021-01-12T00:00:00.000Z | pro monthly   | 19.90  |
| 270         | 3       |          | 2021-01-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 271         | 2       |          | 2020-09-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 272         | 1       | 3        | 2020-12-26T00:00:00.000Z | 2021-01-17T00:00:00.000Z | basic monthly | 9.90   |
| 272         | 3       |          | 2021-01-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 273         | 1       |          | 2020-02-21T00:00:00.000Z |                          | basic monthly | 9.90   |
| 274         | 1       |          | 2020-03-08T00:00:00.000Z |                          | basic monthly | 9.90   |
| 275         | 1       | 4        | 2020-05-04T00:00:00.000Z | 2020-09-09T00:00:00.000Z | basic monthly | 9.90   |
| 275         | 4       |          | 2020-09-09T00:00:00.000Z |                          | churn         |        |
| 276         | 2       | 3        | 2021-01-01T00:00:00.000Z | 2021-03-01T00:00:00.000Z | pro monthly   | 19.90  |
| 276         | 3       |          | 2021-03-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 277         | 1       |          | 2020-08-13T00:00:00.000Z |                          | basic monthly | 9.90   |
| 278         | 2       | 3        | 2020-08-08T00:00:00.000Z | 2020-11-08T00:00:00.000Z | pro monthly   | 19.90  |
| 278         | 3       |          | 2020-11-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 279         | 3       |          | 2020-04-07T00:00:00.000Z |                          | pro annual    | 199.00 |
| 280         | 1       | 2        | 2020-06-24T00:00:00.000Z | 2020-10-28T00:00:00.000Z | basic monthly | 9.90   |
| 280         | 2       | 4        | 2020-10-28T00:00:00.000Z | 2021-02-23T00:00:00.000Z | pro monthly   | 19.90  |
| 280         | 4       |          | 2021-02-23T00:00:00.000Z |                          | churn         |        |
| 281         | 1       |          | 2020-01-08T00:00:00.000Z |                          | basic monthly | 9.90   |
| 282         | 2       |          | 2020-06-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 283         | 1       | 2        | 2020-06-18T00:00:00.000Z | 2020-09-11T00:00:00.000Z | basic monthly | 9.90   |
| 283         | 2       | 3        | 2020-09-11T00:00:00.000Z | 2020-12-11T00:00:00.000Z | pro monthly   | 19.90  |
| 283         | 3       |          | 2020-12-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 284         | 2       | 4        | 2020-08-03T00:00:00.000Z | 2020-11-18T00:00:00.000Z | pro monthly   | 19.90  |
| 284         | 4       |          | 2020-11-18T00:00:00.000Z |                          | churn         |        |
| 285         | 4       |          | 2020-07-13T00:00:00.000Z |                          | churn         |        |
| 286         | 2       |          | 2020-03-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 287         | 1       | 3        | 2020-08-30T00:00:00.000Z | 2020-12-09T00:00:00.000Z | basic monthly | 9.90   |
| 287         | 3       |          | 2020-12-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 288         | 1       | 4        | 2020-12-05T00:00:00.000Z | 2020-12-06T00:00:00.000Z | basic monthly | 9.90   |
| 288         | 4       |          | 2020-12-06T00:00:00.000Z |                          | churn         |        |
| 289         | 2       |          | 2020-01-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 290         | 1       |          | 2020-01-17T00:00:00.000Z |                          | basic monthly | 9.90   |
| 291         | 1       | 3        | 2020-03-10T00:00:00.000Z | 2020-08-16T00:00:00.000Z | basic monthly | 9.90   |
| 291         | 3       |          | 2020-08-16T00:00:00.000Z |                          | pro annual    | 199.00 |
| 292         | 1       | 3        | 2020-08-21T00:00:00.000Z | 2020-10-18T00:00:00.000Z | basic monthly | 9.90   |
| 292         | 3       |          | 2020-10-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 293         | 1       | 2        | 2020-11-06T00:00:00.000Z | 2021-03-15T00:00:00.000Z | basic monthly | 9.90   |
| 293         | 2       | 4        | 2021-03-15T00:00:00.000Z | 2021-03-18T00:00:00.000Z | pro monthly   | 19.90  |
| 293         | 4       |          | 2021-03-18T00:00:00.000Z |                          | churn         |        |
| 294         | 4       |          | 2020-01-26T00:00:00.000Z |                          | churn         |        |
| 295         | 1       | 2        | 2020-06-08T00:00:00.000Z | 2020-08-17T00:00:00.000Z | basic monthly | 9.90   |
| 295         | 2       |          | 2020-08-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 296         | 4       |          | 2020-10-24T00:00:00.000Z |                          | churn         |        |
| 297         | 2       | 3        | 2020-08-20T00:00:00.000Z | 2020-12-20T00:00:00.000Z | pro monthly   | 19.90  |
| 297         | 3       |          | 2020-12-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 298         | 1       | 2        | 2020-11-02T00:00:00.000Z | 2020-12-13T00:00:00.000Z | basic monthly | 9.90   |
| 298         | 2       |          | 2020-12-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 299         | 1       | 2        | 2020-09-20T00:00:00.000Z | 2020-10-28T00:00:00.000Z | basic monthly | 9.90   |
| 299         | 2       | 3        | 2020-10-28T00:00:00.000Z | 2021-01-28T00:00:00.000Z | pro monthly   | 19.90  |
| 299         | 3       |          | 2021-01-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 300         | 1       | 3        | 2020-04-13T00:00:00.000Z | 2020-10-04T00:00:00.000Z | basic monthly | 9.90   |
| 300         | 3       |          | 2020-10-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 301         | 1       | 2        | 2020-05-14T00:00:00.000Z | 2020-10-30T00:00:00.000Z | basic monthly | 9.90   |
| 301         | 2       | 3        | 2020-10-30T00:00:00.000Z | 2021-01-30T00:00:00.000Z | pro monthly   | 19.90  |
| 301         | 3       |          | 2021-01-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 302         | 2       | 4        | 2020-01-16T00:00:00.000Z | 2020-01-22T00:00:00.000Z | pro monthly   | 19.90  |
| 302         | 4       |          | 2020-01-22T00:00:00.000Z |                          | churn         |        |
| 303         | 1       | 4        | 2020-02-20T00:00:00.000Z | 2020-06-15T00:00:00.000Z | basic monthly | 9.90   |
| 303         | 4       |          | 2020-06-15T00:00:00.000Z |                          | churn         |        |
| 304         | 1       | 4        | 2021-01-04T00:00:00.000Z | 2021-01-27T00:00:00.000Z | basic monthly | 9.90   |
| 304         | 4       |          | 2021-01-27T00:00:00.000Z |                          | churn         |        |
| 305         | 1       |          | 2020-11-23T00:00:00.000Z |                          | basic monthly | 9.90   |
| 306         | 2       |          | 2020-09-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 307         | 1       | 2        | 2020-04-08T00:00:00.000Z | 2020-09-27T00:00:00.000Z | basic monthly | 9.90   |
| 307         | 2       | 3        | 2020-09-27T00:00:00.000Z | 2020-10-27T00:00:00.000Z | pro monthly   | 19.90  |
| 307         | 3       |          | 2020-10-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 308         | 1       | 4        | 2020-04-19T00:00:00.000Z | 2020-07-22T00:00:00.000Z | basic monthly | 9.90   |
| 308         | 4       |          | 2020-07-22T00:00:00.000Z |                          | churn         |        |
| 309         | 2       |          | 2020-12-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 310         | 1       | 3        | 2020-08-08T00:00:00.000Z | 2021-01-05T00:00:00.000Z | basic monthly | 9.90   |
| 310         | 3       |          | 2021-01-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 311         | 1       | 4        | 2020-12-10T00:00:00.000Z | 2021-03-01T00:00:00.000Z | basic monthly | 9.90   |
| 311         | 4       |          | 2021-03-01T00:00:00.000Z |                          | churn         |        |
| 312         | 1       | 2        | 2020-01-16T00:00:00.000Z | 2020-04-19T00:00:00.000Z | basic monthly | 9.90   |
| 312         | 2       |          | 2020-04-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 313         | 1       | 3        | 2020-01-22T00:00:00.000Z | 2020-06-29T00:00:00.000Z | basic monthly | 9.90   |
| 313         | 3       |          | 2020-06-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 314         | 4       |          | 2020-11-18T00:00:00.000Z |                          | churn         |        |
| 315         | 1       | 2        | 2020-12-20T00:00:00.000Z | 2020-12-21T00:00:00.000Z | basic monthly | 9.90   |
| 315         | 2       |          | 2020-12-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 316         | 2       |          | 2020-04-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 317         | 4       |          | 2020-10-18T00:00:00.000Z |                          | churn         |        |
| 318         | 1       | 2        | 2020-06-27T00:00:00.000Z | 2020-09-30T00:00:00.000Z | basic monthly | 9.90   |
| 318         | 2       | 3        | 2020-09-30T00:00:00.000Z | 2020-11-30T00:00:00.000Z | pro monthly   | 19.90  |
| 318         | 3       |          | 2020-11-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 319         | 2       |          | 2020-11-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 320         | 2       | 3        | 2020-10-04T00:00:00.000Z | 2021-04-04T00:00:00.000Z | pro monthly   | 19.90  |
| 320         | 3       |          | 2021-04-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 321         | 2       |          | 2020-03-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 322         | 3       |          | 2020-12-26T00:00:00.000Z |                          | pro annual    | 199.00 |
| 323         | 1       | 2        | 2020-10-27T00:00:00.000Z | 2021-04-14T00:00:00.000Z | basic monthly | 9.90   |
| 323         | 2       |          | 2021-04-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 324         | 1       | 4        | 2020-05-14T00:00:00.000Z | 2020-07-26T00:00:00.000Z | basic monthly | 9.90   |
| 324         | 4       |          | 2020-07-26T00:00:00.000Z |                          | churn         |        |
| 325         | 4       |          | 2020-05-25T00:00:00.000Z |                          | churn         |        |
| 326         | 3       |          | 2020-11-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 327         | 1       | 2        | 2020-04-21T00:00:00.000Z | 2020-08-17T00:00:00.000Z | basic monthly | 9.90   |
| 327         | 2       |          | 2020-08-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 328         | 1       | 2        | 2020-10-13T00:00:00.000Z | 2021-02-02T00:00:00.000Z | basic monthly | 9.90   |
| 328         | 2       |          | 2021-02-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 329         | 4       |          | 2020-05-03T00:00:00.000Z |                          | churn         |        |
| 330         | 4       |          | 2020-01-27T00:00:00.000Z |                          | churn         |        |
| 331         | 1       | 4        | 2020-04-19T00:00:00.000Z | 2020-09-14T00:00:00.000Z | basic monthly | 9.90   |
| 331         | 4       |          | 2020-09-14T00:00:00.000Z |                          | churn         |        |
| 332         | 1       | 2        | 2020-10-18T00:00:00.000Z | 2020-11-17T00:00:00.000Z | basic monthly | 9.90   |
| 332         | 2       |          | 2020-11-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 333         | 2       | 4        | 2020-01-26T00:00:00.000Z | 2020-06-15T00:00:00.000Z | pro monthly   | 19.90  |
| 333         | 4       |          | 2020-06-15T00:00:00.000Z |                          | churn         |        |
| 334         | 1       | 2        | 2020-08-14T00:00:00.000Z | 2021-02-09T00:00:00.000Z | basic monthly | 9.90   |
| 334         | 2       |          | 2021-02-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 335         | 1       |          | 2020-10-02T00:00:00.000Z |                          | basic monthly | 9.90   |
| 336         | 1       | 2        | 2020-06-30T00:00:00.000Z | 2020-07-22T00:00:00.000Z | basic monthly | 9.90   |
| 336         | 2       |          | 2020-07-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 337         | 1       |          | 2020-11-23T00:00:00.000Z |                          | basic monthly | 9.90   |
| 338         | 1       |          | 2020-12-19T00:00:00.000Z |                          | basic monthly | 9.90   |
| 339         | 1       |          | 2020-05-13T00:00:00.000Z |                          | basic monthly | 9.90   |
| 340         | 1       | 2        | 2020-07-04T00:00:00.000Z | 2020-07-19T00:00:00.000Z | basic monthly | 9.90   |
| 340         | 2       |          | 2020-07-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 341         | 1       | 2        | 2020-10-24T00:00:00.000Z | 2021-01-30T00:00:00.000Z | basic monthly | 9.90   |
| 341         | 2       |          | 2021-01-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 342         | 1       | 4        | 2020-06-28T00:00:00.000Z | 2020-08-19T00:00:00.000Z | basic monthly | 9.90   |
| 342         | 4       |          | 2020-08-19T00:00:00.000Z |                          | churn         |        |
| 343         | 1       |          | 2020-02-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 344         | 2       | 4        | 2020-09-29T00:00:00.000Z | 2021-02-15T00:00:00.000Z | pro monthly   | 19.90  |
| 344         | 4       |          | 2021-02-15T00:00:00.000Z |                          | churn         |        |
| 345         | 1       | 2        | 2020-04-24T00:00:00.000Z | 2020-06-07T00:00:00.000Z | basic monthly | 9.90   |
| 345         | 2       | 3        | 2020-06-07T00:00:00.000Z | 2020-08-07T00:00:00.000Z | pro monthly   | 19.90  |
| 345         | 3       |          | 2020-08-07T00:00:00.000Z |                          | pro annual    | 199.00 |
| 346         | 2       | 3        | 2020-11-20T00:00:00.000Z | 2021-04-20T00:00:00.000Z | pro monthly   | 19.90  |
| 346         | 3       |          | 2021-04-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 347         | 1       | 3        | 2020-06-06T00:00:00.000Z | 2020-07-14T00:00:00.000Z | basic monthly | 9.90   |
| 347         | 3       |          | 2020-07-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 348         | 1       | 4        | 2020-09-21T00:00:00.000Z | 2020-09-28T00:00:00.000Z | basic monthly | 9.90   |
| 348         | 4       |          | 2020-09-28T00:00:00.000Z |                          | churn         |        |
| 349         | 1       | 3        | 2020-06-23T00:00:00.000Z | 2020-08-22T00:00:00.000Z | basic monthly | 9.90   |
| 349         | 3       |          | 2020-08-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 350         | 1       |          | 2020-05-02T00:00:00.000Z |                          | basic monthly | 9.90   |
| 351         | 1       | 2        | 2020-05-31T00:00:00.000Z | 2020-07-06T00:00:00.000Z | basic monthly | 9.90   |
| 351         | 2       |          | 2020-07-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 352         | 1       | 2        | 2020-09-28T00:00:00.000Z | 2021-03-06T00:00:00.000Z | basic monthly | 9.90   |
| 352         | 2       |          | 2021-03-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 353         | 3       |          | 2020-12-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 354         | 4       |          | 2020-03-26T00:00:00.000Z |                          | churn         |        |
| 355         | 2       |          | 2020-11-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 356         | 1       | 3        | 2020-04-16T00:00:00.000Z | 2020-07-02T00:00:00.000Z | basic monthly | 9.90   |
| 356         | 3       |          | 2020-07-02T00:00:00.000Z |                          | pro annual    | 199.00 |
| 357         | 2       | 3        | 2020-10-14T00:00:00.000Z | 2021-01-14T00:00:00.000Z | pro monthly   | 19.90  |
| 357         | 3       |          | 2021-01-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 358         | 2       | 4        | 2020-03-03T00:00:00.000Z | 2020-04-02T00:00:00.000Z | pro monthly   | 19.90  |
| 358         | 4       |          | 2020-04-02T00:00:00.000Z |                          | churn         |        |
| 359         | 1       | 2        | 2020-08-21T00:00:00.000Z | 2020-12-11T00:00:00.000Z | basic monthly | 9.90   |
| 359         | 2       |          | 2020-12-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 360         | 2       | 3        | 2020-09-03T00:00:00.000Z | 2021-02-03T00:00:00.000Z | pro monthly   | 19.90  |
| 360         | 3       |          | 2021-02-03T00:00:00.000Z |                          | pro annual    | 199.00 |
| 361         | 4       |          | 2020-10-17T00:00:00.000Z |                          | churn         |        |
| 362         | 1       | 3        | 2020-06-12T00:00:00.000Z | 2020-08-21T00:00:00.000Z | basic monthly | 9.90   |
| 362         | 3       |          | 2020-08-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 363         | 1       | 3        | 2020-05-13T00:00:00.000Z | 2020-07-10T00:00:00.000Z | basic monthly | 9.90   |
| 363         | 3       |          | 2020-07-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 364         | 2       | 4        | 2020-05-09T00:00:00.000Z | 2020-09-15T00:00:00.000Z | pro monthly   | 19.90  |
| 364         | 4       |          | 2020-09-15T00:00:00.000Z |                          | churn         |        |
| 365         | 2       | 3        | 2020-06-16T00:00:00.000Z | 2020-12-16T00:00:00.000Z | pro monthly   | 19.90  |
| 365         | 3       |          | 2020-12-16T00:00:00.000Z |                          | pro annual    | 199.00 |
| 366         | 1       |          | 2020-07-25T00:00:00.000Z |                          | basic monthly | 9.90   |
| 367         | 1       | 2        | 2020-03-03T00:00:00.000Z | 2020-08-01T00:00:00.000Z | basic monthly | 9.90   |
| 367         | 2       |          | 2020-08-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 368         | 1       | 2        | 2020-10-30T00:00:00.000Z | 2021-04-02T00:00:00.000Z | basic monthly | 9.90   |
| 368         | 2       |          | 2021-04-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 369         | 1       | 4        | 2020-09-18T00:00:00.000Z | 2020-11-09T00:00:00.000Z | basic monthly | 9.90   |
| 369         | 4       |          | 2020-11-09T00:00:00.000Z |                          | churn         |        |
| 370         | 1       | 2        | 2020-03-15T00:00:00.000Z | 2020-08-27T00:00:00.000Z | basic monthly | 9.90   |
| 370         | 2       | 3        | 2020-08-27T00:00:00.000Z | 2020-10-27T00:00:00.000Z | pro monthly   | 19.90  |
| 370         | 3       |          | 2020-10-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 371         | 2       |          | 2020-05-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 372         | 1       | 3        | 2020-05-11T00:00:00.000Z | 2020-08-08T00:00:00.000Z | basic monthly | 9.90   |
| 372         | 3       |          | 2020-08-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 373         | 1       | 2        | 2020-10-27T00:00:00.000Z | 2020-11-03T00:00:00.000Z | basic monthly | 9.90   |
| 373         | 2       |          | 2020-11-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 374         | 1       | 2        | 2020-05-25T00:00:00.000Z | 2020-06-15T00:00:00.000Z | basic monthly | 9.90   |
| 374         | 2       | 4        | 2020-06-15T00:00:00.000Z | 2020-09-21T00:00:00.000Z | pro monthly   | 19.90  |
| 374         | 4       |          | 2020-09-21T00:00:00.000Z |                          | churn         |        |
| 375         | 2       | 3        | 2020-01-08T00:00:00.000Z | 2020-07-08T00:00:00.000Z | pro monthly   | 19.90  |
| 375         | 3       |          | 2020-07-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 376         | 2       | 4        | 2020-10-26T00:00:00.000Z | 2021-03-17T00:00:00.000Z | pro monthly   | 19.90  |
| 376         | 4       |          | 2021-03-17T00:00:00.000Z |                          | churn         |        |
| 377         | 1       | 2        | 2020-02-18T00:00:00.000Z | 2020-03-17T00:00:00.000Z | basic monthly | 9.90   |
| 377         | 2       |          | 2020-03-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 378         | 2       |          | 2020-05-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 379         | 2       | 4        | 2020-02-12T00:00:00.000Z | 2020-05-05T00:00:00.000Z | pro monthly   | 19.90  |
| 379         | 4       |          | 2020-05-05T00:00:00.000Z |                          | churn         |        |
| 380         | 1       | 2        | 2020-08-08T00:00:00.000Z | 2020-11-29T00:00:00.000Z | basic monthly | 9.90   |
| 380         | 2       | 3        | 2020-11-29T00:00:00.000Z | 2021-02-28T00:00:00.000Z | pro monthly   | 19.90  |
| 380         | 3       |          | 2021-02-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 381         | 1       | 2        | 2020-07-28T00:00:00.000Z | 2020-08-22T00:00:00.000Z | basic monthly | 9.90   |
| 381         | 2       |          | 2020-08-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 382         | 1       |          | 2020-02-27T00:00:00.000Z |                          | basic monthly | 9.90   |
| 383         | 2       | 3        | 2020-02-06T00:00:00.000Z | 2020-08-06T00:00:00.000Z | pro monthly   | 19.90  |
| 383         | 3       |          | 2020-08-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 384         | 2       | 4        | 2020-08-02T00:00:00.000Z | 2020-08-23T00:00:00.000Z | pro monthly   | 19.90  |
| 384         | 4       |          | 2020-08-23T00:00:00.000Z |                          | churn         |        |
| 385         | 2       |          | 2020-08-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 386         | 1       |          | 2020-09-22T00:00:00.000Z |                          | basic monthly | 9.90   |
| 387         | 1       |          | 2020-02-24T00:00:00.000Z |                          | basic monthly | 9.90   |
| 388         | 4       |          | 2020-11-16T00:00:00.000Z |                          | churn         |        |
| 389         | 1       | 2        | 2020-01-11T00:00:00.000Z | 2020-06-15T00:00:00.000Z | basic monthly | 9.90   |
| 389         | 2       | 4        | 2020-06-15T00:00:00.000Z | 2020-10-27T00:00:00.000Z | pro monthly   | 19.90  |
| 389         | 4       |          | 2020-10-27T00:00:00.000Z |                          | churn         |        |
| 390         | 2       |          | 2020-12-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 391         | 2       | 3        | 2020-07-06T00:00:00.000Z | 2020-09-06T00:00:00.000Z | pro monthly   | 19.90  |
| 391         | 3       |          | 2020-09-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 392         | 2       |          | 2020-06-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 393         | 1       | 2        | 2020-04-18T00:00:00.000Z | 2020-05-05T00:00:00.000Z | basic monthly | 9.90   |
| 393         | 2       |          | 2020-05-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 394         | 1       | 4        | 2020-08-24T00:00:00.000Z | 2021-01-24T00:00:00.000Z | basic monthly | 9.90   |
| 394         | 4       |          | 2021-01-24T00:00:00.000Z |                          | churn         |        |
| 395         | 3       | 4        | 2020-04-07T00:00:00.000Z | 2021-04-07T00:00:00.000Z | pro annual    | 199.00 |
| 395         | 4       |          | 2021-04-07T00:00:00.000Z |                          | churn         |        |
| 396         | 1       |          | 2020-10-02T00:00:00.000Z |                          | basic monthly | 9.90   |
| 397         | 2       |          | 2020-01-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 398         | 1       | 2        | 2020-07-24T00:00:00.000Z | 2020-10-02T00:00:00.000Z | basic monthly | 9.90   |
| 398         | 2       | 4        | 2020-10-02T00:00:00.000Z | 2021-02-27T00:00:00.000Z | pro monthly   | 19.90  |
| 398         | 4       |          | 2021-02-27T00:00:00.000Z |                          | churn         |        |
| 399         | 1       | 2        | 2020-03-10T00:00:00.000Z | 2020-05-24T00:00:00.000Z | basic monthly | 9.90   |
| 399         | 2       |          | 2020-05-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 400         | 1       |          | 2020-05-04T00:00:00.000Z |                          | basic monthly | 9.90   |
| 401         | 2       | 4        | 2020-04-21T00:00:00.000Z | 2020-05-22T00:00:00.000Z | pro monthly   | 19.90  |
| 401         | 4       |          | 2020-05-22T00:00:00.000Z |                          | churn         |        |
| 402         | 2       | 3        | 2020-06-24T00:00:00.000Z | 2020-10-24T00:00:00.000Z | pro monthly   | 19.90  |
| 402         | 3       |          | 2020-10-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 403         | 2       |          | 2020-05-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 404         | 2       |          | 2020-04-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 405         | 4       |          | 2020-03-09T00:00:00.000Z |                          | churn         |        |
| 406         | 2       |          | 2020-10-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 407         | 1       | 2        | 2020-11-10T00:00:00.000Z | 2021-04-12T00:00:00.000Z | basic monthly | 9.90   |
| 407         | 2       |          | 2021-04-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 408         | 2       |          | 2020-02-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 409         | 1       | 2        | 2020-09-09T00:00:00.000Z | 2021-01-29T00:00:00.000Z | basic monthly | 9.90   |
| 409         | 2       |          | 2021-01-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 410         | 1       |          | 2020-02-03T00:00:00.000Z |                          | basic monthly | 9.90   |
| 411         | 1       | 2        | 2020-03-23T00:00:00.000Z | 2020-08-15T00:00:00.000Z | basic monthly | 9.90   |
| 411         | 2       |          | 2020-08-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 412         | 1       | 3        | 2020-06-16T00:00:00.000Z | 2020-10-23T00:00:00.000Z | basic monthly | 9.90   |
| 412         | 3       |          | 2020-10-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 413         | 1       | 2        | 2020-09-03T00:00:00.000Z | 2020-12-21T00:00:00.000Z | basic monthly | 9.90   |
| 413         | 2       |          | 2020-12-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 414         | 2       |          | 2020-10-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 415         | 2       | 3        | 2020-11-06T00:00:00.000Z | 2021-02-06T00:00:00.000Z | pro monthly   | 19.90  |
| 415         | 3       |          | 2021-02-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 416         | 2       | 3        | 2020-08-14T00:00:00.000Z | 2021-02-14T00:00:00.000Z | pro monthly   | 19.90  |
| 416         | 3       |          | 2021-02-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 417         | 2       | 4        | 2020-02-04T00:00:00.000Z | 2020-03-02T00:00:00.000Z | pro monthly   | 19.90  |
| 417         | 4       |          | 2020-03-02T00:00:00.000Z |                          | churn         |        |
| 418         | 1       | 4        | 2020-10-14T00:00:00.000Z | 2020-11-22T00:00:00.000Z | basic monthly | 9.90   |
| 418         | 4       |          | 2020-11-22T00:00:00.000Z |                          | churn         |        |
| 419         | 2       |          | 2020-03-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 420         | 1       |          | 2020-06-03T00:00:00.000Z |                          | basic monthly | 9.90   |
| 421         | 2       |          | 2020-03-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 422         | 2       |          | 2021-01-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 423         | 2       |          | 2020-10-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 424         | 1       | 4        | 2020-12-22T00:00:00.000Z | 2021-04-28T00:00:00.000Z | basic monthly | 9.90   |
| 424         | 4       |          | 2021-04-28T00:00:00.000Z |                          | churn         |        |
| 425         | 2       | 4        | 2020-04-11T00:00:00.000Z | 2020-05-25T00:00:00.000Z | pro monthly   | 19.90  |
| 425         | 4       |          | 2020-05-25T00:00:00.000Z |                          | churn         |        |
| 426         | 1       | 2        | 2020-10-17T00:00:00.000Z | 2021-02-23T00:00:00.000Z | basic monthly | 9.90   |
| 426         | 2       |          | 2021-02-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 427         | 2       | 4        | 2020-06-07T00:00:00.000Z | 2020-06-23T00:00:00.000Z | pro monthly   | 19.90  |
| 427         | 4       |          | 2020-06-23T00:00:00.000Z |                          | churn         |        |
| 428         | 4       |          | 2020-11-01T00:00:00.000Z |                          | churn         |        |
| 429         | 2       | 4        | 2020-02-12T00:00:00.000Z | 2020-07-30T00:00:00.000Z | pro monthly   | 19.90  |
| 429         | 4       |          | 2020-07-30T00:00:00.000Z |                          | churn         |        |
| 430         | 1       | 2        | 2020-03-20T00:00:00.000Z | 2020-08-05T00:00:00.000Z | basic monthly | 9.90   |
| 430         | 2       |          | 2020-08-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 431         | 1       | 4        | 2021-01-03T00:00:00.000Z | 2021-03-14T00:00:00.000Z | basic monthly | 9.90   |
| 431         | 4       |          | 2021-03-14T00:00:00.000Z |                          | churn         |        |
| 432         | 1       | 3        | 2020-03-26T00:00:00.000Z | 2020-05-22T00:00:00.000Z | basic monthly | 9.90   |
| 432         | 3       |          | 2020-05-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 433         | 1       |          | 2020-10-11T00:00:00.000Z |                          | basic monthly | 9.90   |
| 434         | 1       | 2        | 2020-11-15T00:00:00.000Z | 2021-02-02T00:00:00.000Z | basic monthly | 9.90   |
| 434         | 2       |          | 2021-02-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 435         | 2       | 4        | 2020-01-16T00:00:00.000Z | 2020-03-08T00:00:00.000Z | pro monthly   | 19.90  |
| 435         | 4       |          | 2020-03-08T00:00:00.000Z |                          | churn         |        |
| 436         | 1       |          | 2021-01-03T00:00:00.000Z |                          | basic monthly | 9.90   |
| 437         | 4       |          | 2020-05-16T00:00:00.000Z |                          | churn         |        |
| 438         | 1       | 2        | 2020-02-07T00:00:00.000Z | 2020-04-16T00:00:00.000Z | basic monthly | 9.90   |
| 438         | 2       |          | 2020-04-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 439         | 1       | 4        | 2020-01-16T00:00:00.000Z | 2020-05-04T00:00:00.000Z | basic monthly | 9.90   |
| 439         | 4       |          | 2020-05-04T00:00:00.000Z |                          | churn         |        |
| 440         | 2       | 4        | 2020-03-21T00:00:00.000Z | 2020-04-28T00:00:00.000Z | pro monthly   | 19.90  |
| 440         | 4       |          | 2020-04-28T00:00:00.000Z |                          | churn         |        |
| 441         | 4       |          | 2020-10-04T00:00:00.000Z |                          | churn         |        |
| 442         | 1       | 3        | 2020-02-04T00:00:00.000Z | 2020-03-11T00:00:00.000Z | basic monthly | 9.90   |
| 442         | 3       |          | 2020-03-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 443         | 2       | 4        | 2020-12-05T00:00:00.000Z | 2021-03-16T00:00:00.000Z | pro monthly   | 19.90  |
| 443         | 4       |          | 2021-03-16T00:00:00.000Z |                          | churn         |        |
| 444         | 4       |          | 2020-10-21T00:00:00.000Z |                          | churn         |        |
| 445         | 4       |          | 2020-02-20T00:00:00.000Z |                          | churn         |        |
| 446         | 2       | 3        | 2020-02-27T00:00:00.000Z | 2020-08-27T00:00:00.000Z | pro monthly   | 19.90  |
| 446         | 3       |          | 2020-08-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 447         | 4       |          | 2020-04-09T00:00:00.000Z |                          | churn         |        |
| 448         | 1       | 3        | 2020-09-06T00:00:00.000Z | 2020-10-30T00:00:00.000Z | basic monthly | 9.90   |
| 448         | 3       |          | 2020-10-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 449         | 1       | 2        | 2020-01-13T00:00:00.000Z | 2020-05-07T00:00:00.000Z | basic monthly | 9.90   |
| 449         | 2       |          | 2020-05-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 450         | 1       | 3        | 2020-10-06T00:00:00.000Z | 2021-01-08T00:00:00.000Z | basic monthly | 9.90   |
| 450         | 3       |          | 2021-01-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 451         | 2       |          | 2020-09-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 452         | 1       | 4        | 2020-05-18T00:00:00.000Z | 2020-06-22T00:00:00.000Z | basic monthly | 9.90   |
| 452         | 4       |          | 2020-06-22T00:00:00.000Z |                          | churn         |        |
| 453         | 2       |          | 2020-02-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 454         | 2       |          | 2020-06-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 455         | 1       |          | 2020-08-20T00:00:00.000Z |                          | basic monthly | 9.90   |
| 456         | 4       |          | 2020-02-28T00:00:00.000Z |                          | churn         |        |
| 457         | 1       | 2        | 2020-11-26T00:00:00.000Z | 2021-03-12T00:00:00.000Z | basic monthly | 9.90   |
| 457         | 2       |          | 2021-03-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 458         | 4       |          | 2020-05-02T00:00:00.000Z |                          | churn         |        |
| 459         | 2       | 3        | 2020-12-14T00:00:00.000Z | 2021-03-14T00:00:00.000Z | pro monthly   | 19.90  |
| 459         | 3       |          | 2021-03-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 460         | 1       | 2        | 2020-12-16T00:00:00.000Z | 2021-04-16T00:00:00.000Z | basic monthly | 9.90   |
| 460         | 2       |          | 2021-04-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 461         | 1       | 4        | 2020-02-28T00:00:00.000Z | 2020-07-30T00:00:00.000Z | basic monthly | 9.90   |
| 461         | 4       |          | 2020-07-30T00:00:00.000Z |                          | churn         |        |
| 462         | 1       | 2        | 2020-05-12T00:00:00.000Z | 2020-09-15T00:00:00.000Z | basic monthly | 9.90   |
| 462         | 2       |          | 2020-09-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 463         | 1       | 2        | 2020-12-04T00:00:00.000Z | 2021-01-23T00:00:00.000Z | basic monthly | 9.90   |
| 463         | 2       | 4        | 2021-01-23T00:00:00.000Z | 2021-04-24T00:00:00.000Z | pro monthly   | 19.90  |
| 463         | 4       |          | 2021-04-24T00:00:00.000Z |                          | churn         |        |
| 464         | 1       |          | 2020-01-18T00:00:00.000Z |                          | basic monthly | 9.90   |
| 465         | 1       | 4        | 2020-10-31T00:00:00.000Z | 2021-01-03T00:00:00.000Z | basic monthly | 9.90   |
| 465         | 4       |          | 2021-01-03T00:00:00.000Z |                          | churn         |        |
| 466         | 4       |          | 2020-03-20T00:00:00.000Z |                          | churn         |        |
| 467         | 4       |          | 2020-06-28T00:00:00.000Z |                          | churn         |        |
| 468         | 1       | 3        | 2020-04-28T00:00:00.000Z | 2020-05-01T00:00:00.000Z | basic monthly | 9.90   |
| 468         | 3       |          | 2020-05-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 469         | 2       | 3        | 2020-06-24T00:00:00.000Z | 2020-11-24T00:00:00.000Z | pro monthly   | 19.90  |
| 469         | 3       |          | 2020-11-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 470         | 2       | 3        | 2020-05-05T00:00:00.000Z | 2020-08-05T00:00:00.000Z | pro monthly   | 19.90  |
| 470         | 3       |          | 2020-08-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 471         | 2       |          | 2020-02-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 472         | 2       | 3        | 2020-12-30T00:00:00.000Z | 2021-04-30T00:00:00.000Z | pro monthly   | 19.90  |
| 472         | 3       |          | 2021-04-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 473         | 1       | 3        | 2020-03-25T00:00:00.000Z | 2020-04-17T00:00:00.000Z | basic monthly | 9.90   |
| 473         | 3       |          | 2020-04-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 474         | 2       | 3        | 2020-09-08T00:00:00.000Z | 2021-02-08T00:00:00.000Z | pro monthly   | 19.90  |
| 474         | 3       |          | 2021-02-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 475         | 1       | 3        | 2020-07-31T00:00:00.000Z | 2020-12-17T00:00:00.000Z | basic monthly | 9.90   |
| 475         | 3       |          | 2020-12-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 476         | 2       |          | 2020-08-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 477         | 4       |          | 2020-02-04T00:00:00.000Z |                          | churn         |        |
| 478         | 1       | 2        | 2020-10-30T00:00:00.000Z | 2021-01-19T00:00:00.000Z | basic monthly | 9.90   |
| 478         | 2       |          | 2021-01-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 479         | 1       | 2        | 2020-10-08T00:00:00.000Z | 2021-01-24T00:00:00.000Z | basic monthly | 9.90   |
| 479         | 2       |          | 2021-01-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 480         | 1       | 3        | 2020-10-12T00:00:00.000Z | 2021-02-10T00:00:00.000Z | basic monthly | 9.90   |
| 480         | 3       |          | 2021-02-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 481         | 4       |          | 2020-07-15T00:00:00.000Z |                          | churn         |        |
| 482         | 2       |          | 2020-07-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 483         | 1       | 2        | 2020-01-19T00:00:00.000Z | 2020-07-10T00:00:00.000Z | basic monthly | 9.90   |
| 483         | 2       |          | 2020-07-10T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 484         | 1       | 3        | 2020-09-24T00:00:00.000Z | 2021-01-15T00:00:00.000Z | basic monthly | 9.90   |
| 484         | 3       |          | 2021-01-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 485         | 2       | 3        | 2020-05-31T00:00:00.000Z | 2020-07-31T00:00:00.000Z | pro monthly   | 19.90  |
| 485         | 3       |          | 2020-07-31T00:00:00.000Z |                          | pro annual    | 199.00 |
| 486         | 1       | 4        | 2020-07-04T00:00:00.000Z | 2020-10-10T00:00:00.000Z | basic monthly | 9.90   |
| 486         | 4       |          | 2020-10-10T00:00:00.000Z |                          | churn         |        |
| 487         | 1       | 3        | 2020-12-14T00:00:00.000Z | 2021-01-14T00:00:00.000Z | basic monthly | 9.90   |
| 487         | 3       |          | 2021-01-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 488         | 2       | 3        | 2020-02-22T00:00:00.000Z | 2020-06-22T00:00:00.000Z | pro monthly   | 19.90  |
| 488         | 3       |          | 2020-06-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 489         | 4       |          | 2020-09-01T00:00:00.000Z |                          | churn         |        |
| 490         | 1       | 2        | 2020-04-29T00:00:00.000Z | 2020-06-26T00:00:00.000Z | basic monthly | 9.90   |
| 490         | 2       | 4        | 2020-06-26T00:00:00.000Z | 2020-07-01T00:00:00.000Z | pro monthly   | 19.90  |
| 490         | 4       |          | 2020-07-01T00:00:00.000Z |                          | churn         |        |
| 491         | 2       |          | 2020-07-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 492         | 1       |          | 2020-03-05T00:00:00.000Z |                          | basic monthly | 9.90   |
| 493         | 1       | 2        | 2020-07-21T00:00:00.000Z | 2020-08-19T00:00:00.000Z | basic monthly | 9.90   |
| 493         | 2       |          | 2020-08-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 494         | 2       | 4        | 2020-07-25T00:00:00.000Z | 2021-01-06T00:00:00.000Z | pro monthly   | 19.90  |
| 494         | 4       |          | 2021-01-06T00:00:00.000Z |                          | churn         |        |
| 495         | 2       |          | 2020-01-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 496         | 1       | 3        | 2020-02-15T00:00:00.000Z | 2020-07-05T00:00:00.000Z | basic monthly | 9.90   |
| 496         | 3       |          | 2020-07-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 497         | 1       | 2        | 2020-04-15T00:00:00.000Z | 2020-07-18T00:00:00.000Z | basic monthly | 9.90   |
| 497         | 2       | 3        | 2020-07-18T00:00:00.000Z | 2021-01-18T00:00:00.000Z | pro monthly   | 19.90  |
| 497         | 3       |          | 2021-01-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 498         | 1       | 4        | 2020-11-20T00:00:00.000Z | 2021-03-08T00:00:00.000Z | basic monthly | 9.90   |
| 498         | 4       |          | 2021-03-08T00:00:00.000Z |                          | churn         |        |
| 499         | 2       |          | 2020-02-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 500         | 1       | 3        | 2020-09-23T00:00:00.000Z | 2020-12-21T00:00:00.000Z | basic monthly | 9.90   |
| 500         | 3       |          | 2020-12-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 501         | 4       |          | 2020-10-22T00:00:00.000Z |                          | churn         |        |
| 502         | 1       | 3        | 2020-02-01T00:00:00.000Z | 2020-06-25T00:00:00.000Z | basic monthly | 9.90   |
| 502         | 3       |          | 2020-06-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 503         | 2       |          | 2020-09-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 504         | 2       |          | 2020-05-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 505         | 1       | 3        | 2020-11-24T00:00:00.000Z | 2021-01-25T00:00:00.000Z | basic monthly | 9.90   |
| 505         | 3       |          | 2021-01-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 506         | 1       | 2        | 2020-07-18T00:00:00.000Z | 2020-07-26T00:00:00.000Z | basic monthly | 9.90   |
| 506         | 2       |          | 2020-07-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 507         | 1       | 4        | 2020-07-23T00:00:00.000Z | 2020-11-22T00:00:00.000Z | basic monthly | 9.90   |
| 507         | 4       |          | 2020-11-22T00:00:00.000Z |                          | churn         |        |
| 508         | 4       |          | 2020-12-27T00:00:00.000Z |                          | churn         |        |
| 509         | 1       | 4        | 2020-09-30T00:00:00.000Z | 2020-10-14T00:00:00.000Z | basic monthly | 9.90   |
| 509         | 4       |          | 2020-10-14T00:00:00.000Z |                          | churn         |        |
| 510         | 1       | 2        | 2020-02-26T00:00:00.000Z | 2020-04-19T00:00:00.000Z | basic monthly | 9.90   |
| 510         | 2       | 3        | 2020-04-19T00:00:00.000Z | 2020-06-19T00:00:00.000Z | pro monthly   | 19.90  |
| 510         | 3       |          | 2020-06-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 511         | 3       |          | 2020-11-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 512         | 1       | 2        | 2020-12-30T00:00:00.000Z | 2021-04-12T00:00:00.000Z | basic monthly | 9.90   |
| 512         | 2       |          | 2021-04-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 513         | 2       |          | 2020-08-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 514         | 1       | 2        | 2020-02-05T00:00:00.000Z | 2020-03-11T00:00:00.000Z | basic monthly | 9.90   |
| 514         | 2       |          | 2020-03-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 515         | 1       | 2        | 2020-05-22T00:00:00.000Z | 2020-07-06T00:00:00.000Z | basic monthly | 9.90   |
| 515         | 2       |          | 2020-07-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 516         | 1       | 2        | 2020-12-28T00:00:00.000Z | 2021-03-20T00:00:00.000Z | basic monthly | 9.90   |
| 516         | 2       |          | 2021-03-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 517         | 1       | 2        | 2020-07-31T00:00:00.000Z | 2020-11-21T00:00:00.000Z | basic monthly | 9.90   |
| 517         | 2       |          | 2020-11-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 518         | 4       |          | 2020-10-13T00:00:00.000Z |                          | churn         |        |
| 519         | 1       |          | 2020-01-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 520         | 1       | 2        | 2020-08-23T00:00:00.000Z | 2021-02-16T00:00:00.000Z | basic monthly | 9.90   |
| 520         | 2       |          | 2021-02-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 521         | 2       | 4        | 2020-06-24T00:00:00.000Z | 2020-11-07T00:00:00.000Z | pro monthly   | 19.90  |
| 521         | 4       |          | 2020-11-07T00:00:00.000Z |                          | churn         |        |
| 522         | 1       | 2        | 2020-09-02T00:00:00.000Z | 2020-09-26T00:00:00.000Z | basic monthly | 9.90   |
| 522         | 2       |          | 2020-09-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 523         | 4       |          | 2020-04-28T00:00:00.000Z |                          | churn         |        |
| 524         | 1       | 3        | 2020-08-16T00:00:00.000Z | 2020-08-31T00:00:00.000Z | basic monthly | 9.90   |
| 524         | 3       |          | 2020-08-31T00:00:00.000Z |                          | pro annual    | 199.00 |
| 525         | 1       |          | 2020-09-07T00:00:00.000Z |                          | basic monthly | 9.90   |
| 526         | 1       | 3        | 2020-05-27T00:00:00.000Z | 2020-09-23T00:00:00.000Z | basic monthly | 9.90   |
| 526         | 3       |          | 2020-09-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 527         | 2       | 3        | 2020-04-27T00:00:00.000Z | 2020-08-27T00:00:00.000Z | pro monthly   | 19.90  |
| 527         | 3       |          | 2020-08-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 528         | 2       |          | 2020-08-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 529         | 1       | 2        | 2020-04-06T00:00:00.000Z | 2020-09-13T00:00:00.000Z | basic monthly | 9.90   |
| 529         | 2       |          | 2020-09-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 530         | 1       | 2        | 2020-03-01T00:00:00.000Z | 2020-08-21T00:00:00.000Z | basic monthly | 9.90   |
| 530         | 2       | 3        | 2020-08-21T00:00:00.000Z | 2020-10-21T00:00:00.000Z | pro monthly   | 19.90  |
| 530         | 3       |          | 2020-10-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 531         | 1       | 2        | 2020-05-01T00:00:00.000Z | 2020-08-25T00:00:00.000Z | basic monthly | 9.90   |
| 531         | 2       |          | 2020-08-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 532         | 1       | 2        | 2020-04-04T00:00:00.000Z | 2020-05-24T00:00:00.000Z | basic monthly | 9.90   |
| 532         | 2       | 3        | 2020-05-24T00:00:00.000Z | 2020-09-24T00:00:00.000Z | pro monthly   | 19.90  |
| 532         | 3       |          | 2020-09-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 533         | 1       | 4        | 2020-02-08T00:00:00.000Z | 2020-03-05T00:00:00.000Z | basic monthly | 9.90   |
| 533         | 4       |          | 2020-03-05T00:00:00.000Z |                          | churn         |        |
| 534         | 1       | 3        | 2020-06-01T00:00:00.000Z | 2020-08-15T00:00:00.000Z | basic monthly | 9.90   |
| 534         | 3       |          | 2020-08-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 535         | 2       |          | 2020-04-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 536         | 2       |          | 2020-09-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 537         | 1       |          | 2020-12-28T00:00:00.000Z |                          | basic monthly | 9.90   |
| 538         | 1       | 4        | 2020-10-19T00:00:00.000Z | 2021-01-22T00:00:00.000Z | basic monthly | 9.90   |
| 538         | 4       |          | 2021-01-22T00:00:00.000Z |                          | churn         |        |
| 539         | 2       |          | 2020-04-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 540         | 1       | 2        | 2020-08-23T00:00:00.000Z | 2021-01-28T00:00:00.000Z | basic monthly | 9.90   |
| 540         | 2       | 4        | 2021-01-28T00:00:00.000Z | 2021-03-09T00:00:00.000Z | pro monthly   | 19.90  |
| 540         | 4       |          | 2021-03-09T00:00:00.000Z |                          | churn         |        |
| 541         | 3       |          | 2020-07-11T00:00:00.000Z |                          | pro annual    | 199.00 |
| 542         | 3       | 4        | 2020-04-14T00:00:00.000Z | 2021-04-14T00:00:00.000Z | pro annual    | 199.00 |
| 542         | 4       |          | 2021-04-14T00:00:00.000Z |                          | churn         |        |
| 543         | 1       | 3        | 2020-05-12T00:00:00.000Z | 2020-07-03T00:00:00.000Z | basic monthly | 9.90   |
| 543         | 3       |          | 2020-07-03T00:00:00.000Z |                          | pro annual    | 199.00 |
| 544         | 2       |          | 2020-03-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 545         | 1       | 2        | 2020-03-12T00:00:00.000Z | 2020-04-21T00:00:00.000Z | basic monthly | 9.90   |
| 545         | 2       |          | 2020-04-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 546         | 1       |          | 2020-06-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 547         | 1       | 3        | 2020-03-12T00:00:00.000Z | 2020-08-24T00:00:00.000Z | basic monthly | 9.90   |
| 547         | 3       |          | 2020-08-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 548         | 1       |          | 2020-03-31T00:00:00.000Z |                          | basic monthly | 9.90   |
| 549         | 1       | 2        | 2020-10-14T00:00:00.000Z | 2021-01-12T00:00:00.000Z | basic monthly | 9.90   |
| 549         | 2       |          | 2021-01-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 550         | 1       | 4        | 2020-10-01T00:00:00.000Z | 2021-03-22T00:00:00.000Z | basic monthly | 9.90   |
| 550         | 4       |          | 2021-03-22T00:00:00.000Z |                          | churn         |        |
| 551         | 1       |          | 2020-05-14T00:00:00.000Z |                          | basic monthly | 9.90   |
| 552         | 2       | 3        | 2020-08-03T00:00:00.000Z | 2021-01-03T00:00:00.000Z | pro monthly   | 19.90  |
| 552         | 3       |          | 2021-01-03T00:00:00.000Z |                          | pro annual    | 199.00 |
| 553         | 2       |          | 2020-10-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 554         | 2       |          | 2020-10-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 555         | 1       | 2        | 2020-05-01T00:00:00.000Z | 2020-09-24T00:00:00.000Z | basic monthly | 9.90   |
| 555         | 2       |          | 2020-09-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 556         | 1       | 3        | 2020-08-15T00:00:00.000Z | 2020-10-10T00:00:00.000Z | basic monthly | 9.90   |
| 556         | 3       |          | 2020-10-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 557         | 1       | 3        | 2020-03-09T00:00:00.000Z | 2020-04-24T00:00:00.000Z | basic monthly | 9.90   |
| 557         | 3       |          | 2020-04-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 558         | 2       |          | 2020-12-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 559         | 1       |          | 2020-11-13T00:00:00.000Z |                          | basic monthly | 9.90   |
| 560         | 1       | 4        | 2020-07-02T00:00:00.000Z | 2020-09-07T00:00:00.000Z | basic monthly | 9.90   |
| 560         | 4       |          | 2020-09-07T00:00:00.000Z |                          | churn         |        |
| 561         | 1       |          | 2020-06-25T00:00:00.000Z |                          | basic monthly | 9.90   |
| 562         | 1       | 2        | 2020-08-13T00:00:00.000Z | 2020-10-23T00:00:00.000Z | basic monthly | 9.90   |
| 562         | 2       |          | 2020-10-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 563         | 1       | 4        | 2020-06-26T00:00:00.000Z | 2020-07-19T00:00:00.000Z | basic monthly | 9.90   |
| 563         | 4       |          | 2020-07-19T00:00:00.000Z |                          | churn         |        |
| 564         | 4       |          | 2020-06-26T00:00:00.000Z |                          | churn         |        |
| 565         | 2       |          | 2020-01-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 566         | 2       |          | 2020-12-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 567         | 4       |          | 2020-07-19T00:00:00.000Z |                          | churn         |        |
| 568         | 1       |          | 2020-04-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 569         | 1       | 2        | 2020-12-19T00:00:00.000Z | 2021-03-31T00:00:00.000Z | basic monthly | 9.90   |
| 569         | 2       |          | 2021-03-31T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 570         | 1       | 4        | 2020-10-29T00:00:00.000Z | 2021-03-16T00:00:00.000Z | basic monthly | 9.90   |
| 570         | 4       |          | 2021-03-16T00:00:00.000Z |                          | churn         |        |
| 571         | 1       |          | 2020-12-22T00:00:00.000Z |                          | basic monthly | 9.90   |
| 572         | 1       | 4        | 2020-04-04T00:00:00.000Z | 2020-09-08T00:00:00.000Z | basic monthly | 9.90   |
| 572         | 4       |          | 2020-09-08T00:00:00.000Z |                          | churn         |        |
| 573         | 1       | 2        | 2020-07-09T00:00:00.000Z | 2020-11-23T00:00:00.000Z | basic monthly | 9.90   |
| 573         | 2       | 3        | 2020-11-23T00:00:00.000Z | 2021-01-23T00:00:00.000Z | pro monthly   | 19.90  |
| 573         | 3       |          | 2021-01-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 574         | 1       | 2        | 2020-10-09T00:00:00.000Z | 2021-01-30T00:00:00.000Z | basic monthly | 9.90   |
| 574         | 2       |          | 2021-01-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 575         | 1       | 2        | 2020-06-23T00:00:00.000Z | 2020-10-31T00:00:00.000Z | basic monthly | 9.90   |
| 575         | 2       |          | 2020-10-31T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 576         | 2       |          | 2021-01-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 577         | 1       |          | 2020-12-14T00:00:00.000Z |                          | basic monthly | 9.90   |
| 578         | 1       |          | 2020-02-06T00:00:00.000Z |                          | basic monthly | 9.90   |
| 579         | 2       |          | 2020-01-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 580         | 2       | 3        | 2020-10-18T00:00:00.000Z | 2021-03-18T00:00:00.000Z | pro monthly   | 19.90  |
| 580         | 3       |          | 2021-03-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 581         | 1       | 3        | 2020-01-12T00:00:00.000Z | 2020-06-01T00:00:00.000Z | basic monthly | 9.90   |
| 581         | 3       |          | 2020-06-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 582         | 1       |          | 2020-12-06T00:00:00.000Z |                          | basic monthly | 9.90   |
| 583         | 1       | 3        | 2020-02-27T00:00:00.000Z | 2020-03-04T00:00:00.000Z | basic monthly | 9.90   |
| 583         | 3       |          | 2020-03-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 584         | 2       |          | 2020-08-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 585         | 2       |          | 2020-01-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 586         | 1       |          | 2020-01-19T00:00:00.000Z |                          | basic monthly | 9.90   |
| 587         | 2       | 3        | 2020-06-28T00:00:00.000Z | 2020-07-28T00:00:00.000Z | pro monthly   | 19.90  |
| 587         | 3       |          | 2020-07-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 588         | 2       | 3        | 2020-12-19T00:00:00.000Z | 2021-04-19T00:00:00.000Z | pro monthly   | 19.90  |
| 588         | 3       |          | 2021-04-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 589         | 1       | 2        | 2020-09-21T00:00:00.000Z | 2020-10-01T00:00:00.000Z | basic monthly | 9.90   |
| 589         | 2       |          | 2020-10-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 590         | 1       |          | 2020-02-15T00:00:00.000Z |                          | basic monthly | 9.90   |
| 591         | 1       | 2        | 2020-05-21T00:00:00.000Z | 2020-08-26T00:00:00.000Z | basic monthly | 9.90   |
| 591         | 2       | 4        | 2020-08-26T00:00:00.000Z | 2020-12-08T00:00:00.000Z | pro monthly   | 19.90  |
| 591         | 4       |          | 2020-12-08T00:00:00.000Z |                          | churn         |        |
| 592         | 3       |          | 2020-02-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 593         | 1       |          | 2020-03-11T00:00:00.000Z |                          | basic monthly | 9.90   |
| 594         | 2       | 4        | 2020-01-22T00:00:00.000Z | 2020-03-14T00:00:00.000Z | pro monthly   | 19.90  |
| 594         | 4       |          | 2020-03-14T00:00:00.000Z |                          | churn         |        |
| 595         | 1       | 2        | 2020-06-11T00:00:00.000Z | 2020-11-18T00:00:00.000Z | basic monthly | 9.90   |
| 595         | 2       |          | 2020-11-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 596         | 1       |          | 2020-05-25T00:00:00.000Z |                          | basic monthly | 9.90   |
| 597         | 2       |          | 2020-04-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 598         | 2       |          | 2021-01-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 599         | 1       | 3        | 2020-02-15T00:00:00.000Z | 2020-05-01T00:00:00.000Z | basic monthly | 9.90   |
| 599         | 3       |          | 2020-05-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 600         | 1       | 3        | 2020-06-27T00:00:00.000Z | 2020-11-09T00:00:00.000Z | basic monthly | 9.90   |
| 600         | 3       |          | 2020-11-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 601         | 1       |          | 2020-01-18T00:00:00.000Z |                          | basic monthly | 9.90   |
| 602         | 1       | 4        | 2020-04-01T00:00:00.000Z | 2020-05-09T00:00:00.000Z | basic monthly | 9.90   |
| 602         | 4       |          | 2020-05-09T00:00:00.000Z |                          | churn         |        |
| 603         | 2       |          | 2020-04-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 604         | 1       |          | 2020-07-28T00:00:00.000Z |                          | basic monthly | 9.90   |
| 605         | 3       |          | 2020-09-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 606         | 4       |          | 2020-02-03T00:00:00.000Z |                          | churn         |        |
| 607         | 1       | 4        | 2020-01-09T00:00:00.000Z | 2020-04-03T00:00:00.000Z | basic monthly | 9.90   |
| 607         | 4       |          | 2020-04-03T00:00:00.000Z |                          | churn         |        |
| 608         | 1       | 4        | 2020-06-30T00:00:00.000Z | 2020-11-29T00:00:00.000Z | basic monthly | 9.90   |
| 608         | 4       |          | 2020-11-29T00:00:00.000Z |                          | churn         |        |
| 609         | 2       | 4        | 2020-06-19T00:00:00.000Z | 2020-12-01T00:00:00.000Z | pro monthly   | 19.90  |
| 609         | 4       |          | 2020-12-01T00:00:00.000Z |                          | churn         |        |
| 610         | 1       | 2        | 2020-12-20T00:00:00.000Z | 2021-03-27T00:00:00.000Z | basic monthly | 9.90   |
| 610         | 2       |          | 2021-03-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 611         | 2       |          | 2020-08-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 612         | 4       |          | 2020-11-21T00:00:00.000Z |                          | churn         |        |
| 613         | 4       |          | 2020-05-03T00:00:00.000Z |                          | churn         |        |
| 614         | 1       | 4        | 2020-11-14T00:00:00.000Z | 2021-02-14T00:00:00.000Z | basic monthly | 9.90   |
| 614         | 4       |          | 2021-02-14T00:00:00.000Z |                          | churn         |        |
| 615         | 2       |          | 2020-07-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 616         | 1       | 4        | 2020-03-27T00:00:00.000Z | 2020-03-31T00:00:00.000Z | basic monthly | 9.90   |
| 616         | 4       |          | 2020-03-31T00:00:00.000Z |                          | churn         |        |
| 617         | 3       |          | 2020-09-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 618         | 1       | 2        | 2020-01-23T00:00:00.000Z | 2020-05-08T00:00:00.000Z | basic monthly | 9.90   |
| 618         | 2       | 4        | 2020-05-08T00:00:00.000Z | 2020-08-27T00:00:00.000Z | pro monthly   | 19.90  |
| 618         | 4       |          | 2020-08-27T00:00:00.000Z |                          | churn         |        |
| 619         | 2       |          | 2020-04-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 620         | 1       |          | 2020-12-13T00:00:00.000Z |                          | basic monthly | 9.90   |
| 621         | 1       |          | 2020-11-13T00:00:00.000Z |                          | basic monthly | 9.90   |
| 622         | 1       |          | 2020-12-07T00:00:00.000Z |                          | basic monthly | 9.90   |
| 623         | 2       |          | 2020-10-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 624         | 2       |          | 2020-08-31T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 625         | 2       |          | 2020-03-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 626         | 1       |          | 2020-07-15T00:00:00.000Z |                          | basic monthly | 9.90   |
| 627         | 2       |          | 2020-03-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 628         | 2       | 3        | 2020-08-08T00:00:00.000Z | 2021-02-08T00:00:00.000Z | pro monthly   | 19.90  |
| 628         | 3       |          | 2021-02-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 629         | 4       |          | 2020-11-11T00:00:00.000Z |                          | churn         |        |
| 630         | 2       | 4        | 2020-02-02T00:00:00.000Z | 2020-06-02T00:00:00.000Z | pro monthly   | 19.90  |
| 630         | 4       |          | 2020-06-02T00:00:00.000Z |                          | churn         |        |
| 631         | 1       | 3        | 2020-08-10T00:00:00.000Z | 2020-10-22T00:00:00.000Z | basic monthly | 9.90   |
| 631         | 3       |          | 2020-10-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 632         | 1       | 2        | 2020-05-01T00:00:00.000Z | 2020-08-17T00:00:00.000Z | basic monthly | 9.90   |
| 632         | 2       |          | 2020-08-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 633         | 4       |          | 2021-01-03T00:00:00.000Z |                          | churn         |        |
| 634         | 4       |          | 2020-07-22T00:00:00.000Z |                          | churn         |        |
| 635         | 1       | 3        | 2020-02-24T00:00:00.000Z | 2020-05-27T00:00:00.000Z | basic monthly | 9.90   |
| 635         | 3       |          | 2020-05-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 636         | 1       |          | 2020-10-02T00:00:00.000Z |                          | basic monthly | 9.90   |
| 637         | 1       |          | 2020-09-27T00:00:00.000Z |                          | basic monthly | 9.90   |
| 638         | 4       |          | 2020-09-10T00:00:00.000Z |                          | churn         |        |
| 639         | 3       |          | 2020-07-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 640         | 1       | 2        | 2020-03-24T00:00:00.000Z | 2020-08-13T00:00:00.000Z | basic monthly | 9.90   |
| 640         | 2       |          | 2020-08-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 641         | 2       | 4        | 2020-03-03T00:00:00.000Z | 2020-06-06T00:00:00.000Z | pro monthly   | 19.90  |
| 641         | 4       |          | 2020-06-06T00:00:00.000Z |                          | churn         |        |
| 642         | 1       | 4        | 2020-03-25T00:00:00.000Z | 2020-05-08T00:00:00.000Z | basic monthly | 9.90   |
| 642         | 4       |          | 2020-05-08T00:00:00.000Z |                          | churn         |        |
| 643         | 1       | 2        | 2020-04-10T00:00:00.000Z | 2020-09-17T00:00:00.000Z | basic monthly | 9.90   |
| 643         | 2       |          | 2020-09-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 644         | 1       |          | 2020-01-10T00:00:00.000Z |                          | basic monthly | 9.90   |
| 645         | 2       | 4        | 2020-05-14T00:00:00.000Z | 2020-05-20T00:00:00.000Z | pro monthly   | 19.90  |
| 645         | 4       |          | 2020-05-20T00:00:00.000Z |                          | churn         |        |
| 646         | 1       |          | 2020-03-06T00:00:00.000Z |                          | basic monthly | 9.90   |
| 647         | 1       | 2        | 2020-05-08T00:00:00.000Z | 2020-08-06T00:00:00.000Z | basic monthly | 9.90   |
| 647         | 2       | 4        | 2020-08-06T00:00:00.000Z | 2020-12-05T00:00:00.000Z | pro monthly   | 19.90  |
| 647         | 4       |          | 2020-12-05T00:00:00.000Z |                          | churn         |        |
| 648         | 1       | 3        | 2020-03-23T00:00:00.000Z | 2020-05-30T00:00:00.000Z | basic monthly | 9.90   |
| 648         | 3       |          | 2020-05-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 649         | 2       | 4        | 2020-09-09T00:00:00.000Z | 2021-01-21T00:00:00.000Z | pro monthly   | 19.90  |
| 649         | 4       |          | 2021-01-21T00:00:00.000Z |                          | churn         |        |
| 650         | 4       |          | 2020-04-23T00:00:00.000Z |                          | churn         |        |
| 651         | 1       | 2        | 2020-06-19T00:00:00.000Z | 2020-09-02T00:00:00.000Z | basic monthly | 9.90   |
| 651         | 2       | 4        | 2020-09-02T00:00:00.000Z | 2020-10-31T00:00:00.000Z | pro monthly   | 19.90  |
| 651         | 4       |          | 2020-10-31T00:00:00.000Z |                          | churn         |        |
| 652         | 1       | 3        | 2020-07-27T00:00:00.000Z | 2020-09-25T00:00:00.000Z | basic monthly | 9.90   |
| 652         | 3       |          | 2020-09-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 653         | 2       | 4        | 2020-07-07T00:00:00.000Z | 2020-07-22T00:00:00.000Z | pro monthly   | 19.90  |
| 653         | 4       |          | 2020-07-22T00:00:00.000Z |                          | churn         |        |
| 654         | 1       | 4        | 2020-12-08T00:00:00.000Z | 2021-03-10T00:00:00.000Z | basic monthly | 9.90   |
| 654         | 4       |          | 2021-03-10T00:00:00.000Z |                          | churn         |        |
| 655         | 1       | 2        | 2020-04-29T00:00:00.000Z | 2020-05-16T00:00:00.000Z | basic monthly | 9.90   |
| 655         | 2       |          | 2020-05-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 656         | 2       |          | 2020-05-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 657         | 4       |          | 2020-10-02T00:00:00.000Z |                          | churn         |        |
| 658         | 1       | 2        | 2020-11-21T00:00:00.000Z | 2021-01-27T00:00:00.000Z | basic monthly | 9.90   |
| 658         | 2       |          | 2021-01-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 659         | 2       |          | 2020-10-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 660         | 4       |          | 2020-05-09T00:00:00.000Z |                          | churn         |        |
| 661         | 1       | 2        | 2020-04-20T00:00:00.000Z | 2020-07-09T00:00:00.000Z | basic monthly | 9.90   |
| 661         | 2       | 3        | 2020-07-09T00:00:00.000Z | 2020-10-09T00:00:00.000Z | pro monthly   | 19.90  |
| 661         | 3       |          | 2020-10-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 662         | 2       |          | 2020-02-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 663         | 2       |          | 2020-09-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 664         | 1       | 3        | 2020-02-06T00:00:00.000Z | 2020-04-20T00:00:00.000Z | basic monthly | 9.90   |
| 664         | 3       | 4        | 2020-04-20T00:00:00.000Z | 2021-04-20T00:00:00.000Z | pro annual    | 199.00 |
| 664         | 4       |          | 2021-04-20T00:00:00.000Z |                          | churn         |        |
| 665         | 1       |          | 2020-10-01T00:00:00.000Z |                          | basic monthly | 9.90   |
| 666         | 2       |          | 2020-12-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 667         | 2       |          | 2021-01-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 668         | 1       | 3        | 2020-02-20T00:00:00.000Z | 2020-06-14T00:00:00.000Z | basic monthly | 9.90   |
| 668         | 3       |          | 2020-06-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 669         | 1       | 2        | 2020-12-05T00:00:00.000Z | 2021-04-24T00:00:00.000Z | basic monthly | 9.90   |
| 669         | 2       |          | 2021-04-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 670         | 2       | 4        | 2020-01-10T00:00:00.000Z | 2020-02-18T00:00:00.000Z | pro monthly   | 19.90  |
| 670         | 4       |          | 2020-02-18T00:00:00.000Z |                          | churn         |        |
| 671         | 3       |          | 2020-06-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 672         | 2       | 4        | 2021-01-05T00:00:00.000Z | 2021-03-01T00:00:00.000Z | pro monthly   | 19.90  |
| 672         | 4       |          | 2021-03-01T00:00:00.000Z |                          | churn         |        |
| 673         | 1       |          | 2020-01-08T00:00:00.000Z |                          | basic monthly | 9.90   |
| 674         | 1       | 4        | 2020-02-10T00:00:00.000Z | 2020-04-12T00:00:00.000Z | basic monthly | 9.90   |
| 674         | 4       |          | 2020-04-12T00:00:00.000Z |                          | churn         |        |
| 675         | 2       |          | 2020-05-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 676         | 1       | 2        | 2020-04-29T00:00:00.000Z | 2020-06-08T00:00:00.000Z | basic monthly | 9.90   |
| 676         | 2       |          | 2020-06-08T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 677         | 1       |          | 2020-12-22T00:00:00.000Z |                          | basic monthly | 9.90   |
| 678         | 1       |          | 2020-03-12T00:00:00.000Z |                          | basic monthly | 9.90   |
| 679         | 2       | 4        | 2020-06-17T00:00:00.000Z | 2020-11-30T00:00:00.000Z | pro monthly   | 19.90  |
| 679         | 4       |          | 2020-11-30T00:00:00.000Z |                          | churn         |        |
| 680         | 1       |          | 2020-04-18T00:00:00.000Z |                          | basic monthly | 9.90   |
| 681         | 2       |          | 2020-03-01T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 682         | 1       | 2        | 2020-08-28T00:00:00.000Z | 2020-10-15T00:00:00.000Z | basic monthly | 9.90   |
| 682         | 2       |          | 2020-10-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 683         | 1       | 4        | 2020-07-26T00:00:00.000Z | 2020-08-06T00:00:00.000Z | basic monthly | 9.90   |
| 683         | 4       |          | 2020-08-06T00:00:00.000Z |                          | churn         |        |
| 684         | 1       | 2        | 2020-06-16T00:00:00.000Z | 2020-11-16T00:00:00.000Z | basic monthly | 9.90   |
| 684         | 2       | 3        | 2020-11-16T00:00:00.000Z | 2020-12-16T00:00:00.000Z | pro monthly   | 19.90  |
| 684         | 3       |          | 2020-12-16T00:00:00.000Z |                          | pro annual    | 199.00 |
| 685         | 1       | 2        | 2020-05-16T00:00:00.000Z | 2020-11-09T00:00:00.000Z | basic monthly | 9.90   |
| 685         | 2       | 4        | 2020-11-09T00:00:00.000Z | 2021-02-09T00:00:00.000Z | pro monthly   | 19.90  |
| 685         | 4       |          | 2021-02-09T00:00:00.000Z |                          | churn         |        |
| 686         | 1       | 2        | 2020-07-31T00:00:00.000Z | 2020-10-11T00:00:00.000Z | basic monthly | 9.90   |
| 686         | 2       | 4        | 2020-10-11T00:00:00.000Z | 2020-11-02T00:00:00.000Z | pro monthly   | 19.90  |
| 686         | 4       |          | 2020-11-02T00:00:00.000Z |                          | churn         |        |
| 687         | 1       |          | 2020-05-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 688         | 1       | 3        | 2020-08-20T00:00:00.000Z | 2020-09-20T00:00:00.000Z | basic monthly | 9.90   |
| 688         | 3       |          | 2020-09-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 689         | 2       |          | 2020-12-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 690         | 1       | 2        | 2020-05-05T00:00:00.000Z | 2020-06-13T00:00:00.000Z | basic monthly | 9.90   |
| 690         | 2       |          | 2020-06-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 691         | 2       | 3        | 2020-06-22T00:00:00.000Z | 2020-11-22T00:00:00.000Z | pro monthly   | 19.90  |
| 691         | 3       |          | 2020-11-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 692         | 1       |          | 2020-11-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 693         | 2       | 3        | 2020-08-20T00:00:00.000Z | 2020-09-20T00:00:00.000Z | pro monthly   | 19.90  |
| 693         | 3       |          | 2020-09-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 694         | 1       |          | 2020-12-03T00:00:00.000Z |                          | basic monthly | 9.90   |
| 695         | 2       |          | 2020-05-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 696         | 1       |          | 2020-10-04T00:00:00.000Z |                          | basic monthly | 9.90   |
| 697         | 1       |          | 2020-01-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 698         | 1       | 2        | 2020-11-19T00:00:00.000Z | 2021-01-28T00:00:00.000Z | basic monthly | 9.90   |
| 698         | 2       |          | 2021-01-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 699         | 2       |          | 2020-06-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 700         | 2       | 3        | 2020-12-13T00:00:00.000Z | 2021-03-13T00:00:00.000Z | pro monthly   | 19.90  |
| 700         | 3       |          | 2021-03-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 701         | 1       | 4        | 2020-05-17T00:00:00.000Z | 2020-11-07T00:00:00.000Z | basic monthly | 9.90   |
| 701         | 4       |          | 2020-11-07T00:00:00.000Z |                          | churn         |        |
| 702         | 2       | 4        | 2020-01-15T00:00:00.000Z | 2020-02-27T00:00:00.000Z | pro monthly   | 19.90  |
| 702         | 4       |          | 2020-02-27T00:00:00.000Z |                          | churn         |        |
| 703         | 1       | 4        | 2020-11-09T00:00:00.000Z | 2020-12-04T00:00:00.000Z | basic monthly | 9.90   |
| 703         | 4       |          | 2020-12-04T00:00:00.000Z |                          | churn         |        |
| 704         | 1       | 4        | 2020-12-13T00:00:00.000Z | 2021-01-19T00:00:00.000Z | basic monthly | 9.90   |
| 704         | 4       |          | 2021-01-19T00:00:00.000Z |                          | churn         |        |
| 705         | 1       | 2        | 2020-07-22T00:00:00.000Z | 2020-12-14T00:00:00.000Z | basic monthly | 9.90   |
| 705         | 2       | 4        | 2020-12-14T00:00:00.000Z | 2021-02-06T00:00:00.000Z | pro monthly   | 19.90  |
| 705         | 4       |          | 2021-02-06T00:00:00.000Z |                          | churn         |        |
| 706         | 1       | 4        | 2020-12-14T00:00:00.000Z | 2021-01-24T00:00:00.000Z | basic monthly | 9.90   |
| 706         | 4       |          | 2021-01-24T00:00:00.000Z |                          | churn         |        |
| 707         | 1       | 2        | 2020-09-06T00:00:00.000Z | 2021-02-28T00:00:00.000Z | basic monthly | 9.90   |
| 707         | 2       |          | 2021-02-28T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 708         | 4       |          | 2020-07-12T00:00:00.000Z |                          | churn         |        |
| 709         | 1       | 4        | 2020-03-18T00:00:00.000Z | 2020-03-30T00:00:00.000Z | basic monthly | 9.90   |
| 709         | 4       |          | 2020-03-30T00:00:00.000Z |                          | churn         |        |
| 710         | 1       | 4        | 2020-10-06T00:00:00.000Z | 2020-12-24T00:00:00.000Z | basic monthly | 9.90   |
| 710         | 4       |          | 2020-12-24T00:00:00.000Z |                          | churn         |        |
| 711         | 1       | 2        | 2020-10-09T00:00:00.000Z | 2020-11-16T00:00:00.000Z | basic monthly | 9.90   |
| 711         | 2       | 4        | 2020-11-16T00:00:00.000Z | 2020-12-31T00:00:00.000Z | pro monthly   | 19.90  |
| 711         | 4       |          | 2020-12-31T00:00:00.000Z |                          | churn         |        |
| 712         | 1       |          | 2021-01-02T00:00:00.000Z |                          | basic monthly | 9.90   |
| 713         | 2       |          | 2020-09-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 714         | 2       |          | 2020-08-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 715         | 3       |          | 2020-02-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 716         | 1       | 4        | 2020-12-30T00:00:00.000Z | 2021-02-16T00:00:00.000Z | basic monthly | 9.90   |
| 716         | 4       |          | 2021-02-16T00:00:00.000Z |                          | churn         |        |
| 717         | 2       | 3        | 2020-01-15T00:00:00.000Z | 2020-06-15T00:00:00.000Z | pro monthly   | 19.90  |
| 717         | 3       |          | 2020-06-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 718         | 1       |          | 2020-05-31T00:00:00.000Z |                          | basic monthly | 9.90   |
| 719         | 1       |          | 2020-04-18T00:00:00.000Z |                          | basic monthly | 9.90   |
| 720         | 2       |          | 2020-05-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 721         | 1       |          | 2020-08-19T00:00:00.000Z |                          | basic monthly | 9.90   |
| 722         | 1       | 4        | 2020-08-28T00:00:00.000Z | 2021-01-31T00:00:00.000Z | basic monthly | 9.90   |
| 722         | 4       |          | 2021-01-31T00:00:00.000Z |                          | churn         |        |
| 723         | 2       |          | 2020-06-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 724         | 2       | 4        | 2020-10-10T00:00:00.000Z | 2020-11-06T00:00:00.000Z | pro monthly   | 19.90  |
| 724         | 4       |          | 2020-11-06T00:00:00.000Z |                          | churn         |        |
| 725         | 2       | 3        | 2020-06-06T00:00:00.000Z | 2020-07-06T00:00:00.000Z | pro monthly   | 19.90  |
| 725         | 3       |          | 2020-07-06T00:00:00.000Z |                          | pro annual    | 199.00 |
| 726         | 4       |          | 2020-03-09T00:00:00.000Z |                          | churn         |        |
| 727         | 2       |          | 2020-04-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 728         | 1       |          | 2020-06-24T00:00:00.000Z |                          | basic monthly | 9.90   |
| 729         | 1       | 2        | 2020-04-10T00:00:00.000Z | 2020-08-17T00:00:00.000Z | basic monthly | 9.90   |
| 729         | 2       |          | 2020-08-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 730         | 1       | 3        | 2020-08-22T00:00:00.000Z | 2020-10-27T00:00:00.000Z | basic monthly | 9.90   |
| 730         | 3       |          | 2020-10-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 731         | 1       | 2        | 2020-09-20T00:00:00.000Z | 2020-09-29T00:00:00.000Z | basic monthly | 9.90   |
| 731         | 2       | 4        | 2020-09-29T00:00:00.000Z | 2021-03-07T00:00:00.000Z | pro monthly   | 19.90  |
| 731         | 4       |          | 2021-03-07T00:00:00.000Z |                          | churn         |        |
| 732         | 4       |          | 2020-06-23T00:00:00.000Z |                          | churn         |        |
| 733         | 1       | 4        | 2020-04-18T00:00:00.000Z | 2020-04-24T00:00:00.000Z | basic monthly | 9.90   |
| 733         | 4       |          | 2020-04-24T00:00:00.000Z |                          | churn         |        |
| 734         | 2       |          | 2020-09-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 735         | 1       | 4        | 2020-11-30T00:00:00.000Z | 2021-04-04T00:00:00.000Z | basic monthly | 9.90   |
| 735         | 4       |          | 2021-04-04T00:00:00.000Z |                          | churn         |        |
| 736         | 1       | 2        | 2020-03-26T00:00:00.000Z | 2020-04-07T00:00:00.000Z | basic monthly | 9.90   |
| 736         | 2       | 4        | 2020-04-07T00:00:00.000Z | 2020-06-04T00:00:00.000Z | pro monthly   | 19.90  |
| 736         | 4       |          | 2020-06-04T00:00:00.000Z |                          | churn         |        |
| 737         | 1       |          | 2020-11-11T00:00:00.000Z |                          | basic monthly | 9.90   |
| 738         | 3       |          | 2020-01-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 739         | 2       |          | 2020-12-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 740         | 1       | 4        | 2021-01-06T00:00:00.000Z | 2021-04-06T00:00:00.000Z | basic monthly | 9.90   |
| 740         | 4       |          | 2021-04-06T00:00:00.000Z |                          | churn         |        |
| 741         | 2       |          | 2020-03-31T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 742         | 1       | 3        | 2020-08-20T00:00:00.000Z | 2020-11-22T00:00:00.000Z | basic monthly | 9.90   |
| 742         | 3       |          | 2020-11-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 743         | 3       |          | 2020-07-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 744         | 2       | 4        | 2020-04-22T00:00:00.000Z | 2020-09-11T00:00:00.000Z | pro monthly   | 19.90  |
| 744         | 4       |          | 2020-09-11T00:00:00.000Z |                          | churn         |        |
| 745         | 1       | 3        | 2020-03-12T00:00:00.000Z | 2020-08-25T00:00:00.000Z | basic monthly | 9.90   |
| 745         | 3       |          | 2020-08-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 746         | 1       | 2        | 2020-12-05T00:00:00.000Z | 2021-02-23T00:00:00.000Z | basic monthly | 9.90   |
| 746         | 2       | 3        | 2021-02-23T00:00:00.000Z | 2021-04-23T00:00:00.000Z | pro monthly   | 19.90  |
| 746         | 3       |          | 2021-04-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 747         | 2       |          | 2020-11-17T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 748         | 2       | 4        | 2020-03-07T00:00:00.000Z | 2020-07-10T00:00:00.000Z | pro monthly   | 19.90  |
| 748         | 4       |          | 2020-07-10T00:00:00.000Z |                          | churn         |        |
| 749         | 2       |          | 2020-02-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 750         | 4       |          | 2020-07-10T00:00:00.000Z |                          | churn         |        |
| 751         | 1       |          | 2020-06-07T00:00:00.000Z |                          | basic monthly | 9.90   |
| 752         | 4       |          | 2020-11-04T00:00:00.000Z |                          | churn         |        |
| 753         | 1       | 2        | 2020-09-02T00:00:00.000Z | 2021-01-23T00:00:00.000Z | basic monthly | 9.90   |
| 753         | 2       |          | 2021-01-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 754         | 1       | 4        | 2020-05-03T00:00:00.000Z | 2020-05-09T00:00:00.000Z | basic monthly | 9.90   |
| 754         | 4       |          | 2020-05-09T00:00:00.000Z |                          | churn         |        |
| 755         | 1       | 3        | 2020-05-16T00:00:00.000Z | 2020-10-22T00:00:00.000Z | basic monthly | 9.90   |
| 755         | 3       |          | 2020-10-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 756         | 4       |          | 2020-02-26T00:00:00.000Z |                          | churn         |        |
| 757         | 4       |          | 2020-11-12T00:00:00.000Z |                          | churn         |        |
| 758         | 1       | 2        | 2020-11-04T00:00:00.000Z | 2020-12-30T00:00:00.000Z | basic monthly | 9.90   |
| 758         | 2       |          | 2020-12-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 759         | 2       |          | 2020-11-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 760         | 4       |          | 2020-10-04T00:00:00.000Z |                          | churn         |        |
| 761         | 1       | 2        | 2020-11-25T00:00:00.000Z | 2021-01-19T00:00:00.000Z | basic monthly | 9.90   |
| 761         | 2       | 3        | 2021-01-19T00:00:00.000Z | 2021-02-19T00:00:00.000Z | pro monthly   | 19.90  |
| 761         | 3       |          | 2021-02-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 762         | 2       |          | 2020-10-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 763         | 2       |          | 2020-07-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 764         | 2       |          | 2020-03-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 765         | 1       | 4        | 2020-11-24T00:00:00.000Z | 2021-03-12T00:00:00.000Z | basic monthly | 9.90   |
| 765         | 4       |          | 2021-03-12T00:00:00.000Z |                          | churn         |        |
| 766         | 1       | 2        | 2020-12-21T00:00:00.000Z | 2021-03-02T00:00:00.000Z | basic monthly | 9.90   |
| 766         | 2       | 4        | 2021-03-02T00:00:00.000Z | 2021-04-05T00:00:00.000Z | pro monthly   | 19.90  |
| 766         | 4       |          | 2021-04-05T00:00:00.000Z |                          | churn         |        |
| 767         | 1       | 3        | 2020-08-28T00:00:00.000Z | 2020-12-26T00:00:00.000Z | basic monthly | 9.90   |
| 767         | 3       |          | 2020-12-26T00:00:00.000Z |                          | pro annual    | 199.00 |
| 768         | 1       | 4        | 2020-03-30T00:00:00.000Z | 2020-06-01T00:00:00.000Z | basic monthly | 9.90   |
| 768         | 4       |          | 2020-06-01T00:00:00.000Z |                          | churn         |        |
| 769         | 1       | 4        | 2020-11-17T00:00:00.000Z | 2021-02-26T00:00:00.000Z | basic monthly | 9.90   |
| 769         | 4       |          | 2021-02-26T00:00:00.000Z |                          | churn         |        |
| 770         | 1       |          | 2020-12-10T00:00:00.000Z |                          | basic monthly | 9.90   |
| 771         | 4       |          | 2020-05-27T00:00:00.000Z |                          | churn         |        |
| 772         | 1       | 4        | 2020-06-18T00:00:00.000Z | 2020-08-20T00:00:00.000Z | basic monthly | 9.90   |
| 772         | 4       |          | 2020-08-20T00:00:00.000Z |                          | churn         |        |
| 773         | 2       | 4        | 2020-10-06T00:00:00.000Z | 2021-01-21T00:00:00.000Z | pro monthly   | 19.90  |
| 773         | 4       |          | 2021-01-21T00:00:00.000Z |                          | churn         |        |
| 774         | 2       |          | 2020-12-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 775         | 1       | 2        | 2020-12-01T00:00:00.000Z | 2020-12-03T00:00:00.000Z | basic monthly | 9.90   |
| 775         | 2       |          | 2020-12-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 776         | 1       | 3        | 2020-12-21T00:00:00.000Z | 2021-04-29T00:00:00.000Z | basic monthly | 9.90   |
| 776         | 3       |          | 2021-04-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 777         | 2       | 4        | 2020-09-13T00:00:00.000Z | 2020-10-07T00:00:00.000Z | pro monthly   | 19.90  |
| 777         | 4       |          | 2020-10-07T00:00:00.000Z |                          | churn         |        |
| 778         | 2       | 3        | 2020-06-09T00:00:00.000Z | 2020-11-09T00:00:00.000Z | pro monthly   | 19.90  |
| 778         | 3       |          | 2020-11-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 779         | 1       | 2        | 2020-08-23T00:00:00.000Z | 2020-11-14T00:00:00.000Z | basic monthly | 9.90   |
| 779         | 2       |          | 2020-11-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 780         | 1       | 2        | 2020-08-20T00:00:00.000Z | 2020-12-27T00:00:00.000Z | basic monthly | 9.90   |
| 780         | 2       | 3        | 2020-12-27T00:00:00.000Z | 2021-04-27T00:00:00.000Z | pro monthly   | 19.90  |
| 780         | 3       |          | 2021-04-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 781         | 1       |          | 2020-11-17T00:00:00.000Z |                          | basic monthly | 9.90   |
| 782         | 2       |          | 2020-09-15T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 783         | 3       |          | 2020-06-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 784         | 4       |          | 2020-12-09T00:00:00.000Z |                          | churn         |        |
| 785         | 2       |          | 2020-04-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 786         | 4       |          | 2020-05-17T00:00:00.000Z |                          | churn         |        |
| 787         | 2       |          | 2020-09-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 788         | 1       | 2        | 2020-05-18T00:00:00.000Z | 2020-06-23T00:00:00.000Z | basic monthly | 9.90   |
| 788         | 2       |          | 2020-06-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 789         | 1       |          | 2020-07-05T00:00:00.000Z |                          | basic monthly | 9.90   |
| 790         | 1       |          | 2020-03-17T00:00:00.000Z |                          | basic monthly | 9.90   |
| 791         | 4       |          | 2020-07-31T00:00:00.000Z |                          | churn         |        |
| 792         | 1       | 2        | 2020-09-26T00:00:00.000Z | 2020-12-27T00:00:00.000Z | basic monthly | 9.90   |
| 792         | 2       |          | 2020-12-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 793         | 1       | 4        | 2020-05-14T00:00:00.000Z | 2020-10-19T00:00:00.000Z | basic monthly | 9.90   |
| 793         | 4       |          | 2020-10-19T00:00:00.000Z |                          | churn         |        |
| 794         | 2       |          | 2020-08-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 795         | 1       | 3        | 2020-08-29T00:00:00.000Z | 2020-12-13T00:00:00.000Z | basic monthly | 9.90   |
| 795         | 3       |          | 2020-12-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 796         | 2       | 4        | 2020-05-05T00:00:00.000Z | 2020-06-07T00:00:00.000Z | pro monthly   | 19.90  |
| 796         | 4       |          | 2020-06-07T00:00:00.000Z |                          | churn         |        |
| 797         | 2       |          | 2020-01-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 798         | 1       | 2        | 2020-10-18T00:00:00.000Z | 2020-12-05T00:00:00.000Z | basic monthly | 9.90   |
| 798         | 2       | 3        | 2020-12-05T00:00:00.000Z | 2021-03-05T00:00:00.000Z | pro monthly   | 19.90  |
| 798         | 3       |          | 2021-03-05T00:00:00.000Z |                          | pro annual    | 199.00 |
| 799         | 2       |          | 2020-12-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 800         | 4       |          | 2020-05-19T00:00:00.000Z |                          | churn         |        |
| 801         | 2       |          | 2020-08-18T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 802         | 3       |          | 2020-02-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 803         | 4       |          | 2020-01-30T00:00:00.000Z |                          | churn         |        |
| 804         | 1       | 2        | 2020-07-19T00:00:00.000Z | 2020-11-13T00:00:00.000Z | basic monthly | 9.90   |
| 804         | 2       | 4        | 2020-11-13T00:00:00.000Z | 2020-11-27T00:00:00.000Z | pro monthly   | 19.90  |
| 804         | 4       |          | 2020-11-27T00:00:00.000Z |                          | churn         |        |
| 805         | 1       | 2        | 2020-04-09T00:00:00.000Z | 2020-09-02T00:00:00.000Z | basic monthly | 9.90   |
| 805         | 2       |          | 2020-09-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 806         | 1       | 2        | 2020-05-09T00:00:00.000Z | 2020-05-13T00:00:00.000Z | basic monthly | 9.90   |
| 806         | 2       | 3        | 2020-05-13T00:00:00.000Z | 2020-06-13T00:00:00.000Z | pro monthly   | 19.90  |
| 806         | 3       |          | 2020-06-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 807         | 1       | 3        | 2020-03-12T00:00:00.000Z | 2020-07-28T00:00:00.000Z | basic monthly | 9.90   |
| 807         | 3       |          | 2020-07-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 808         | 1       |          | 2020-05-24T00:00:00.000Z |                          | basic monthly | 9.90   |
| 809         | 1       |          | 2020-10-27T00:00:00.000Z |                          | basic monthly | 9.90   |
| 810         | 1       | 4        | 2020-11-29T00:00:00.000Z | 2020-12-02T00:00:00.000Z | basic monthly | 9.90   |
| 810         | 4       |          | 2020-12-02T00:00:00.000Z |                          | churn         |        |
| 811         | 1       | 4        | 2020-03-14T00:00:00.000Z | 2020-07-04T00:00:00.000Z | basic monthly | 9.90   |
| 811         | 4       |          | 2020-07-04T00:00:00.000Z |                          | churn         |        |
| 812         | 2       | 4        | 2020-05-20T00:00:00.000Z | 2020-11-15T00:00:00.000Z | pro monthly   | 19.90  |
| 812         | 4       |          | 2020-11-15T00:00:00.000Z |                          | churn         |        |
| 813         | 2       |          | 2020-02-08T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 814         | 1       | 4        | 2020-11-18T00:00:00.000Z | 2021-04-02T00:00:00.000Z | basic monthly | 9.90   |
| 814         | 4       |          | 2021-04-02T00:00:00.000Z |                          | churn         |        |
| 815         | 2       | 3        | 2020-12-09T00:00:00.000Z | 2021-01-09T00:00:00.000Z | pro monthly   | 19.90  |
| 815         | 3       |          | 2021-01-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 816         | 4       |          | 2020-01-26T00:00:00.000Z |                          | churn         |        |
| 817         | 2       | 3        | 2020-05-28T00:00:00.000Z | 2020-08-28T00:00:00.000Z | pro monthly   | 19.90  |
| 817         | 3       |          | 2020-08-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 818         | 1       | 2        | 2020-01-23T00:00:00.000Z | 2020-06-25T00:00:00.000Z | basic monthly | 9.90   |
| 818         | 2       |          | 2020-06-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 819         | 1       | 3        | 2020-01-25T00:00:00.000Z | 2020-06-01T00:00:00.000Z | basic monthly | 9.90   |
| 819         | 3       |          | 2020-06-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 820         | 1       |          | 2020-07-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 821         | 1       | 2        | 2020-04-22T00:00:00.000Z | 2020-10-06T00:00:00.000Z | basic monthly | 9.90   |
| 821         | 2       |          | 2020-10-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 822         | 1       | 3        | 2020-10-17T00:00:00.000Z | 2021-03-15T00:00:00.000Z | basic monthly | 9.90   |
| 822         | 3       |          | 2021-03-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 823         | 2       |          | 2020-04-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 824         | 2       |          | 2020-02-21T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 825         | 1       | 2        | 2020-10-04T00:00:00.000Z | 2020-11-10T00:00:00.000Z | basic monthly | 9.90   |
| 825         | 2       |          | 2020-11-10T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 826         | 1       |          | 2020-08-01T00:00:00.000Z |                          | basic monthly | 9.90   |
| 827         | 1       |          | 2020-11-10T00:00:00.000Z |                          | basic monthly | 9.90   |
| 828         | 1       | 3        | 2020-06-29T00:00:00.000Z | 2020-12-24T00:00:00.000Z | basic monthly | 9.90   |
| 828         | 3       |          | 2020-12-24T00:00:00.000Z |                          | pro annual    | 199.00 |
| 829         | 1       | 4        | 2020-04-20T00:00:00.000Z | 2020-09-23T00:00:00.000Z | basic monthly | 9.90   |
| 829         | 4       |          | 2020-09-23T00:00:00.000Z |                          | churn         |        |
| 830         | 1       | 2        | 2020-07-26T00:00:00.000Z | 2020-12-26T00:00:00.000Z | basic monthly | 9.90   |
| 830         | 2       |          | 2020-12-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 831         | 1       | 2        | 2020-08-17T00:00:00.000Z | 2020-11-13T00:00:00.000Z | basic monthly | 9.90   |
| 831         | 2       | 4        | 2020-11-13T00:00:00.000Z | 2021-01-15T00:00:00.000Z | pro monthly   | 19.90  |
| 831         | 4       |          | 2021-01-15T00:00:00.000Z |                          | churn         |        |
| 832         | 1       | 2        | 2020-03-14T00:00:00.000Z | 2020-07-13T00:00:00.000Z | basic monthly | 9.90   |
| 832         | 2       |          | 2020-07-13T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 833         | 2       | 4        | 2020-10-15T00:00:00.000Z | 2020-10-22T00:00:00.000Z | pro monthly   | 19.90  |
| 833         | 4       |          | 2020-10-22T00:00:00.000Z |                          | churn         |        |
| 834         | 2       | 3        | 2020-07-12T00:00:00.000Z | 2020-11-12T00:00:00.000Z | pro monthly   | 19.90  |
| 834         | 3       |          | 2020-11-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 835         | 1       | 4        | 2020-10-11T00:00:00.000Z | 2020-11-28T00:00:00.000Z | basic monthly | 9.90   |
| 835         | 4       |          | 2020-11-28T00:00:00.000Z |                          | churn         |        |
| 836         | 1       | 3        | 2020-03-31T00:00:00.000Z | 2020-04-16T00:00:00.000Z | basic monthly | 9.90   |
| 836         | 3       |          | 2020-04-16T00:00:00.000Z |                          | pro annual    | 199.00 |
| 837         | 2       |          | 2020-11-12T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 838         | 1       | 2        | 2020-04-02T00:00:00.000Z | 2020-07-18T00:00:00.000Z | basic monthly | 9.90   |
| 838         | 2       | 3        | 2020-07-18T00:00:00.000Z | 2020-10-18T00:00:00.000Z | pro monthly   | 19.90  |
| 838         | 3       |          | 2020-10-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 839         | 4       |          | 2020-08-20T00:00:00.000Z |                          | churn         |        |
| 840         | 2       | 3        | 2020-04-18T00:00:00.000Z | 2020-05-18T00:00:00.000Z | pro monthly   | 19.90  |
| 840         | 3       |          | 2020-05-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 841         | 2       |          | 2020-03-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 842         | 2       | 4        | 2020-02-18T00:00:00.000Z | 2020-08-14T00:00:00.000Z | pro monthly   | 19.90  |
| 842         | 4       |          | 2020-08-14T00:00:00.000Z |                          | churn         |        |
| 843         | 1       | 2        | 2020-08-18T00:00:00.000Z | 2021-02-04T00:00:00.000Z | basic monthly | 9.90   |
| 843         | 2       |          | 2021-02-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 844         | 4       |          | 2020-10-21T00:00:00.000Z |                          | churn         |        |
| 845         | 2       | 3        | 2020-04-28T00:00:00.000Z | 2020-09-28T00:00:00.000Z | pro monthly   | 19.90  |
| 845         | 3       |          | 2020-09-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 846         | 2       | 3        | 2020-03-25T00:00:00.000Z | 2020-09-25T00:00:00.000Z | pro monthly   | 19.90  |
| 846         | 3       |          | 2020-09-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 847         | 2       | 3        | 2020-01-27T00:00:00.000Z | 2020-05-27T00:00:00.000Z | pro monthly   | 19.90  |
| 847         | 3       |          | 2020-05-27T00:00:00.000Z |                          | pro annual    | 199.00 |
| 848         | 2       |          | 2021-01-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 849         | 1       | 4        | 2020-07-01T00:00:00.000Z | 2020-10-11T00:00:00.000Z | basic monthly | 9.90   |
| 849         | 4       |          | 2020-10-11T00:00:00.000Z |                          | churn         |        |
| 850         | 1       | 2        | 2020-04-29T00:00:00.000Z | 2020-07-03T00:00:00.000Z | basic monthly | 9.90   |
| 850         | 2       | 4        | 2020-07-03T00:00:00.000Z | 2020-10-26T00:00:00.000Z | pro monthly   | 19.90  |
| 850         | 4       |          | 2020-10-26T00:00:00.000Z |                          | churn         |        |
| 851         | 1       | 4        | 2020-07-25T00:00:00.000Z | 2020-12-06T00:00:00.000Z | basic monthly | 9.90   |
| 851         | 4       |          | 2020-12-06T00:00:00.000Z |                          | churn         |        |
| 852         | 1       |          | 2020-03-10T00:00:00.000Z |                          | basic monthly | 9.90   |
| 853         | 2       |          | 2020-03-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 854         | 2       | 3        | 2020-07-22T00:00:00.000Z | 2020-09-22T00:00:00.000Z | pro monthly   | 19.90  |
| 854         | 3       |          | 2020-09-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 855         | 1       |          | 2020-06-24T00:00:00.000Z |                          | basic monthly | 9.90   |
| 856         | 1       |          | 2020-05-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 857         | 1       | 2        | 2020-05-23T00:00:00.000Z | 2020-09-01T00:00:00.000Z | basic monthly | 9.90   |
| 857         | 2       | 4        | 2020-09-01T00:00:00.000Z | 2020-12-01T00:00:00.000Z | pro monthly   | 19.90  |
| 857         | 4       |          | 2020-12-01T00:00:00.000Z |                          | churn         |        |
| 858         | 2       | 3        | 2020-03-29T00:00:00.000Z | 2020-05-29T00:00:00.000Z | pro monthly   | 19.90  |
| 858         | 3       |          | 2020-05-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 859         | 4       |          | 2020-11-22T00:00:00.000Z |                          | churn         |        |
| 860         | 2       | 3        | 2020-07-08T00:00:00.000Z | 2020-11-08T00:00:00.000Z | pro monthly   | 19.90  |
| 860         | 3       |          | 2020-11-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 861         | 1       |          | 2020-07-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 862         | 4       |          | 2020-07-25T00:00:00.000Z |                          | churn         |        |
| 863         | 2       | 4        | 2020-02-18T00:00:00.000Z | 2020-04-20T00:00:00.000Z | pro monthly   | 19.90  |
| 863         | 4       |          | 2020-04-20T00:00:00.000Z |                          | churn         |        |
| 864         | 3       |          | 2020-04-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 865         | 1       | 2        | 2020-02-28T00:00:00.000Z | 2020-04-03T00:00:00.000Z | basic monthly | 9.90   |
| 865         | 2       | 4        | 2020-04-03T00:00:00.000Z | 2020-07-20T00:00:00.000Z | pro monthly   | 19.90  |
| 865         | 4       |          | 2020-07-20T00:00:00.000Z |                          | churn         |        |
| 866         | 1       | 2        | 2020-07-22T00:00:00.000Z | 2020-12-21T00:00:00.000Z | basic monthly | 9.90   |
| 866         | 2       | 4        | 2020-12-21T00:00:00.000Z | 2021-03-25T00:00:00.000Z | pro monthly   | 19.90  |
| 866         | 4       |          | 2021-03-25T00:00:00.000Z |                          | churn         |        |
| 867         | 2       |          | 2020-04-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 868         | 3       |          | 2020-03-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 869         | 1       |          | 2020-12-09T00:00:00.000Z |                          | basic monthly | 9.90   |
| 870         | 1       | 3        | 2020-08-18T00:00:00.000Z | 2020-08-23T00:00:00.000Z | basic monthly | 9.90   |
| 870         | 3       |          | 2020-08-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 871         | 1       | 2        | 2020-12-25T00:00:00.000Z | 2021-03-07T00:00:00.000Z | basic monthly | 9.90   |
| 871         | 2       |          | 2021-03-07T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 872         | 1       | 4        | 2020-10-25T00:00:00.000Z | 2021-03-12T00:00:00.000Z | basic monthly | 9.90   |
| 872         | 4       |          | 2021-03-12T00:00:00.000Z |                          | churn         |        |
| 873         | 2       | 3        | 2020-03-31T00:00:00.000Z | 2020-06-30T00:00:00.000Z | pro monthly   | 19.90  |
| 873         | 3       |          | 2020-06-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 874         | 1       |          | 2020-04-15T00:00:00.000Z |                          | basic monthly | 9.90   |
| 875         | 1       | 2        | 2020-03-20T00:00:00.000Z | 2020-08-04T00:00:00.000Z | basic monthly | 9.90   |
| 875         | 2       | 3        | 2020-08-04T00:00:00.000Z | 2020-12-04T00:00:00.000Z | pro monthly   | 19.90  |
| 875         | 3       |          | 2020-12-04T00:00:00.000Z |                          | pro annual    | 199.00 |
| 876         | 1       | 2        | 2020-04-16T00:00:00.000Z | 2020-07-19T00:00:00.000Z | basic monthly | 9.90   |
| 876         | 2       |          | 2020-07-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 877         | 1       |          | 2020-03-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 878         | 1       | 2        | 2020-08-03T00:00:00.000Z | 2020-11-23T00:00:00.000Z | basic monthly | 9.90   |
| 878         | 2       |          | 2020-11-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 879         | 1       |          | 2020-09-17T00:00:00.000Z |                          | basic monthly | 9.90   |
| 880         | 1       | 3        | 2020-08-12T00:00:00.000Z | 2021-01-10T00:00:00.000Z | basic monthly | 9.90   |
| 880         | 3       |          | 2021-01-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 881         | 2       | 4        | 2020-10-24T00:00:00.000Z | 2020-11-25T00:00:00.000Z | pro monthly   | 19.90  |
| 881         | 4       |          | 2020-11-25T00:00:00.000Z |                          | churn         |        |
| 882         | 1       |          | 2020-02-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 883         | 1       | 2        | 2020-03-12T00:00:00.000Z | 2020-07-19T00:00:00.000Z | basic monthly | 9.90   |
| 883         | 2       |          | 2020-07-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 884         | 1       | 2        | 2020-11-08T00:00:00.000Z | 2020-11-25T00:00:00.000Z | basic monthly | 9.90   |
| 884         | 2       |          | 2020-11-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 885         | 1       | 2        | 2020-03-15T00:00:00.000Z | 2020-06-22T00:00:00.000Z | basic monthly | 9.90   |
| 885         | 2       |          | 2020-06-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 886         | 2       |          | 2020-12-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 887         | 2       | 4        | 2020-05-19T00:00:00.000Z | 2020-09-25T00:00:00.000Z | pro monthly   | 19.90  |
| 887         | 4       |          | 2020-09-25T00:00:00.000Z |                          | churn         |        |
| 888         | 2       | 3        | 2020-03-03T00:00:00.000Z | 2020-05-03T00:00:00.000Z | pro monthly   | 19.90  |
| 888         | 3       |          | 2020-05-03T00:00:00.000Z |                          | pro annual    | 199.00 |
| 889         | 1       | 2        | 2020-08-27T00:00:00.000Z | 2020-09-13T00:00:00.000Z | basic monthly | 9.90   |
| 889         | 2       | 4        | 2020-09-13T00:00:00.000Z | 2021-03-03T00:00:00.000Z | pro monthly   | 19.90  |
| 889         | 4       |          | 2021-03-03T00:00:00.000Z |                          | churn         |        |
| 890         | 2       |          | 2020-09-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 891         | 1       | 2        | 2020-05-14T00:00:00.000Z | 2020-08-12T00:00:00.000Z | basic monthly | 9.90   |
| 891         | 2       | 4        | 2020-08-12T00:00:00.000Z | 2021-02-02T00:00:00.000Z | pro monthly   | 19.90  |
| 891         | 4       |          | 2021-02-02T00:00:00.000Z |                          | churn         |        |
| 892         | 4       |          | 2020-07-27T00:00:00.000Z |                          | churn         |        |
| 893         | 1       | 3        | 2020-05-23T00:00:00.000Z | 2020-10-15T00:00:00.000Z | basic monthly | 9.90   |
| 893         | 3       |          | 2020-10-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 894         | 2       |          | 2020-12-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 895         | 1       | 3        | 2020-09-14T00:00:00.000Z | 2021-02-15T00:00:00.000Z | basic monthly | 9.90   |
| 895         | 3       |          | 2021-02-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 896         | 1       | 2        | 2020-06-07T00:00:00.000Z | 2020-08-16T00:00:00.000Z | basic monthly | 9.90   |
| 896         | 2       |          | 2020-08-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 897         | 1       | 2        | 2020-07-01T00:00:00.000Z | 2020-08-12T00:00:00.000Z | basic monthly | 9.90   |
| 897         | 2       | 4        | 2020-08-12T00:00:00.000Z | 2020-12-30T00:00:00.000Z | pro monthly   | 19.90  |
| 897         | 4       |          | 2020-12-30T00:00:00.000Z |                          | churn         |        |
| 898         | 4       |          | 2020-05-17T00:00:00.000Z |                          | churn         |        |
| 899         | 1       | 4        | 2020-05-04T00:00:00.000Z | 2020-07-14T00:00:00.000Z | basic monthly | 9.90   |
| 899         | 4       |          | 2020-07-14T00:00:00.000Z |                          | churn         |        |
| 900         | 2       |          | 2020-10-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 901         | 1       | 2        | 2020-04-28T00:00:00.000Z | 2020-05-22T00:00:00.000Z | basic monthly | 9.90   |
| 901         | 2       |          | 2020-05-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 902         | 1       |          | 2021-01-05T00:00:00.000Z |                          | basic monthly | 9.90   |
| 903         | 1       | 4        | 2020-05-16T00:00:00.000Z | 2020-06-17T00:00:00.000Z | basic monthly | 9.90   |
| 903         | 4       |          | 2020-06-17T00:00:00.000Z |                          | churn         |        |
| 904         | 4       |          | 2020-07-06T00:00:00.000Z |                          | churn         |        |
| 905         | 2       |          | 2020-02-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 906         | 1       | 2        | 2020-04-21T00:00:00.000Z | 2020-04-29T00:00:00.000Z | basic monthly | 9.90   |
| 906         | 2       |          | 2020-04-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 907         | 1       | 2        | 2020-03-31T00:00:00.000Z | 2020-06-26T00:00:00.000Z | basic monthly | 9.90   |
| 907         | 2       | 4        | 2020-06-26T00:00:00.000Z | 2020-10-20T00:00:00.000Z | pro monthly   | 19.90  |
| 907         | 4       |          | 2020-10-20T00:00:00.000Z |                          | churn         |        |
| 908         | 2       |          | 2020-02-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 909         | 1       | 3        | 2020-09-16T00:00:00.000Z | 2021-01-18T00:00:00.000Z | basic monthly | 9.90   |
| 909         | 3       |          | 2021-01-18T00:00:00.000Z |                          | pro annual    | 199.00 |
| 910         | 2       |          | 2020-07-30T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 911         | 1       | 2        | 2020-05-08T00:00:00.000Z | 2020-06-05T00:00:00.000Z | basic monthly | 9.90   |
| 911         | 2       |          | 2020-06-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 912         | 2       | 3        | 2020-12-23T00:00:00.000Z | 2021-02-23T00:00:00.000Z | pro monthly   | 19.90  |
| 912         | 3       |          | 2021-02-23T00:00:00.000Z |                          | pro annual    | 199.00 |
| 913         | 2       |          | 2021-01-03T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 914         | 1       | 2        | 2020-07-25T00:00:00.000Z | 2020-07-30T00:00:00.000Z | basic monthly | 9.90   |
| 914         | 2       | 4        | 2020-07-30T00:00:00.000Z | 2020-10-05T00:00:00.000Z | pro monthly   | 19.90  |
| 914         | 4       |          | 2020-10-05T00:00:00.000Z |                          | churn         |        |
| 915         | 2       |          | 2020-10-05T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 916         | 2       | 3        | 2020-01-26T00:00:00.000Z | 2020-02-26T00:00:00.000Z | pro monthly   | 19.90  |
| 916         | 3       |          | 2020-02-26T00:00:00.000Z |                          | pro annual    | 199.00 |
| 917         | 1       | 3        | 2020-07-14T00:00:00.000Z | 2020-10-10T00:00:00.000Z | basic monthly | 9.90   |
| 917         | 3       |          | 2020-10-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 918         | 1       | 2        | 2020-06-10T00:00:00.000Z | 2020-09-01T00:00:00.000Z | basic monthly | 9.90   |
| 918         | 2       | 3        | 2020-09-01T00:00:00.000Z | 2020-12-01T00:00:00.000Z | pro monthly   | 19.90  |
| 918         | 3       |          | 2020-12-01T00:00:00.000Z |                          | pro annual    | 199.00 |
| 919         | 4       |          | 2020-09-19T00:00:00.000Z |                          | churn         |        |
| 920         | 2       |          | 2020-08-26T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 921         | 1       | 2        | 2020-08-02T00:00:00.000Z | 2020-11-20T00:00:00.000Z | basic monthly | 9.90   |
| 921         | 2       |          | 2020-11-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 922         | 2       | 3        | 2020-11-09T00:00:00.000Z | 2021-02-09T00:00:00.000Z | pro monthly   | 19.90  |
| 922         | 3       |          | 2021-02-09T00:00:00.000Z |                          | pro annual    | 199.00 |
| 923         | 2       | 4        | 2020-09-04T00:00:00.000Z | 2020-11-04T00:00:00.000Z | pro monthly   | 19.90  |
| 923         | 4       |          | 2020-11-04T00:00:00.000Z |                          | churn         |        |
| 924         | 1       | 2        | 2020-06-26T00:00:00.000Z | 2020-12-02T00:00:00.000Z | basic monthly | 9.90   |
| 924         | 2       |          | 2020-12-02T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 925         | 1       | 2        | 2020-09-28T00:00:00.000Z | 2021-02-04T00:00:00.000Z | basic monthly | 9.90   |
| 925         | 2       |          | 2021-02-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 926         | 1       | 2        | 2020-07-19T00:00:00.000Z | 2020-10-13T00:00:00.000Z | basic monthly | 9.90   |
| 926         | 2       | 3        | 2020-10-13T00:00:00.000Z | 2021-02-13T00:00:00.000Z | pro monthly   | 19.90  |
| 926         | 3       |          | 2021-02-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 927         | 2       |          | 2020-01-20T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 928         | 4       |          | 2020-07-15T00:00:00.000Z |                          | churn         |        |
| 929         | 1       | 3        | 2020-04-09T00:00:00.000Z | 2020-08-13T00:00:00.000Z | basic monthly | 9.90   |
| 929         | 3       |          | 2020-08-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 930         | 1       | 2        | 2020-02-21T00:00:00.000Z | 2020-03-24T00:00:00.000Z | basic monthly | 9.90   |
| 930         | 2       |          | 2020-03-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 931         | 1       | 2        | 2020-02-03T00:00:00.000Z | 2020-02-12T00:00:00.000Z | basic monthly | 9.90   |
| 931         | 2       | 3        | 2020-02-12T00:00:00.000Z | 2020-04-12T00:00:00.000Z | pro monthly   | 19.90  |
| 931         | 3       |          | 2020-04-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 932         | 3       |          | 2020-11-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 933         | 1       | 2        | 2020-05-15T00:00:00.000Z | 2020-06-24T00:00:00.000Z | basic monthly | 9.90   |
| 933         | 2       |          | 2020-06-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 934         | 2       | 4        | 2020-01-14T00:00:00.000Z | 2020-04-25T00:00:00.000Z | pro monthly   | 19.90  |
| 934         | 4       |          | 2020-04-25T00:00:00.000Z |                          | churn         |        |
| 935         | 4       |          | 2020-02-01T00:00:00.000Z |                          | churn         |        |
| 936         | 2       |          | 2020-09-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 937         | 2       | 3        | 2020-02-29T00:00:00.000Z | 2020-08-29T00:00:00.000Z | pro monthly   | 19.90  |
| 937         | 3       |          | 2020-08-29T00:00:00.000Z |                          | pro annual    | 199.00 |
| 938         | 1       | 3        | 2020-08-08T00:00:00.000Z | 2020-11-08T00:00:00.000Z | basic monthly | 9.90   |
| 938         | 3       |          | 2020-11-08T00:00:00.000Z |                          | pro annual    | 199.00 |
| 939         | 1       | 2        | 2020-03-27T00:00:00.000Z | 2020-08-16T00:00:00.000Z | basic monthly | 9.90   |
| 939         | 2       |          | 2020-08-16T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 940         | 2       | 4        | 2020-01-24T00:00:00.000Z | 2020-03-22T00:00:00.000Z | pro monthly   | 19.90  |
| 940         | 4       |          | 2020-03-22T00:00:00.000Z |                          | churn         |        |
| 941         | 2       |          | 2020-09-22T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 942         | 1       | 4        | 2020-12-13T00:00:00.000Z | 2021-01-18T00:00:00.000Z | basic monthly | 9.90   |
| 942         | 4       |          | 2021-01-18T00:00:00.000Z |                          | churn         |        |
| 943         | 1       | 3        | 2020-11-20T00:00:00.000Z | 2021-01-14T00:00:00.000Z | basic monthly | 9.90   |
| 943         | 3       |          | 2021-01-14T00:00:00.000Z |                          | pro annual    | 199.00 |
| 944         | 1       | 2        | 2020-10-01T00:00:00.000Z | 2021-01-14T00:00:00.000Z | basic monthly | 9.90   |
| 944         | 2       |          | 2021-01-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 945         | 1       | 3        | 2020-01-14T00:00:00.000Z | 2020-03-25T00:00:00.000Z | basic monthly | 9.90   |
| 945         | 3       |          | 2020-03-25T00:00:00.000Z |                          | pro annual    | 199.00 |
| 946         | 2       | 3        | 2020-07-17T00:00:00.000Z | 2020-12-17T00:00:00.000Z | pro monthly   | 19.90  |
| 946         | 3       |          | 2020-12-17T00:00:00.000Z |                          | pro annual    | 199.00 |
| 947         | 1       | 3        | 2020-07-20T00:00:00.000Z | 2020-09-19T00:00:00.000Z | basic monthly | 9.90   |
| 947         | 3       |          | 2020-09-19T00:00:00.000Z |                          | pro annual    | 199.00 |
| 948         | 1       | 4        | 2020-03-23T00:00:00.000Z | 2020-08-18T00:00:00.000Z | basic monthly | 9.90   |
| 948         | 4       |          | 2020-08-18T00:00:00.000Z |                          | churn         |        |
| 949         | 2       |          | 2020-10-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 950         | 2       | 3        | 2020-09-20T00:00:00.000Z | 2021-01-20T00:00:00.000Z | pro monthly   | 19.90  |
| 950         | 3       |          | 2021-01-20T00:00:00.000Z |                          | pro annual    | 199.00 |
| 951         | 2       |          | 2020-08-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 952         | 2       |          | 2020-08-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 953         | 1       |          | 2020-09-15T00:00:00.000Z |                          | basic monthly | 9.90   |
| 954         | 4       |          | 2020-11-30T00:00:00.000Z |                          | churn         |        |
| 955         | 2       |          | 2020-08-04T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 956         | 1       | 2        | 2020-02-27T00:00:00.000Z | 2020-07-12T00:00:00.000Z | basic monthly | 9.90   |
| 956         | 2       | 3        | 2020-07-12T00:00:00.000Z | 2021-01-12T00:00:00.000Z | pro monthly   | 19.90  |
| 956         | 3       |          | 2021-01-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 957         | 4       |          | 2020-05-05T00:00:00.000Z |                          | churn         |        |
| 958         | 1       | 2        | 2020-07-13T00:00:00.000Z | 2020-11-22T00:00:00.000Z | basic monthly | 9.90   |
| 958         | 2       | 3        | 2020-11-22T00:00:00.000Z | 2021-01-22T00:00:00.000Z | pro monthly   | 19.90  |
| 958         | 3       |          | 2021-01-22T00:00:00.000Z |                          | pro annual    | 199.00 |
| 959         | 1       |          | 2020-04-29T00:00:00.000Z |                          | basic monthly | 9.90   |
| 960         | 2       | 3        | 2020-10-29T00:00:00.000Z | 2021-02-28T00:00:00.000Z | pro monthly   | 19.90  |
| 960         | 3       |          | 2021-02-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 961         | 1       | 3        | 2020-09-19T00:00:00.000Z | 2020-11-21T00:00:00.000Z | basic monthly | 9.90   |
| 961         | 3       |          | 2020-11-21T00:00:00.000Z |                          | pro annual    | 199.00 |
| 962         | 1       | 2        | 2020-06-10T00:00:00.000Z | 2020-09-23T00:00:00.000Z | basic monthly | 9.90   |
| 962         | 2       | 4        | 2020-09-23T00:00:00.000Z | 2020-11-20T00:00:00.000Z | pro monthly   | 19.90  |
| 962         | 4       |          | 2020-11-20T00:00:00.000Z |                          | churn         |        |
| 963         | 2       |          | 2020-01-11T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 964         | 1       | 4        | 2020-10-16T00:00:00.000Z | 2021-02-27T00:00:00.000Z | basic monthly | 9.90   |
| 964         | 4       |          | 2021-02-27T00:00:00.000Z |                          | churn         |        |
| 965         | 1       |          | 2020-06-26T00:00:00.000Z |                          | basic monthly | 9.90   |
| 966         | 1       |          | 2020-02-16T00:00:00.000Z |                          | basic monthly | 9.90   |
| 967         | 1       | 2        | 2020-08-28T00:00:00.000Z | 2021-01-15T00:00:00.000Z | basic monthly | 9.90   |
| 967         | 2       | 3        | 2021-01-15T00:00:00.000Z | 2021-04-15T00:00:00.000Z | pro monthly   | 19.90  |
| 967         | 3       |          | 2021-04-15T00:00:00.000Z |                          | pro annual    | 199.00 |
| 968         | 2       |          | 2020-11-29T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 969         | 2       | 3        | 2020-02-28T00:00:00.000Z | 2020-06-28T00:00:00.000Z | pro monthly   | 19.90  |
| 969         | 3       |          | 2020-06-28T00:00:00.000Z |                          | pro annual    | 199.00 |
| 970         | 1       |          | 2020-10-12T00:00:00.000Z |                          | basic monthly | 9.90   |
| 971         | 2       |          | 2020-01-09T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 972         | 3       |          | 2020-02-12T00:00:00.000Z |                          | pro annual    | 199.00 |
| 973         | 4       |          | 2020-01-15T00:00:00.000Z |                          | churn         |        |
| 974         | 1       | 3        | 2020-09-17T00:00:00.000Z | 2020-10-16T00:00:00.000Z | basic monthly | 9.90   |
| 974         | 3       |          | 2020-10-16T00:00:00.000Z |                          | pro annual    | 199.00 |
| 975         | 1       | 3        | 2020-11-22T00:00:00.000Z | 2021-04-30T00:00:00.000Z | basic monthly | 9.90   |
| 975         | 3       |          | 2021-04-30T00:00:00.000Z |                          | pro annual    | 199.00 |
| 976         | 1       | 3        | 2020-11-18T00:00:00.000Z | 2021-02-13T00:00:00.000Z | basic monthly | 9.90   |
| 976         | 3       |          | 2021-02-13T00:00:00.000Z |                          | pro annual    | 199.00 |
| 977         | 1       | 4        | 2020-08-11T00:00:00.000Z | 2020-11-03T00:00:00.000Z | basic monthly | 9.90   |
| 977         | 4       |          | 2020-11-03T00:00:00.000Z |                          | churn         |        |
| 978         | 2       | 3        | 2020-09-03T00:00:00.000Z | 2020-11-03T00:00:00.000Z | pro monthly   | 19.90  |
| 978         | 3       |          | 2020-11-03T00:00:00.000Z |                          | pro annual    | 199.00 |
| 979         | 1       |          | 2021-01-04T00:00:00.000Z |                          | basic monthly | 9.90   |
| 980         | 2       |          | 2020-06-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 981         | 2       |          | 2020-02-23T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 982         | 1       | 2        | 2020-06-20T00:00:00.000Z | 2020-10-14T00:00:00.000Z | basic monthly | 9.90   |
| 982         | 2       |          | 2020-10-14T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 983         | 1       |          | 2020-12-19T00:00:00.000Z |                          | basic monthly | 9.90   |
| 984         | 1       | 4        | 2020-07-07T00:00:00.000Z | 2020-09-30T00:00:00.000Z | basic monthly | 9.90   |
| 984         | 4       |          | 2020-09-30T00:00:00.000Z |                          | churn         |        |
| 985         | 4       |          | 2020-08-09T00:00:00.000Z |                          | churn         |        |
| 986         | 1       | 4        | 2020-11-23T00:00:00.000Z | 2021-04-13T00:00:00.000Z | basic monthly | 9.90   |
| 986         | 4       |          | 2021-04-13T00:00:00.000Z |                          | churn         |        |
| 987         | 4       |          | 2020-01-12T00:00:00.000Z |                          | churn         |        |
| 988         | 4       |          | 2020-05-09T00:00:00.000Z |                          | churn         |        |
| 989         | 2       | 3        | 2020-09-10T00:00:00.000Z | 2021-01-10T00:00:00.000Z | pro monthly   | 19.90  |
| 989         | 3       |          | 2021-01-10T00:00:00.000Z |                          | pro annual    | 199.00 |
| 990         | 1       |          | 2020-07-30T00:00:00.000Z |                          | basic monthly | 9.90   |
| 991         | 2       |          | 2020-10-25T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 992         | 2       |          | 2020-10-24T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 993         | 4       |          | 2020-11-07T00:00:00.000Z |                          | churn         |        |
| 994         | 1       | 2        | 2020-08-01T00:00:00.000Z | 2020-08-27T00:00:00.000Z | basic monthly | 9.90   |
| 994         | 2       |          | 2020-08-27T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 995         | 1       | 2        | 2020-06-18T00:00:00.000Z | 2020-12-06T00:00:00.000Z | basic monthly | 9.90   |
| 995         | 2       |          | 2020-12-06T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 996         | 1       | 4        | 2020-11-18T00:00:00.000Z | 2020-12-07T00:00:00.000Z | basic monthly | 9.90   |
| 996         | 4       |          | 2020-12-07T00:00:00.000Z |                          | churn         |        |
| 997         | 1       | 2        | 2020-08-03T00:00:00.000Z | 2020-08-26T00:00:00.000Z | basic monthly | 9.90   |
| 997         | 2       | 4        | 2020-08-26T00:00:00.000Z | 2020-11-14T00:00:00.000Z | pro monthly   | 19.90  |
| 997         | 4       |          | 2020-11-14T00:00:00.000Z |                          | churn         |        |
| 998         | 2       |          | 2020-10-19T00:00:00.000Z |                          | pro monthly   | 19.90  |
| 999         | 2       | 4        | 2020-10-30T00:00:00.000Z | 2020-12-01T00:00:00.000Z | pro monthly   | 19.90  |
| 999         | 4       |          | 2020-12-01T00:00:00.000Z |                          | churn         |        |
| 1000        | 2       | 4        | 2020-03-26T00:00:00.000Z | 2020-06-04T00:00:00.000Z | pro monthly   | 19.90  |
| 1000        | 4       |          | 2020-06-04T00:00:00.000Z |                          | churn         |        |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16)