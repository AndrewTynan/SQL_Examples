
question 1 

with cte as ( 
Select 
	customer_id, 
	month(order_place_time) as month,
	year(order_place_time) as year,
	count(distinct delivery_id) as delivery_count 
	From delivery_orders 
group by 1,2,3 
) 

select 
	year,
	month,
	1. * count(distinct case when delivery_count <= 20 then customer_id end) / count(distinct customer_id) as perc_infrequent 
	from cte 
group by 1,2 
order by 1,2 


question 2 

with cte as ( 
Select 
	customer_id, 
	month(order_place_time) as month,
	year(order_place_time) as year,
	count(distinct delivery_id) as delivery_count 
	From delivery_orders 
group by 1,2,3 
) 

, cte_2 as ( 
Select 
	customer_id, 
	month,
	year,
	delivery_count 
	rank() over(partition by year, month 
				order by delivery_count desc) delivery_count_rank 
	from cte 
	where delivery_count > 20 
) 


Select 
	year,	
	month,
	customer_id, 	
	delivery_count 
	from cte_2 
	where delivery_count_rank = 1 
order by year, month 


 question 3 


with cte as ( 
Select 
	customer_id, 
	month(order_place_time) as month,
	year(order_place_time) as year,
	count(distinct delivery_id) as delivery_count 
	From delivery_orders 
group by 1,2,3 
) 

, cte_2 as ( 
Select 
	customer_id, 
	month,
	year,
	delivery_count 
	rank() over(partition by year, month 
				order by delivery_count desc) delivery_count_rank 
	from cte 
	where delivery_count > 20 
) 

, cte_3 as ( 
Select 
	year,	
	month,
	customer_id, 	
	delivery_count 
	from cte_2 
	where delivery_count_rank = 1 
order by year, month 
) 

, cte_4 as ( 
Select 
	a.year,	
	a.month,
	a.customer_id, 	
	a.delivery_count, 
	b.restaurant_id,
	count(*) as restaurant_id_orders

	from cte_3 a 
	left join delivery_orders b 
		on a.customer_id = b.customer_id 
		and a.year = year(b.order_place_time) 
		and a.month = month(b.order_place_time)
group by 1,2,3,4,5 
) 

, cte_5 as ( 
Select 
	*, 
	rank() over(partition by year, month, customer_id
				order by restaurant_id_orders desc ) as restaurant_id_orders_rank 
	from cte_4

) 

Select 
	* 
	From 
	where restaurant_id_orders_rank <= 3 










