

--origin cumulative revenue LTD
select order_date, sum(revenue) over (order by order_date rows unbounded preceding) cumulative_revenue
	from 
	(select order_date, sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2011-06-01' and current_date
	group by 1
	) a 
	

--using window functions to get the first and last active dates
--many aggregate functions like min and max are using the window fucntions and partitioning in the background
select * 
from
(select distinct user_account_id, event_date, 
		first_value(event_date) over (partition by user_account_id order by event_date desc rows between unbounded preceding and unbounded following) as first_active,
		last_value(event_date) over (partition by user_account_id order by event_date desc rows between unbounded preceding and unbounded following) as last_active
	from  
	(select distinct user_account_id, event_date
		from ORIGIN_PUB.ORIGIN_ACTIVITY 
	) a 
) b
where User_Account_Id = '1000092576586'
order by 2
	

	
--cumulative sum of revenue and units
select order_date, region_name, sum(revenue) over (partition by region_name order by order_date rows unbounded preceding) cumulative_revenue,
		sum(units) over (partition by region_name order by order_date rows unbounded preceding) cumulative_units
	from 
	(select order_date, region_name, sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1,2
	) a 
	
	
--produces errors 	
--cumulative sum of revenue and units
--built in function csum
select order_date, csum(revenue, order_date) cumulative_revenue
	from 
	(select order_date,sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1
	) a 

	
--rank by region of each days revenue
select order_date, region_name, revenue, dense_rank() over (partition by region_name order by revenue desc) as revenue_rank 
	from 
	(select order_date, region_name, sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1,2
	) a 


--rank by day each regions revenue
select order_date, region_name, revenue, dense_rank() over (partition by order_date order by revenue desc) as revenue_rank 
	from 
	(select order_date, region_name, sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1,2
	) a 
	
	
--rank by day each regions revenue
select order_date, region_name, revenue, 
		first_value(revenue) over (partition by region_name order by revenue desc
									rows between unbounded preceding and unbounded following) as top_revenue,
		last_value(revenue) over (partition by region_name order by revenue desc
									rows between unbounded preceding and unbounded following) as bottom_revenue
	from  
	(select order_date, region_name, sum(Revenue_Amt) revenue, sum(units) units
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1,2
	) a 



--new spenders, existing spenders and overall spenders by year 
SELECT  order_year, 
		SUM(flag) AS new_spenders,
  		COUNT(*) AS distinct_spenders, 
  		(distinct_spenders - new_spenders) existing_spenders,
		SUM(SUM(flag)) OVER (ORDER BY order_year ROWS UNBOUNDED PRECEDING) AS cumulative_spenders 
FROM
 	(
	  SELECT 
	  distinct 
	  user_account_id, 
	  EXTRACT(YEAR FROM order_date) AS order_year,
		CASE  -- get the first year when a user placed an order
	         WHEN EXTRACT(YEAR FROM order_date) = MIN(EXTRACT(YEAR FROM order_date)) OVER (PARTITION BY user_account_id) THEN 1 
	         	ELSE 0 
	      			END flag
			from ORIGIN_PUB.ORIGIN_REVENUE o
	   	GROUP BY order_year,user_account_id
	 	) a 
GROUP BY 1	


--ntiles 
select region_name, revenue, (RANK() OVER (ORDER BY revenue) - 1) * 10 / COUNT(*) OVER()  --quantile(10, revenue)
	from 
	(select region_name, sum(Revenue_Amt) revenue
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1
	) a 
group by 1,2


--moving average
select region_name, order_date, revenue, average(revenue) over(partition by region_name order by order_date rows 5 preceding)
	from 
	(select region_name, order_date, sum(Revenue_Amt) revenue
		from ORIGIN_PUB.ORIGIN_REVENUE o
		join EADW_CORE_PUB.OFFER_ITEM_DIM d 
			on d.Edw_Offer_Item_Id = o.Edw_Offer_Item_Id
		join ORIGIN_PUB.ORIGIN_GEOGRAPHY g 
			on g.Country_Code = o.Country_Code
		where Valid_Order_Flag = 'Y'
		and o.Order_Date between '2015-03-01' and current_date
	group by 1,2
	) a 
group by 1,2,3



--improvement would be to adjust for lifetime lenght 

--Origin LTD top 1% spenders
	--filter the top percentiles
select revenue_percentile, count(distinct user_account_id), sum(cumulative_revenue) 
	from --get the percentiles 
		(select user_account_id, cumulative_revenue, (RANK() OVER (ORDER BY cumulative_revenue) - 1) * 100 / COUNT(*) OVER() as revenue_percentile
			from
			(select user_account_id, max(cumulative_revenue) cumulative_revenue	
				from --cumulative sum LTD spend 
					(select distinct user_account_id, order_date, sum(Revenue_Amt) over (partition by user_account_id order by order_date rows unbounded preceding) cumulative_revenue
						from ORIGIN_PUB.ORIGIN_REVENUE
							where Valid_Order_Flag = 'Y'
							and Order_Date between '2011-06-01' and current_date
					) a 
			group by 1 		
			) b 
		) c 
group by 1
order by 1 desc






	