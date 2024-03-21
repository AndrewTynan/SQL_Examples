/*  https://www.interviewquery.com/questions/seven-day-streak  */ 

/* Given a table with event logs, find the percentage of users that had at least one seven-day streak of visiting the same URL. */ 

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
        ORDER BY COUNT(*) desc
        ) c



