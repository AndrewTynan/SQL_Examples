

--Movie rental payment transactions table

Tablename: payment
   col_name   | col_type
--------------+--------------------------
 payment_id   | integer
 customer_id  | smallint
 staff_id     | smallint
 rental_id    | integer
 amount       | numeric
 payment_ts   | timestamp with time zone

--Sample results

 year | mon |   rev
------+-----+----------
 2020 |   1 |  123.45
 2020 |   2 |  234.56
 2020 |   3 |  345.67
 
 --1. Write a query to return the total movie rental revenue for each month.

Select 
	year(payment_ts) as year,
	month(payment_ts) as mon,
	sum(amount) as rev 
	From payment  
group by 1,2 


-- customer table 
 col_name   | col_type
-------------+--------------------------
 customer_id | integer
 store_id    | smallint
 first_name  | text
 last_name   | text
 email       | text
 address_id  | smallint
 activebool  | boolean
 create_date | date
 active      | integer

 --2. Write a query to return the first and last name of the customer who spent the most on movie rentals in Feb 2020. (assuming there could be ties in the ranking) 

--sample result 
 first_name,  last_name

with cte as ( 
Select 
	c.customer_id, 
	 c.first_name, 
	 c.last_name, 
	 sum(amount) as rev 	
	From payment p 
	join customer c 
		on p.customer_id = c.customer_id 
	Where year(payment_ts) = 2020
	And month(payment_ts) = 2 
group by 1,2,3 	
) 
, cte2 as ( 
Select 
	customer_id, 
	first_name, 
	last_name, 
	rev, 
	dense_rank() over(order by rev desc) as rk 
	From cte 
) 
Select 
	first_name, 
	last_name 
	From 
	Where rk = 1 


--3. Write a query to return the name of the customer who spent the second-highest for movie rentals in May 2020.


with cte as ( 
Select 
	c.customer_id, 
	 c.first_name, 
	 c.last_name, 
	 sum(amount) as rev 	
	From payment p 
	join customer c 
		on p.customer_id = c.customer_id 
	Where year(payment_ts) = 2020
	And month(payment_ts) = 5 
group by 1,2,3 	
) 
, cte2 as ( 
Select 
	customer_id, 
	first_name, 
	last_name, 
	rev, 
	dense_rank() over(order by rev desc) as rk 
	From cte 
) 
Select 
	first_name, 
	last_name 
	From 
	Where rk = 2  


--4. Write a query to count the number of customers who spend more than > $20 by month

--sample result
year	mon	num_hp_customers
2020	2	158
2020	5	520

WITH cte as ( 
Select 
	 customer_id, 
	 year(payment_ts) as year,
	 month(payment_ts) as mon,	 
	 sum(amount) as rev 	
	From payment 
group by 1,2,3 	
)

Select 
	year,
	mon,
	COUNT(DISTINCT case when rev > 20 then customer_id end) as num_hp_customers
	From cte
group by 1,2


-- Write a query to return the timeframe in a day that has the most rentals
with cte as ( 
Select 
	 hour(payment_ts) as hour,  
	 count(distinct payment_id)	payment_id_count
	From payment 
group by 1
) 
, cte2 as ( 
Select 
	case when hour between 8 and 12 then 'morning'
		 when hour between 13 and 17  then 'afternoon'
		 when hour between 18 and 23 then 'night'
		 else 'other'
		 end day_part, 
	sum(payment_id_count) as payments 
	from cte 
group by 1 
) 
, cte3 as ( 
Select 
	*,
	DENSE_RANK() over(order by payments desc) as rk 
	from cte2 
) 
Select 
	day_part
	From cte3 
	Where rk = 1 


# of customers who are never-active / inactive / active

with cte as ( 
Select 
	 c.customer_id, 
	 datediff('day', current_date, max(case when date(payment_ts) is null then current_date + 1 else date(payment_ts) end)) as days_since_payment 
	From customer c 
	left join payment p 
		on p.customer_id = c.customer_id 
group by 1
) 

Select 
	case when days_since_payment <= 30 then 'active'
		 when days_since_payment > 30 then 'inactive'
		 when days_since_payment < 0  then 'never-active'
		 end active_type, 
	count(distinct customer_id)	as customer_id_count
	from cte 
group by 1 



