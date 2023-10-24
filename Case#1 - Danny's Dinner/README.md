# Danny's Dinner 🍣🍛🍜

![App Screenshot](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

Hey there! 👋

I'm really happy to tell you that I finished the "Danny Dinner" project as part of an 8-week SQL challenge. I used a special tool called MS SQL Server. 🎉

During this project, I got to work on a real project, like something people use every day! This made me much better at using SQL. I also learned about something cool called "windows function" in SQL and I used it in my project. 💡

The whole "Danny's Dinner" project taught me how to solve different kinds of problems. It also helped me get better and feel more sure about what I'm doing. 💪

Thanks to this project, I'm feeling more confident in my SQL skills. 💼

## Introduction 🍽️
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business. 📊

## Problem Statement 🧩
Danny wants to use the data to answer a few simple questions about his customers. 

- **Visiting patterns** 🚶‍♀️🚶
- **How much money they’ve spent** 💸💰
- **Which menu items are their favourite** 🍣🍜🥘

Having this deeper connection with his customers will help him **deliver a better and more personalised experience for his loyal customers** 🌟

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions! 📋

Danny has shared with you 3 key datasets for this case study:

- sales
- menu
- members
You can inspect the entity relationship diagram and example data below.

![App Screenshot](https://miro.medium.com/v2/resize:fit:750/format:webp/1*fEmZXjnIof5BHL_sLGDVUg.png)

## Case Study Questions 📚

Each of the following case study questions can be answered using a single SQL statement:

- What is the total amount each customer spent at the restaurant?
- How many days has each customer visited the restaurant?
- What was the first item from the menu purchased by each customer?
- What is the most purchased item on the menu and how many times was it purchased by all customers?
- Which item was the most popular for each customer?
- Which item was purchased first by the customer after they became a member?
- Which item was purchased just before the customer became a member?
- What is the total items and amount spent for each member before they became a member?
- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Answer

### 1. What is the total amount each customer spent at the restaurant?

```` sql
Select s.customer_id , sum( m.price) as Money_Spend
FROM SALES AS S
JOIN MENU AS M
on s.product_id = m.product_id
GROUP BY s.customer_id;
````
#### Answer:

| customer_id | Money_Spend     | 
| :-------- | :------- | 
| A   | 76 | 
| B      |74 |
| C     | 36 |

Customer **A** spend Most money $76 and Customer **B** and **C** spend $74 & $36 respectively

***

### 2. How many days has each customer visited the restaurant?

````sql
select customer_id , count(distinct(order_date)) as visit_count
from sales
group by customer_id;
````

#### Answer:
| Customer_id | Times_visited |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A, B and C visited 4, 6 and 2 times respectivly.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
with ordered_date as(
	select s.customer_id
		, s.order_date
		, m.product_name
		, DENSE_RANK() over (partition by s.customer_id
		  order by s.order_date) as rank_no
	from sales as s
	join menu as m
	on  m.product_id = s.product_id
	)
select customer_id , product_name
from ordered_date
where rank_no = 1
group by customer_id , product_name;

````

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first order is curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT top 1 menu.product_name, COUNT(sales.product_id) AS most_purchased_item
FROM sales
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY most_purchased_item DESC;
````



#### Answer:
| Product_name  | most_purchased_item | 
| ----------- | ----------- |
| ramen       | 8|


- Most purchased item on the menu is ramen which is 8 times

### 5. Which item was the most popular for each customer?

````sql
with purchased_item as 
(
    select s.customer_id 
        , m.product_name
        ,COUNT(m.product_id) AS order_count
        , DENSE_RANK() over(partition by s.customer_id order by count(s.customer_id) desc) AS RANK_id
    from sales as s
    join menu as m
    on s.product_id = m.product_id
    group by s.customer_id , m.product_name 
)

select customer_id , product_name,
order_count
from purchased_item
where RANK_id = 1;

````

#### Answer:
| Customer_id | Product_name | Count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen while customer B like all items on the menu.

### 6. Which item was purchased first by the customer after they became a member?

````sql
with joined_member as (
	select s.customer_id
		, m.product_name
		, DENSE_RANK() over ( partition by s.customer_id 
								order by s.order_date) as rank_id
	from menu as m
	join sales as s
	on s.product_id = m.product_id
	join members as me
	on me.customer_id = s.customer_id
	where s.order_date > me.join_date
)
select  customer_id , product_name
from joined_member
where rank_id=1
group by customer_id , product_name;

````


#### Answer:
| customer_id |  product_name |
| ----------- | ----------  |
| A           |  ramen        |
| B           |  sushi        |

After becoming a member 
- Customer A's first order was ramen.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
with joined_member as (
	select s.customer_id
		, m.product_name
		, dense_rank() over ( partition by s.customer_id 
								order by s.order_date desc) as rank_id
	from menu as m
	join sales as s
	on s.product_id = m.product_id
	join members as me
	on me.customer_id = s.customer_id
	where s.order_date < me.join_date
)
select  customer_id , product_name
from joined_member
where rank_id=1
group by customer_id , product_name;
````

#### Answer:
| customer_id |product_name |
| ----------- | ----------  |
| A           |  curry      |
| A           |  sushi      | 
| B           |  sushi      |

Before becoming a member 
- Customer A’s  order was sushi and curry.
- Customer B’s order was sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
select s.customer_id 
	, COUNT(s.product_id) as total_item
	, SUM(m.price) as total_sales
from sales as s
join menu as m
	on s.product_id = m.product_id
join members as me
	on s.customer_id = me.customer_id
where s.order_date < me.join_date
group by s.customer_id;

````


#### Answer:
| customer_id |total_item | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

Before becoming a member
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
With Points as
(
Select *, Case When product_id = 1 THEN price*20
               Else price*10
			   End as Points
From Menu
)
Select S.customer_id, Sum(P.points) as Points
From Sales S
Join Points p
On p.product_id = S.product_id
Group by S.customer_id;
````


#### Answer:
| customer_id | Points | 
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for customer A, B and C are 860, 940 and 360 respectivly.

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
WITH dates AS 
(
   SELECT *, 
   DATEADD(DAY, 6, join_date) AS valid_date, 
   EOMONTH('2021-01-31') AS last_date
   FROM members 
)
Select S.Customer_id, 
       SUM(
	         Case 
		       When m.product_ID = 1 THEN m.price*20
			     When S.order_date between D.join_date and D.valid_date Then m.price*20
			     Else m.price*10
			     END 
		       ) as Points
From Dates D
join Sales S
On D.customer_id = S.customer_id
Join Menu M
On M.product_id = S.product_id
Where S.order_date < d.last_date
Group by S.customer_id;
````

#### Answer:
| Customer_id | Points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A and B are 1,370 and 820 respectivly.

***
