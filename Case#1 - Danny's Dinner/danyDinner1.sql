/* 1] What is the total amount each 
customer spent at the restaurant?*/

use DannyDinner

select s.customer_id , sum( m.price) as Money_Spend
FROM SALES AS S
JOIN MENU AS M
on s.product_id = m.product_id
GROUP BY s.customer_id;

/* 2] How many days has each customer visited the restaurant? */

select customer_id , count(distinct(order_date)) as visit_count
from sales
group by customer_id;

/* 3] What was the first item from the menu purchased by each customer?*/

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

/* 4] What is the most purchased item on the menu and how many 
times was it purchased by all customers? */

SELECT top 1 menu.product_name, COUNT(sales.product_id) AS most_purchased_item
FROM sales
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY most_purchased_item DESC;


/* 5] Which item was the most popular for each customer?*/

use DannyDinner;
with purchased_item as (
select s.customer_id 
	, m.product_name
	,COUNT(m.product_id) AS order_count
	, DENSE_RANK() over(partition by s.customer_id order by count(s.customer_id) desc) AS RANK_id
from sales as s
join menu as m
on s.product_id = m.product_id
group by s.customer_id , m.product_name )

select customer_id , product_name,
order_count
from purchased_item
where RANK_id = 1
;
 /* 6] Which item was purchased first by the customer after they became a member?*/

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


/* 7] Which item was purchased just before the customer became a member?*/

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


/* 8] What is the total items and amount spent for each member before they became a member?*/

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

/* 9]  If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?*/
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

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January? */

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
