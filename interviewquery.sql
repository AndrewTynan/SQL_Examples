
-- off-set union 
-- allows pivoting 
select
    branch_id,
    sum(21_sales) as total_sales_2021,
    sum(22_sales) as total_sales_2022
from(select
            branch_id,
            total_sales as 21_sales,
            0 as 22_sales
        from sales_2021
    union
        select
            branch_id,
            0 as 21_sales,
            total_sales as 22_sales
        from sales_2022
    ) as a
group by branch_id


-- self-join dates 
-- more compacct option than  window functions 
WITH cte AS (
    SELECT 
        a1.date,
        a1.new_users, 
        a2.new_users b2, 
        a3.new_users b3
        , ROUND((3*a1.new_users + 2*IFNULL(a2.new_users,0) + 1*IFNULL(a3.new_users,0))/6,2) AS weighted_average
        , RANK() OVER(ORDER BY a1.date) AS rnk
    FROM acquisitions a1
        LEFT JOIN acquisitions a2 ON a1.date = a2.date + 1
        LEFT JOIN acquisitions a3 ON a1.date = a3.date + 2
)
SELECT date, weighted_average
FROM cte
WHERE rnk > 2; -- this excluded the first two rows which had nulls, it was part of thte question 


-- repeat instances of something, in this case repeat purchasers 
Select count(user_id)
from
    (Select user_id
    From transaction
    Group by user_id
    Having count(distinct created_at) > 1 -- could change to count(distinct date(created_at)) to get those that respend on another date 
    ) as t1;


-- Audio Chat Success
-- https://www.interviewquery.com/questions/audio-chat-success 
WITH distinct_chats AS (
    SELECT 
        c.buyer_user_id 
        , c.seller_user_id
        , MAX(call_connected) AS at_least_one_call_connected
        , COUNT(DISTINCT mp.id) AS completed_transaction
        , SUM(call_connected) AS total_connected_calls        
    FROM chats AS c 
    LEFT JOIN marketplace_purchases AS mp  
        ON mp.buyer_user_id = c.buyer_user_id
            AND mp.seller_user_id = c.seller_user_id 
    GROUP BY 1,2
)
, base as ( 
SELECT 
      NULL as total_connected_calls  
    , at_least_one_call_connected
    , AVG(completed_transaction)
    , SUM(completed_transaction)
FROM distinct_chats 
GROUP BY 1,2 
) 
, multipl_calls as ( 
SELECT 
      total_connected_calls
    ,  NULL as at_least_one_call_connected
    , AVG(completed_transaction)
    , SUM(completed_transaction)
FROM distinct_chats 
GROUP BY 1,2 
) 

Select 
    * 
    from base 
union 
Select 
    * 
    From multipl_calls


-- Distanccec Traveled 
-- https://www.interviewquery.com/questions/distance-traveled
-- Ask if we need to report all rides, even if they didn't travel? 
-- Ask how to handle null distanec for riders who didn't travel? 
select 
    coalesce(sum(distance),0) as distance_traveled,
    name 
    from users u 
    left join rides r 
        on u.id = r.passenger_user_id 
group by name 
order by distance_traveled desc 


-- Weighted Average With Missing Dates
-- https://www.interviewquery.com/questions/weighted-average-with-missing-dates
WITH acquisitions_w_prior_dates_prep as ( 
SELECT 
    *, 
    lag(date, 1) over(order by date) as one_day_ago,
    lag(date, 2) over(order by date) as two_days_ago, 
    lag(new_users, 1) over(order by date) as one_day_ago_new_users,
    lag(new_users, 2) over(order by date) as two_days_ago_new_users
    FROM acquisitions
) 
, acquisitions_w_prior_dates as (
Select 
    date, 
    new_users,
    IF(DATEDIFF(date, one_day_ago) = 1, one_day_ago_new_users, null) as one_day_ago_new_users,
    IF(DATEDIFF(date, two_days_ago) = 2, two_days_ago_new_users, null) as two_days_ago_new_users 
    From acquisitions_w_prior_dates_prep
) 
, final as ( 
Select 
    date, 
    ROUND(
    ((new_users * 3) + 
    (one_day_ago_new_users * 2) + 
    (two_days_ago_new_users * 1))
    / 6
    ,2) 
     as weighted_average
    From acquisitions_w_prior_dates
) 
Select 
    *
    From final 
    Where weighted_average is not null 
order by date    


-- Branch Sales Pivot 
-- Notes: the union accounts for missing branches in either year table 
select
    branch_id,
    sum(21_sales) as total_sales_2021,
    sum(22_sales) as total_sales_2022
from
    (
        select
            branch_id,
            total_sales as 21_sales,
            0 as 22_sales
        from
            sales_2021
        union
        select
            branch_id,
            0 as 21_sales,
            total_sales as 22_sales
        from
            sales_2022
    ) as a
group by
    branch_id


-- Top 5 Turnover Risk
--bottom 5 is order by salary, since default order is ascending 
SELECT 
    emp.id as employee_id
FROM employees emp 
JOIN projects proj 
    ON emp.id = proj.employee_id
GROUP BY 1
HAVING COUNT(end_dt) >= 3
ORDER BY salary
LIMIT 5


-- groccery mass 
-- need to union all because of repeated values 
WITH  grocery_mass as ( 
select 
    grocery,
    mass
    from recipe1
union all  
select 
    grocery,
    mass    
    from recipe2
union all 
select 
    grocery,
    mass    
    from recipe3        
) 

Select 
    grocery,
    sum(mass) as total_mass
    From grocery_mass
group by 1 


-- duplicate rows 
WITH cte as (
select 
    *,
    count(*) over(partition by id,name,created_at) as row_count, 
    row_number() over(partition by id,name,created_at) as row_num
    from users
) 
Select 
    id,
    name,
    created_at
    From cte 
    Where row_count > 1 
    AND row_num = 2 


-- career jumping 
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
    position_count, 
    round(avg(avg_position_tenure),2)  as avg_avg_position_tenure, 
    round(avg(months_to_ds_manager),2) as avg_months_to_ds_manager
    FROM cte4 a
group by 1,2
order by 1,2



-- Rolling Average Steps
-- only include full trailing windows 
-- in this example, it's 3 rows 

-- one way to do it is with datediff, but this requires multiple cals 
WITH cte as ( 
SELECT 
    user_id,  
    date, 
    DATEDIFF(date, lag(date) over(partition by user_id 
                                  order by date )) yesterday_diff,
    DATEDIFF( date, lag(date,2) over(partition by user_id 
                                     order by date )) two_days_diff, 
    avg(steps) over(partition by user_id 
                    order by date 
                    rows between 2 preceding and current row) as avg_steps
    FROM daily_steps
) 
Select 
    user_id, 
    date, 
    avg_steps
    From cte     
    Where yesterday_diff = 1 
    AND two_days_diff = 2 


-- a cleaner way is to count the rows, in ths case the date 
WITH cte as ( 
SELECT 
    user_id,  
    date, 
    count(date) over(partition by user_id 
                    order by date 
                    rows between 2 preceding and current row) as date_count, 
    avg(steps) over(partition by user_id 
                    order by date 
                    rows between 2 preceding and current row) as avg_steps
    FROM daily_steps
) 
Select 
    user_id, 
    date, 
    avg_steps
    From cte     
    Where date_count = 3 
