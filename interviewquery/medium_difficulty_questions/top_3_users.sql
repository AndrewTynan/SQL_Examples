/* https://www.interviewquery.com/questions/top-3-users */ 

/* 
Let’s say you work at a file-hosting website. You have information on user’s daily downloads in the download_facts table
Use the window function RANK to display the top three users by downloads each day. Order your data by date, and then by daily_rank
*/ 

WITH cte as ( 
select 
    *, 
    rank() over(partition by date
                order by downloads desc) as daily_rank
    from download_facts
) 

Select 
    daily_rank,
    date,
    downloads,    
    user_id 
    From cte 
    Where daily_rank <= 3 
order by date, daily_rank
