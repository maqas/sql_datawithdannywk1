

CREATE view [dbo].[wk1_q1]
as
(
select distinct customerid, sum(price)[TotalPrice]
from sales a 
inner join menu b 
on a.product_Id = b.product_Id

group by customerid
)


/****** Object:  View [dbo].[wk1_q2]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[wk1_q2]
as
(
select customerid, count(order_date)Dates_Visited
from SALES

group by customerid

)
GO
/****** Object:  View [dbo].[wk1_q3]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[wk1_q3] 
as
(
select * from
(
select customerid, b.product_name,  a.product_id, order_date,
rank() over(partition by customerid order by order_date) rank_col,
dense_rank() over(partition by customerid order by order_date) dense_rank_col
from SALES a
inner join MENU b
on a.product_Id = b.product_id
) a
where a.rank_col = 1

)
GO
/****** Object:  View [dbo].[wk1_q4]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[wk1_q4]
as(


SELECT product_id,count(product_Id)MostPurchased FROM sales
	where product_Id IN
   (
        SELECT count(price) NoofPurhcases
            FROM  SALES a
			inner join MENU b
			on a.product_Id = b.product_id
            GROUP BY product_name
    ) 
	group by product_Id

	)
GO
/****** Object:  View [dbo].[wk1_q5]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[wk1_q5]
as(
select * from (

select customerid, b.product_name,
count(a.order_date)PurchaseCount,
dense_rank() over(partition by customerid order by count(a.order_date)desc)rank
from SALES a
inner join MENU b
on a.product_Id = b.product_Id
group by customerid,a.product_Id,b.product_name

) sq
where sq.rank = 1

)


GO
/****** Object:  Table [dbo].[MEMBERS]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MEMBERS](
	[customer_id] [varchar](1) NULL,
	[join_date] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[wk1_q6]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[wk1_q6]
as
(
select *
from (
select customer_id ,c.product_name join_date,order_date, DATEDIFF(day,join_date,order_date)DateDifference
,rank() over(partition by customer_id order by DATEDIFF(day,join_date,order_date)asc)rank
from MEMBERS a
join SALES b
on a.customer_id = b.customerid
join MENU c
on b.product_Id = c.product_id
group by customer_id, join_date,order_date,product_name
having DATEDIFF(day,join_date,order_date)  >= 0
)sq
where sq.rank = 1 
)
GO
/****** Object:  View [dbo].[wk1_q7]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[wk1_q7]
as
(
select customerid, product_name, join_date, order_date from(

	select customerid, product_name, join_date,  order_date,DATEDIFF(day, join_date, order_date)DateDiffernce,
	rank() over(partition by customerid order by DATEDIFF(day, join_date, order_date)desc)rank
	from MEMBERS a
	join SALES b
	on a.customer_id = b.customerid
	join MENU c
	on b.product_Id = c.product_id
	where DATEDIFF(day, join_date, order_date) < 0
	)sq

	where sq.rank = 1 

)
GO
/****** Object:  View [dbo].[wk1_q8]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[wk1_q8]
as 
(
select customerid, count( product_Id)count_items,sum(price)TotalPrice
from(
	select customerid,b.product_Id, price, DATEDIFF(day, join_date, order_date)DateDifference
	from MEMBERS a
	join SALES b 
	on a.customer_id = b.customerid
	join MENU c
	on b.product_Id = c.product_id
	where DATEDIFF(day, join_date, order_date) < 0
	group by customerid,b.product_Id,join_date, order_date,price
)sq

GROUP BY customerid
)

GO
/****** Object:  View [dbo].[wk1_q9]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[wk1_q9]
	as
	(
	select customerid, sum(TotalPoints)CustPoints
	from (
		select  customerid,
		sum(points_1)TotalPoints
		from (
			select customerid, price, 
			CASE
				when b.product_Id = 1 THEN price * 20
				else price * 10
				end as points_1
				
			from MEMBERS a
			join SALES b
			on a.customer_id = b.customerid
			join MENU c 
			on b.product_Id = c.product_id
			
		)sq
		group by customerid, points_1
	)sq2

	group by customerid
	)
GO
/****** Object:  View [dbo].[wk1_q10]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[wk1_q10]
as
(
select customerid, sum(points)SUM_POINTS
from (
	select customerid, join_date,order_date,s.product_Id, DATEADD(day,6,join_date)valid_date,
	sum(case 
			when s.product_Id = 1 THEN 2 * 10 * price
			when order_date BETWEEN join_date AND DATEADD(day,6,m.join_date) THEN 2 * 10 * price
			else 10 * price
			end )as points
			from SALES s
	inner join MEMBERS m
	on s.customerid = m.customer_id
	inner join MENU mu
	on s.product_Id = mu.product_id
	where month(order_date) = 1
	group by customerid,join_date,s.product_Id,order_date,price
	

)sq
group by customerid
)
GO
/****** Object:  View [dbo].[wk1_q7b]    Script Date: 01/07/2022 15:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[wk1_q7b]
as

WITH prior_member_purchased_cte AS 
(
 SELECT s.customerid, m.join_date, s.order_date, s.product_Id,
         DENSE_RANK() OVER(PARTITION BY s.customerid
         ORDER BY s.order_date DESC) AS rank
 FROM SALES AS s
 JOIN MEMBERS AS m
  ON s.customerid = m.customer_id
 WHERE s.order_date < m.join_date
)
SELECT s.customerid, s.order_date, m2.product_name 
FROM prior_member_purchased_cte AS s
JOIN menu AS m2
 ON s.product_id = m2.product_id
WHERE rank = 1;
GO
