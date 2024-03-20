/* https://www.interviewquery.com/questions/comments-histogram */ 

/* 
Write a SQL query to create a histogram of the number of comments per user in the month of January 2020.
Note: Assume bin buckets class intervals of one.
Note: Comments that were created outside of January 2020 should be counted in a “0” bucket
*/ 

WITH cte as (
SELECT 
    u.id as user_id, 
    count(c.user_id) as comment_count
    FROM users u 
    left join comments c 
        on u.id = c.user_id 
        and month(c.created_at) = 1 
        and year(c.created_at) = 2020
group by 1 
) 

Select 
    comment_count, 
    count(user_id) as frequency
    From cte 
group by 1 
order by 1 
