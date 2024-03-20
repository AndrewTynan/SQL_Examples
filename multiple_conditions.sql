


https://www.interviewquery.com/questions/feed-impression
WITH cte as ( 
select 
    l.user_id, 
    action_type, 
    datediff(date(action_date), date(created_at)) as days_since_created
    from event_log l 
    join pins p 
        on l.pin_id = p.pin_id
) 
, cte2 as ( 
Select 
user_id, 
max(IF(action_type = 'View' and days_since_created <= 7, 1, NULL)) as is_viewer,
max(IF(action_type = 'Engagement',1,0)) as is_engager
from cte 
group by 1 
) 
Select 
    1. * 
    COUNT(DISTINCT IF(is_viewer = 1 AND is_engager = 1, user_id, NULL)) /  
    COUNT(DISTINCT user_id) 
    as percent_of_users
    from cte2   


    