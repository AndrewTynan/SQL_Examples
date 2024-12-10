

https://www.interviewquery.com/questions/cumulative-distribution
Given the two tables, write a SQL query that creates a cumulative distribution of the number of comments per user. Assume bin buckets class intervals of one.
WITH cte as ( 
SELECT 
    u.id, 
    coalesce(count(c.created_at),0) as comments 
    FROM users u 
    LEFT JOIN comments c 
        on u.id = c.user_id 
group by 1 
) 

, cte2 as ( 
Select 
    comments as frequency, 
    count(id) as user_count
    From cte 
group by 1
) 

Select 
    sum(user_count) over(order by frequency) as cum_total,
        frequency
    From cte2 



https://www.interviewquery.com/questions/weighted-average-sales
The sales department is conducting a performance review and is interested in trends in product sales. They have decided to use a weighted moving average as part of their analysis.
Write a SQL query to calculate the 3-day weighted moving average of sales for each product. Use the weights 0.5 for the current day, 0.3 for the previous day, and 0.2 for the day before that.
Note: Only output the weighted moving average for dates that have two or more preceding dates. You may assume that the table doesn’t skip dates.

with cte as (
    SELECT * ,
    lag(sales_volume,1) over( partition by product_id 
                             order by date) as pre_1_day,
    lag(sales_volume,2) over( partition by product_id 
                                order by date) as pre_2_day
FROM sales
)
select 
    date,
    product_id,
    (0.5 * sales_volume + 
     0.3 * pre_1_day +
     0.2 * pre_2_day) weighted_avg_sales 
     from cte
where pre_1_day is not null 
and pre_2_day is not null



https://www.interviewquery.com/questions/average-commute-time
Let’s say you work at Uber. The rides table contains information about the trips of Uber users across America
Write a query to get the average commute time (in minutes) for each commuter in New York (NY) and the average commute time (in minutes) across all commuters in New York.
SELECT  
    distinct 
    commuter_id, 
    floor(avg(TIMESTAMPDIFF(MINUTE, start_dt, end_dt)) over(partition by commuter_id)) as avg_commuter_time,
    floor(avg(TIMESTAMPDIFF(MINUTE, start_dt, end_dt)) over()) as avg_time
    FROM rides 
    WHERE city = 'NY' 



https://leetcode.com/problems/biggest-single-number/
WITH cte as ( 
Select 
    num, 
    count(*) over (partition by num) as num_cnt
    From MyNumbers
) 

Select 
    max(num) as num
    From cte 
    Where num_cnt = 1 


Calculate the running total of sales for each day within the past month.
SELECT
  sale_date,
  SUM(sale_amount) OVER (ORDER BY sale_date) AS running_total
FROM sales
WHERE sale_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
  AND sale_date <= CURRENT_DATE
ORDER BY sale_date 


https://leetcode.com/problems/immediate-food-delivery-ii/
with cte as ( 
Select 
    customer_id, 
    order_date, 
    customer_pref_delivery_date, 
    min(order_date) over(partition by customer_id) as min_order_date
    From Delivery 
) 

Select 
     ROUND(100. * AVG(IF(min_order_date = customer_pref_delivery_date, 1,0)),2) AS immediate_percentage
    from cte 
    Where order_date = min_order_date


https://leetcode.com/problems/restaurant-growth/submissions/ 
WITH cte as ( 
Select 
    visited_on, 
    sum(amount) as amount
    From Customer 
group by 1 
) 

, cte2 as (
Select 
    visited_on, 
    row_number() over(order by visited_on) as row_num, 
    SUM(amount) over(order by visited_on
                     rows between 6 preceding and current row) as amount,
    ROUND(avg(amount) over(order by visited_on
                           rows between 6 preceding and current row),2) as average_amount 
    From cte 
) 

Select 
    visited_on, 
    amount,
    average_amount
    From cte2
    WHERE row_num >= 7
order by visited_on  


https://www.interviewquery.com/questions/rolling-average-steps
https://learnsql.com/blog/range-clause/
Write a SQL query to calculate the 3-day rolling average of steps for each user, rounded to the nearest whole number.
WITH cte as ( 
SELECT 
    user_id,
    date,
    avg(steps) over(partition by user_id
                        order by date
                        range between INTERVAL '2' DAY preceding and current row) as avg_steps,
    count(date) over(partition by user_id
                        order by date
                        range between INTERVAL '2' DAY preceding and current row) as counts                        
    FROM daily_steps  
) 
Select 
    user_id,
    date,
    round(avg_steps) as avg_steps
    From cte 
    Where counts = 3 


585. Investments in 2016 (from Leetcode)
Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:
have the same tiv_2015 value as one or more other policyholders, and
are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
WITH cte as ( 
Select 
    pid,
    tiv_2015, 
    tiv_2016,
    concat(lat,lon) as lat_lon, 
    count(*) over(partition by tiv_2015) as tiv_2015_count,
    count(*) over(partition by lat,lon) as lat_lon_count
    From Insurance 
Group by 1,2,3
) 

Select 
    round(sum(tiv_2016),2) as tiv_2016
    From cte
    Where tiv_2015_count > 1 
    and lat_lon_count = 1


# https://leetcode.com/problems/product-sales-analysis-iii/
WITH cte as ( 
Select 
    product_id, 
    year, 
    min(year) over(partition by product_id) as first_year,
    quantity, 
    price 
    From Sales 
) 

Select 
    product_id, 
    first_year,
    quantity, 
    price
    from cte 
    where year = first_year 


/*  January 31's rolling 3 day average of total transaction amount processed per day */
WITH transaction_date_prep_cte AS ( 
SELECT 
    transaction_time AS transaction_time, 
    date(transaction_time) AS transaction_date,
    transaction_amount AS transaction_amount
    FROM transactions
 ) 

, transaction_date_cte as ( 
SELECT 
    transaction_date, 
    SUM(transaction_amount) AS daily_transaction_amount
    FROM transaction_date_prep_cte
GROUP BY 1 
) 

SELECT 
    *, 
    ROUND(
      avg(daily_transaction_amount) 
        OVER(ORDER BY transaction_date
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as rolling_3_day_avg
    FROM transaction_date_cte
ORDER BY transaction_date      



-- Question 2: How many members moved directly from Microsoft to Google? (Member 2 does not count since Microsoft -> Oracle -> Google)
Select 
    count(distinct Member_id) as count 
    from (Select 
                Member_id,
                Company,
                Year_Start,
                lag(Company, 1) over(partition by Member_id Order by Year_Start) as previous_company,
                lag(Member_id, 1) over(partition by Member_id Order by Year_Start) as previous_Member_id
            From employee_info 
          ) a 
   Where Company = 'Google' 
   And previous_company = 'Microsoft'
   and Member_id = previous_Member_id   


# Repeat Purchases on Multiple Days
WITH purchases_plus as ( 
SELECT 
      * 
    , extract(HOUR FROM last_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) first_purchase_hour 
    , extract(HOUR FROM first_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) last_purchase_hour 
    , lead(quantity) OVER (PARTITION BY user_id
                           ORDER BY purchase_date) as next_quantity 
    , row_number() OVER (PARTITION BY user_id 
                         ORDER BY user_id) user_row_num 
    , dense_rank() OVER (ORDER BY user_id) user_row_num        
    FROM purchases
ORDER BY user_id, purchase_date
) 

, mini_tbl as ( 
Select 
      user_id 
    , product_id 
    , quantity
    From purchases_plus
) 

Select 
      user_id 
    , row_count      
    , count(*) as user_row_count
    from (Select 
              * 
             , count(*) over() as row_count
             From purchases
          ) a 
GROUP BY 1,2 



# top 3 highest paid employees in each dept 
Select 
      d.name as Department 
    , e.name as Employee
    , e.salary as Salary
    from Employee e
    left join (Select
                      DepartmentId
                    , salary
                    , rank() over(partition by DepartmentId
                                  order by Salary) salary_rank 
                    FROM Employee e 
                ) r 
                on e.DepartmentId = r.DepartmentId 
                and e.salary = r.salary
    left join Department d 
        on e.DepartmentId = d.id           
    Where r.salary_rank >= 3    



# for each product cateogry, which product is the most expensive? Output the category, product name and price 
# Only return one item per category even if the prices could be the same for multiple products. 
# Notes: 
# using row_number() to get only one rank
Select 
      category,
      product_name, 
      price
    From (Select 
                category,
                product_name, 
                price, 
                row_number() over(partition by cateogry order by price desc) cateogry_price_rank
            From 
      )
    Where cateogry_price_rank = 1 


# 176. Second Highest Salary
# https://leetcode.com/problems/second-highest-salary/
WITH cte as ( 
Select 
    id,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC)  AS salary_rnk
    From Employee
)

Select 
    IF(max(salary_rnk) >=2, salary, null) as SecondHighestSalary
    From cte 
    WHERE salary_rnk = 2    


# https://leetcode.com/problems/consecutive-numbers/
with cte as ( 
Select 
    id, 
    num, 
    lag(num) over() prior_num,
    lag(num,2) over() two_prior_num
    from logs
) 

Select 
    num as ConsecutiveNums
    from cte 
    Where prior_num = num
    and two_prior_num = num
group by 1   


# https://leetcode.com/problems/game-play-analysis-iv/ 
WITH cte as ( 
Select 
    player_id, 
    event_date, 
    min(event_date)    over(partition by player_id) as first_login_date, 
    lead(event_date,1) over(partition by player_id
                            order by     event_date) as next_login_date
    From activity
) 

Select 
    ROUND(
    1. * COUNT(DISTINCT IF(event_date = first_login_date AND datediff(next_login_date, event_date) = 1, player_id, null)) /
         COUNT(DISTINCT player_id)
         ,2
        ) AS fraction
    From cte 


# Select top 10 records for each category
SELECT rs.Field1,rs.Field2 
    FROM (
        SELECT 
             Field1,Field2, 
             Rank() over (Partition BY Section 
                            ORDER BY RankCriteria DESC ) AS Rank
        FROM table
        ) rs WHERE Rank <= 10


# from top 3.sql
Select  Master_Ttl_Name, 
    max( case when ranks = 1 then Reporting_Region else null end )  item_ID_1,
    max( case when ranks = 1 then ASP else null end )  ASP_1,
    max( case when ranks = 2 then Reporting_Region else null  end )  item_ID_2,
    max( case when ranks = 2 then ASP else null end )  ASP_2,   
    max( case when ranks = 3 then Reporting_Region else null end ) item_ID_3, 
    max( case when ranks = 3 then ASP else null end )  ASP_3,     
    max( case when ranks = 4 then Reporting_Region else null  end )  item_ID_4,   
    max( case when ranks = 4 then ASP else null  end )  ASP_4
    From 
    (
    select a.*, rank() over (partition by Reporting_Region order by ASP DESC) as ranks
           from 
              (
              Select Reporting_Region, Master_Ttl_Name, (sum( Gross_Bookings) / sum( Units) ) as ASP 
                from AJT_test
              Group By 1,2 
              ) a 
      ) b 
Group By 1    



# https://leetcode.com/problems/investments-in-2016/
WITH cte as ( 
Select 
    pid,
    tiv_2015, 
    tiv_2016,
    concat(lat,lon) as lat_lon, 
    count(*) over(partition by tiv_2015) as tiv_2015_count,
    count(*) over(partition by lat,lon) as lat_lon_count
    From Insurance 
Group by 1,2,3
) 

Select 
    round(sum(tiv_2016),2) as tiv_2016
    From cte
    Where tiv_2015_count > 1 
    and lat_lon_count = 1


# https://leetcode.com/problems/exchange-seats/
SELECT id, 
       CASE 
         WHEN mod(id, 2) = 1 AND lead(id) OVER(ORDER BY id) IS NOT NULL THEN lead(student) OVER(ORDER BY id)
         WHEN mod(id, 2) = 0 THEN lag(student) OVER(ORDER BY id)
         ELSE student
       END AS student
FROM seat
ORDER BY id;


# https://www.interviewquery.com/questions/weighted-average-sales
with 3d as (
    SELECT * ,
    lag(sales_volume,1) over( partition by product_id 
                             order by date) as pre_1_day,
    lag(sales_volume,2) over( partition by product_id 
                                order by date) as pre_2_day
FROM sales)
select 
    date,
    product_id,
    (0.5 * sales_volume + 
     0.3 * pre_1_day +
     0.2 * pre_2_day) weighted_avg_sales 
     from 3d
where pre_1_day is not null 
and pre_2_day is not null


# https://www.interviewquery.com/questions/upsell-transactions
WITH cte as (
select 
    *,
    row_number() over(partition by user_id
                     order by created_at) as user_order_number,
    row_number() over(partition by user_id,created_at) as user_intra_day_order_number
    from transactions
order by    user_id,  created_at
) 
Select 
    COUNT(DISTINCT user_id ) as num_of_upsold_customers
    from cte 
    Where user_order_number >= 2 
    AND user_intra_day_order_number = 1 


# https://www.interviewquery.com/questions/duplicate-rows 
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


# https://www.interviewquery.com/questions/closest-sat-scores
WITH cte as (
select 
    student as student, 
    lag(student,1) over(order by score) as other_student, 
    ABS(score - lag(score,1) over(order by score)) as score_diff
    from scores
order by score   
) 

select
    CASE WHEN student<other_student THEN student ELSE other_student END AS one_student,
    CASE WHEN student>other_student THEN student ELSE other_student END AS other_student,
    score_diff
    from cte 
    Where other_student is not null 
ORDER BY 3 ASC, 1 ASC
LIMIT 1




https://www.interviewquery.com/questions/third-unique-song
WITH 
CTE_ds AS 
(
SELECT ROW_NUMBER()  OVER (PARTITION BY user_id, song_name 
                            ORDER BY date_played) br, 
    song_plays.*
from song_plays 
)
,CTE_ds2 AS 
(
SELECT ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date_played) br2,
    CTE_ds.* x
    FROM CTE_ds 
    WHERE br =1
)
SELECT 
    x.name,y.date_played,song_name 
FROM users x
LEFT JOIN 
(SELECT user_id, date_played,song_name 
    FROM CTE_ds2  WHERE br2 = 3) y 
    ON id  = user_id



