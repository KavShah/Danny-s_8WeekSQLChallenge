**Schema (PostgreSQL v13)**

    CREATE TABLE sales (
      "customer_id" VARCHAR(1),
      "order_date" DATE,
      "product_id" INTEGER
    );
    
    INSERT INTO sales
      ("customer_id", "order_date", "product_id")
    VALUES
      ('A', '2021-01-01', '1'),
      ('A', '2021-01-01', '2'),
      ('A', '2021-01-07', '2'),
      ('A', '2021-01-10', '3'),
      ('A', '2021-01-11', '3'),
      ('A', '2021-01-11', '3'),
      ('B', '2021-01-01', '2'),
      ('B', '2021-01-02', '2'),
      ('B', '2021-01-04', '1'),
      ('B', '2021-01-11', '1'),
      ('B', '2021-01-16', '3'),
      ('B', '2021-02-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-07', '3');
     
    
    CREATE TABLE menu (
      "product_id" INTEGER,
      "product_name" VARCHAR(5),
      "price" INTEGER
    );
    
    INSERT INTO menu
      ("product_id", "product_name", "price")
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');
      
    
    CREATE TABLE members (
      "customer_id" VARCHAR(1),
      "join_date" DATE
    );
    
    INSERT INTO members
      ("customer_id", "join_date")
    VALUES
      ('A', '2021-01-07'),
      ('B', '2021-01-09');

---

**Query #1**

    SELECT
      	s.customer_id,
        sum(m.price) as Total
    FROM sales s join menu m 
    on s.product_id=m.product_id
    group by customer_id
    order by 2 desc;

| customer_id | total |
| ----------- | ----- |
| A           | 76    |
| B           | 74    |
| C           | 36    |

---
**Query #2**

    select customer_id,
    count(distinct order_date) as Visits
    from sales
    group by customer_id
    order by 2 desc;

| customer_id | visits |
| ----------- | ------ |
| B           | 6      |
| A           | 4      |
| C           | 2      |

---
**Query #3**

    With q1 as(
    select customer_id, product_name,
    row_number() over(partition by customer_id order by order_date, s.product_id) as rk
    from sales s join menu m
    on s.product_id=m.product_id)
    select customer_id, product_name from q1
    where rk = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**Query #4**

    select product_name,
    count(s.product_id) as ordered
    from sales s join menu m
    on s.product_id=m.product_id
    group by product_name
    order by ordered desc
    limit 1;

| product_name | ordered |
| ------------ | ------- |
| ramen        | 8       |

---
**Query #5**

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

| customer_id | product_name | times_ordered |
| ----------- | ------------ | ------------- |
| A           | ramen        | 3             |
| B           | ramen        | 2             |
| B           | curry        | 2             |
| B           | sushi        | 2             |
| C           | ramen        | 3             |

---
**Query #6**

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

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
**Query #7**

    with q1 as(
    select s.customer_id, order_date, product_id
    from sales s join members m
    on s.customer_id=m.customer_id
    where s.order_date < m.join_date)
    , q2 as (
    select q1.customer_id, product_name,
      rank() over (partition by q1.customer_id order by q1.order_date desc, q1.product_id desc) as rk
      from q1 join menu me
      on q1.product_id = me.product_id
    )
    select customer_id, product_name
    from q2
    where rk=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
**Query #8**

    select s.customer_id, count(s.product_id) as BeforeMemberordered, sum(price) as BeforeMembertotal
    from sales s join members m
    on s.customer_id=m.customer_id
    join menu me 
    on s.product_id=me.product_id
    where s.order_date < m.join_date
    group by 1;

| customer_id | beforememberordered | beforemembertotal |
| ----------- | ------------------- | ----------------- |
| B           | 3                   | 40                |
| A           | 2                   | 25                |

---
**Query #9**

    select customer_id,
    sum(case when s.product_id = 1 then price*20
    	else price*10 end) as RewardPoints
    from sales s join menu m
    on s.product_id=m.product_id
    group by 1;

| customer_id | rewardpoints |
| ----------- | ------------ |
| B           | 940          |
| C           | 360          |
| A           | 860          |

---
**Query #10**

    select s.customer_id,sum(
    case when (order_date >= join_date) and (order_date < join_date + integer '7')  then price*20
    	else (case when s.product_id=1 then price*20
             else price*10 end) end) as RewardPoints
    from sales s join menu m
    on s.product_id=m.product_id
    join members me on s.customer_id=me.customer_id
    where order_date <= date '2021-01-31'
    group by 1;

| customer_id | rewardpoints |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

---
**Query #11**

    select s.customer_id, order_date, product_name, price,
    case when order_date < join_date then 'N'
    	when order_date >= join_date then 'Y'
        else 'N' end as Member
    from sales s join menu m
    on s.product_id=m.product_id
    left join members me 
    on s.customer_id=me.customer_id
    order by customer_id, order_date;

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

---
**Query #12**

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

---

[View on DB Fiddle](https://www.db-fiddle.com/f/m8poJtm4GHX57Fz3WmGyTv/2)
