/* https://www.interviewquery.com/questions/closed-accounts */ 

/* Given a table of account statuses, write a query to get the percentage of accounts that were active on December 31st, 2019, and closed on January 1st, 2020, 
over the total number of accounts that were active on December 31st. Each account has only one daily record indicating its status at the end of the day. */

WITH cte as ( 
select 
    account_id,
    date, 
    status, 
    lead(status) over(partition by account_id
                      order by date) as next_status
    from account_status
) 

Select 
    ROUND(1. * 
         COUNT(DISTINCT IF(next_status  LIKE '%closed%', account_id, null)) /
         COUNT(DISTINCT IF(status       LIKE '%open%', account_id, null)) 
        ,2) as percentage_closed
    from cte 
    Where date(date) = '2019-12-31'
    AND status       LIKE '%open%'
