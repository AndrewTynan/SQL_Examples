   -- DATEDIFF(next_start_date, start_date) as position_tenure
   -- SUM(TIMESTAMPDIFF(MONTH, start_date, end_date))/COUNT(id) avg_tenure

WITH cte1 as (
SELECT 
    user_id, 
    title, 
    start_date, 
    lead(start_date,1) over(partition by user_id 
                            order by start_date) as next_start_date,
    -- IF condition makes sure the user's first position was not ds manager                            
    first_value(IF(title != 'data science manager', start_date, null)) over
         (partition by user_id
          order by start_date) as first_start_date
    FROM user_experiences 
    Where title IN ('data scientist', 'senior data scientist', 'data science manager') 
) 

, cte2 as (
Select    
    *, 
    min(IF(title = 'data science manager', start_date, null)) as first_ds_manager_start_date
    From cte1
group by 1,2,3,4,5
)

, cte3 as ( 
Select 
    *,
    TIMESTAMPDIFF(MONTH, start_date, next_start_date) as position_tenure,
    TIMESTAMPDIFF(MONTH, first_start_date, first_ds_manager_start_date) as months_to_ds_manager
    from cte2 
) 

, cte4 as ( 
Select 
    user_id, 
    min(months_to_ds_manager) as months_to_ds_manager, 
    MAX(IF(title ='data science manager','YES','NO')) ds_manager, 
    AVG(position_tenure) as avg_position_tenure, 
    COUNT(*) as position_count 
    From cte3
group by 1         
) 

SELECT 
    ds_manager, 
    round(avg(position_count),2)       as avg_position_count, 
    round(avg(avg_position_tenure),2)  as avg_avg_position_tenure, 
    round(avg(months_to_ds_manager),2) as avg_months_to_ds_manager
    FROM cte4 a
group by ds_manager 
