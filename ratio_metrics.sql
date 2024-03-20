
# usually the numerator and denominator are counts from the same table 

# get percent of premium subscribers 

# method 1: scaler sub-query for denominator
SELECT 
	1. * COUNT(user_id) / (SELECT COUNT(user_id) FROM subscription) AS premium_subscriber_percent
	From subscription
	Where premium = True 


# method 2: CASE WHEN to create numerator
SELECT 
	
	1. * SUM(CASE WHEN premium = True THEN 1 END) / COUNT(user_id) AS premium_subscriber_percent
	From subscription


# method 3: AVG w/ CASE WHEN 
# note this only works when the denominator is the total count 
# need to have the ELSE 0
# need to make the values decimals to avoid integer division
SELECT 	
	AVG(CASE WHEN premium = True THEN 1.0 ELSE 0.0 END) AS premium_subscriber_percent
	From subscription
	

# return the percent of users who placed their first order as an immediate order.
# method 1: using with 
WITH first_order as ( 
	Select 
		customer_id 
		from delivery 
		Group By customer_id 
		Having min(order_date) = MIN(pref_delivery_date)
	)

Select 
	count(customer_id) * 1.0 / (select count(distinct customer_id) FROM delivery) as immeidate_percent
	From first_order


# method 2 using cte 
WITH ordered_delivery as ( 
Select 
	*, 
	row_number() over(partition by customer_id order by order_date) as order_rank
	From delivery 
)

Select 
	AVG(CASE WHEN order_date = pref_delivery_date then 1.0 ELSE 0.0 END) AS immeidate_percent
	From ordered_delivery
	Where order_rank = 1 






