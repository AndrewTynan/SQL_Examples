/* https://www.interviewquery.com/questions/weighted-average-with-missing-dates */ 

/*The analytics team at a social media platform wants to analyze the short-term trends in daily user growth. 
For this task, they want you to calculate the 3-day rolling weighted average for new daily users, where the current day has a weight of 3, 
the previous day has a weight of 2, and the day before has a weight of 1.

The platform logs new records into the acquisitions table for the days on which new users arrive. Otherwise, it skips the date.
Write a SQL query to calculate the 3-day rolling weighted average for new daily users from the acquisitions table. */ 


WITH cte as ( 
SELECT 
    a1.date, 
    round(sum(
    case when datediff(a1.date, a2.date) = 0 then 3 * ifnull(a2.new_users,0)
         when datediff(a1.date, a2.date) = 1 then 2 * ifnull(a2.new_users,0)
         when datediff(a1.date, a2.date) = 2 then 1 * ifnull(a2.new_users,0)
         end) 
    / 6, 2) as weighted_average,
    RANK() OVER(ORDER BY a1.date) AS rnk
    FROM acquisitions a1 
    join acquisitions a2 
        on a2.date between date_sub(a1.date, interval 2 day) and a1.date 
group by 1 
) 
  
Select 
    date, weighted_average
    From cte 
where rnk > 2
order by 1
