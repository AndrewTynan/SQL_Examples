

https://blog.devops.dev/top-10-advanced-sql-queries-dd5717b7e902


FILTER 
https://docs.data.world/documentation/sql/concepts/intermediate/GROUP_BY.html
https://modern-sql.com/feature/filter

Select 
    COUNT(close_value) FILTER(WHERE close_value > 1000) AS `over 1000`
    FROM sales_pipeline


SELECT department,
       AVG(salary) FILTER (WHERE department = 'Sales') AS avg_salary_sales
FROM employees
GROUP BY department


# median without using median 
WITH ordered_income as (
    SELECT city,
           household_income,
           ROW_NUMBER() OVER (PARTITION BY city 
                                ORDER BY household_income) row_num_asc,
           ROW_NUMBER() OVER (PARTITION BY city 
                                ORDER BY household_income DESC) row_num_dsc
    FROM survey_responses
)
, mediancandidate AS (
    SELECT city,
           household_income
    FROM ordered_income
    WHERE row_num_asc = row_num_dsc 
        OR row_num_asc+1 = row_num_dsc 
        OR row_num_asc = row_num_dsc+1
)

SELECT  city,
        AVG(household_income) AS median_income
FROM mediancandidate
GROUP BY city


# https://www.interviewquery.com/questions/branch-sales-pivot
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


# Write a query to create a new table, named flight routes, that displays unique pairs of two locations.
# https://www.interviewquery.com/questions/flight-records
SELECT DISTINCT destination_one, destination_two
FROM
    (
            SELECT source_location as destination_one,
                destination_location as destination_two 
            FROM FLIGHTS
        UNION ALL
            SELECT destination_location, source_location
            FROM FLIGHTS
    ) a
WHERE destination_one <  destination_two    

#alternate solution 
WITH locations AS (
SELECT id,
        LEAST(source_location, destination_location) AS point_A,
        GREATEST(destination_location, source_location) AS point_B
    FROM flights
    ORDER BY 2,3 
)


SELECT point_A AS destination_one,
        point_B AS destination_two
FROM locations
GROUP BY point_A, point_B
ORDER BY point_A, point_B


#https://www.interviewquery.com/questions/generate-shopping-list-from-recipes
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


-- Finding Consecutive Events
-- Query: Identify consecutive order dates for the same product

WITH ConsecutiveOrders AS (
  SELECT product_id, order_date,
         LAG(order_date) OVER (PARTITION BY product_id ORDER BY order_date) AS prev_order_date
  FROM orders
)
SELECT product_id, order_date, prev_order_date
FROM ConsecutiveOrders
WHERE order_date - prev_order_date = 1;


-- Find Gaps in Sequential Data
-- Query: Identify missing order numbers in a sequence.

WITH Sequences AS (
  SELECT 
        MIN(order_number) AS start_seq, 
        MAX(order_number) AS end_seq
  FROM orders
) 

SELECT 
    start_seq + 1 AS missing_sequence
FROM Sequences
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.order_number = Sequences.start_seq + 1
)


-- gaps and islands 
-- https://www.interviewquery.com/questions/seven-day-streak
WITH grouped AS (
    SELECT 
        DATE(DATE_ADD(created_at, INTERVAL -ROW_NUMBER() 
            OVER (PARTITION BY user_id, URL ORDER BY created_at) DAY)) AS grp,
        user_id, 
        url,
        created_at 
    FROM (
        SELECT * 
        FROM events 
        GROUP BY created_at, url, user_id) dates
) 

SELECT 
    ROUND(1. * 
        COUNT(DISTINCT IF(streak_length >= 7, user_id, NULL)) / 
        COUNT(DISTINCT user_id) 
        ,2 ) AS percent_of_users
FROM (SELECT 
        user_id, url, COUNT(*) as streak_length
        FROM grouped
        GROUP BY user_id, url, grp
        ORDER BY COUNT(*) desc) c



gaps and islands 
https://www.interviewquery.com/questions/longest-streak-users
WITH grouped AS (
    SELECT 
        user_id, 
        DATE(created_at) as created_at,
        ROW_NUMBER() 
            OVER (PARTITION BY user_id ORDER BY created_at) as rn, 
        DATE(DATE_ADD(created_at, INTERVAL -ROW_NUMBER() 
            OVER (PARTITION BY user_id ORDER BY created_at) DAY)) AS grp        
    FROM (SELECT * 
            FROM events 
            -- Where user_id = 59
            GROUP BY created_at, user_id) dates
order by 1,4
)
SELECT 
    user_id, streak_length 
FROM (
    SELECT user_id, COUNT(*) as streak_length
    FROM grouped
    GROUP BY user_id, grp
    ORDER BY COUNT(*) desc) c
GROUP BY user_id
LIMIT 5




Total Conversation Threads
https://www.interviewquery.com/questions/total-conversation-threads
SELECT 
    COUNT(DISTINCT 
    LEAST(sender_id, receiver_id),
    GREATEST(sender_id, receiver_id)
    ) AS total_conv_threads
FROM messenger_sends



Calculate the total sales for each month of the current year, including months with zero sales.
WITH Months AS (
  SELECT 1 AS month_number UNION ALL
  SELECT 2 UNION ALL
  SELECT 3 UNION ALL
  SELECT 4 UNION ALL
  SELECT 5 UNION ALL
  SELECT 6 UNION ALL
  SELECT 7 UNION ALL
  SELECT 8 UNION ALL
  SELECT 9 UNION ALL
  SELECT 10 UNION ALL
  SELECT 11 UNION ALL
  SELECT 12
)

SELECT
  Months.month_number,
  COALESCE(SUM(s.sale_amount), 0) AS total_sales
FROM
  Months
LEFT JOIN
  (
    SELECT
      EXTRACT(MONTH FROM sale_date) AS month,
      sale_amount
    FROM
      sales
    WHERE
      EXTRACT(YEAR FROM sale_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  ) AS s
ON
  Months.month_number = s.month
GROUP BY
  Months.month_number
ORDER BY
  Months.month_number;



Temporary Functions

CREATE TEMPORARY FUNCTION get_seniority(tenure INT64) AS (
   CASE WHEN tenure < 1 THEN "analyst"
        WHEN tenure BETWEEN 1 and 3 THEN "associate"
        WHEN tenure BETWEEN 3 and 5 THEN "senior"
        WHEN tenure > 5 THEN "vp"
        ELSE "n/a"
   END
);
SELECT name
       , get_seniority(tenure) as seniority
FROM employees




Select 
    p1.project_id, 
    -- p1.employee_id, 
    date(p1.start_date) as start_date,
    date(p1.end_date) as end_date,  
    p2.project_id as p2_project_id,
    date(p2.start_date) as p2_start_date, 
    date(p2.end_date)   as p2_end_date
-- SUM( 
-- case when p1.end_date < p2.start_date then datediff(p1.end_date, p1.start_date) 
--      when p1.end_date >= p2.start_date and 
--           p1.end_date < p2.end_date then datediff(p2.end_date, p1.start_date)  
--      when p1.end_date >= p2.start_date and 
--           p1.end_date > p2.end_date then datediff(p1.end_date, p1.start_date)  
--      end)
--      days_worked,
--      p1.employee_id
    from projects p1
    join projects p2 
        on p1.employee_id = p2.employee_id
        and p1.project_id < p2.project_id
        and p1.start_date > p2.start_date
where p1.employee_id = 3        
-- group by 2 




https://www.interviewquery.com/questions/weighted-average-campaigns
A marketing team wants to compute a weighted average score to measure the effectiveness of their past email campaigns. They want the weight of the open rate to be 0.3, and the weight of the click rate to be 0.7.
Write a SQL query to calculate the weighted average for each campaign.
SELECT 
    campaign_name, 
    ((num_opens *  .3) + (num_clicks    * .7)) / num_users as weighted_avg
    FROM email_campaigns




https://www.interviewquery.com/questions/ctr-by-age
Given two tables, search_events and users, write a query to find the three age groups (bucketed by decade: age 0-9 falls into group 0, age 10-19 to group 1, …, 90-99 to group 9, with the endpoint included) with the highest clickthrough rate in 2021. If two or more groups have the same clickthrough rate, the older group should have priority.
Hint: If a user that clicked the link on 1/1/2021 is 29 years old on that day and has a birthday tomorrow on 2/1/2021, they fall into the [20-29] category. If the same user clicked on another link on 2/1/2021, he turned 30 and will fall into the [30-39] category.

SELECT 
    TIMESTAMPDIFF(year, date(birthdate), date(search_time)) DIV 10 as age_group,
    AVG(has_clicked) as ctr 
    FROM search_events s 
    join users u 
        on s.user_id = u.id 
    Where year(search_time) = 2021 
group by age_group   
order by 2 desc, 1      
limit 3 


