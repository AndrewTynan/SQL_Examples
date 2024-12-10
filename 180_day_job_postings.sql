
WITH cte as ( 
SELECT 
    a.job_id,
    a.user_id,
    date(a.date_posted) as date_posted, 
    min(date(b.date_posted)) first_date_posted
    FROM job_postings a 
    LEFT JOIN job_postings b
        on a.job_id = b.job_id 
        and a.date_posted <= b.date_posted
group by 1,2,3         
) 
, cte2 as ( 
Select
    *, 
    DATEDIFF('2022-01-01', date_posted) as days_since_post,
    DATEDIFF('2022-01-01', first_date_posted) as days_since_first_post
    from cte 
) 
, cte3 as ( 
Select 
    *,
    IF(date_posted != first_date_posted, 'YES', 'NO') as existing_job_id, 
    IF(date_posted != first_date_posted, 
        days_since_first_post,
        days_since_post
        ) as total_job_id_days 
    from cte2
) 
Select 
    user_id, 
    SUM(IF(existing_job_id ='YES', total_job_id_days, null)) total_job_id_days,
    COUNT(IF(date_posted < DATE_ADD('2022-01-01', INTERVAL -180 DAY),
            job_id,null)
        ) as job_posts_before_180_days_ago 
    from cte3 

    



WITH posts_job AS (SELECT
    *
FROM job_postings
WHERE (DATEDIFF('2022-01-01', date_posted) > 180)
)

,jobs_difference_days AS (
SELECT
    *,
    DATEDIFF('2022-01-01', date_posted) AS diferenca_dias
FROM job_postings
)

,jobs_same_id AS (
SELECT
    jdd.job_id,
    jdd.user_id,
    jdd.date_posted,
    SUM(jdd_b.diferenca_dias)OVER(PARTITION BY 
        jdd_b.job_id) AS diferenca_cumulativa_dias
FROM jobs_difference_days jdd
JOIN jobs_difference_days jdd_b
ON jdd.job_id = jdd_b.job_id
WHERE (jdd.date_posted <= jdd_b.date_posted)
)

,jobs_more_180_days AS (
SELECT
    *
FROM jobs_same_id 
WHERE diferenca_cumulativa_dias > 180)

,users_id AS (
SELECT
    user_id
FROM jobs_more_180_days
UNION
SELECT
    user_id
FROM posts_job
)

SELECT
    COUNT(DISTINCT ui.user_id) /
    COUNT(DISTINCT jp.user_id) AS percentage
FROM job_postings jp
LEFT JOIN users_id ui
ON ui.user_id = jp.user_id;