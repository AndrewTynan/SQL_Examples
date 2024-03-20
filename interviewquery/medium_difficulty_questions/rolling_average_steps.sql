/* https://www.interviewquery.com/questions/rolling-average-steps */ 

/* 
As a data analyst in a fitness app company, you are tasked with analyzing the user’s daily step count.
Write a SQL query to calculate the 3-day rolling average of steps for each user, rounded to the nearest whole number.
Notes: The rolling average should only be calculated for days where there are 3 previous days of step counts, including the current day. 
The first 2 days for any user should be excluded.
*/ 

SELECT 
    d1.user_id,
    d1.date,
    round(avg(d2.steps)) as avg_steps
    FROM daily_steps d1 
    JOIN daily_steps d2 
        ON  d1.user_id = d2.user_id
        AND d2.date between date_sub(d1.date, interval 2 day) and d1.date
group by 1,2
having count(d2.date) = 3 

-- Alternate solution using window functions with RANGE

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
