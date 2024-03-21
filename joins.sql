

-- https://www.interviewquery.com/questions/avg-friend-requests-by-age-group
SELECT 
    age_group,
       ROUND(COUNT(requester_id)/
             COUNT(DISTINCT user_id), 2) AS average_acceptance
FROM requests_accepted r 
RIGHT JOIN age_groups a 
    ON a.user_id = r.requester_id
GROUP BY age_group
ORDER BY average_acceptance DESC
    

SELECT 
    u.user_id, 
    ou.user_id as other_id,
    ou.name, 
    f.friend_id as jons_friend_id, 
    -- COUNT(DISTINCT f.friend_id) 
    FROM users u 
    JOIN users ou 
        ON u.user_id != ou.user_id 
    JOIN friends f 
        ON u.user_id = f.user_id
    Where u.user_id = 3 
-- group by 1,2,3
order by u.user_id, ou.user_id
    

-- https://www.interviewquery.com/questions/released-patients
-- Write a query to find all dates where the hospital released more patients than the day prior.
Select 
    td.release_date, 
    td.released_patients
    From released_patients td
    Join released_patients yd 
        on td.release_date = yd.release_date + 1 
        and td.released_patients > yd.released_patients 


-- https://leetcode.com/problems/rising-temperature/ 
SELECT 
    w1.id
FROM Weather w1, Weather w2
WHERE DATEDIFF(w1.recordDate, w2.recordDate) = 1 
AND w1.temperature > w2.temperature


-- Write a solution to report the name and bonus amount of each employee with a bonus less than 1000.
-- https://leetcode.com/problems/employee-bonus/
Select  
    e.name, 
    b.bonus 
    From Employee as e 
    Left Join Bonus as b 
        on e.empId = b.empId
    Where b.bonus < 1000 OR b.bonus is null ;


-- 570. Managers with at Least 5 Direct Reports (Leetcode)
Select 
    a.name
    From Employee a
    Join Employee b 
        on a.id = b.managerId
group by b.managerId
having count(distinct b.id) >= 5


-- https://leetcode.com/problems/average-selling-price/ 
Select 
    p.product_id, 
    IFNULL(ROUND(SUM(units * price)/SUM(units),2),0) as average_price
    From Prices p 
    left join UnitsSold s 
        on s.product_id = p.product_id
        and purchase_date >= start_date 
        and purchase_date <= end_date
group by 1


-- https://leetcode.com/problems/students-and-examinations/
-- good example of cross join 
WITH student_subjects as ( 
select 
    student_id, 
    student_name, 
    subject_name
    from Students s 
    cross join Subjects su 
) 
, cte2 as (
Select
    s.student_id, 
    student_name, 
    s.subject_name,
    count(e.subject_name) as attended_exams 
    From student_subjects s
    left join Examinations e 
        on s.student_id = e.student_id 
        and s.subject_name = e.subject_name 
group by 1,2,3 
)
Select 
    student_id, 
    student_name, 
    subject_name,    
    coalesce(attended_exams,0) as attended_exams
    From cte2
order by student_id, subject_name


-- https://leetcode.com/problems/confirmation-rate/?envType=study-plan-v2&envId=top-sql-50
select 
    s.user_id, 
    round(avg(if(c.action = 'confirmed', 1, 0)),2) as confirmation_rate
from Signups as s 
left join Confirmations as c 
on s.user_id= c.user_id 
group by user_id;


-- https://www.interviewquery.com/questions/notification-deliveries
SELECT 
    total_pushes, 
    COUNT(*) AS frequency
FROM (
    SELECT
         u.id, 
        COUNT(nd.notification) as total_pushes
    FROM users AS u
    LEFT JOIN notification_deliveries AS nd
        ON u.id = nd.user_id
            AND u.conversion_date >= nd.created_at
    WHERE u.conversion_date IS NOT NULL
    GROUP BY 1
) AS pushes
GROUP BY 1 


-- https://www.interviewquery.com/questions/cumulative-distribution
WITH hist AS (
    SELECT users.id, COUNT(c.user_id) AS frequency
    FROM users
    LEFT JOIN comments as c
        ON users.id = c.user_id
    GROUP BY 1
),

freq AS (
    SELECT frequency, COUNT(*) AS num_users
    FROM hist
    GROUP BY 1
)

SELECT 
    f1.frequency, 
    SUM(f2.num_users) AS cum_total
FROM freq AS f1
LEFT JOIN freq AS f2
    ON f1.frequency >= f2.frequency
GROUP BY 1


-- https://www.interviewquery.com/questions/employee-salaries 
select 
    d.name as department_name,
    count(distinct e.id) as number_of_employees,
    1. * count(distinct IF(e.salary > 100000, e.id, null)) / count(distinct e.id) as percentage_over_100k
    from employees e
    join departments d
        on e.department_id = d.id
group by d.name 
having count(distinct e.id) >= 10 
order by 3   
limit 3


-- https://www.interviewquery.com/questions/employee-salaries-etl-error 
SELECT e.first_name, e.last_name, e.salary
FROM employees AS e
INNER JOIN (
    SELECT first_name, last_name, MAX(id) AS max_id
    FROM employees
    GROUP BY 1,2
) AS m
    ON e.id = m.max_id


-- https://www.interviewquery.com/questions/average-commute-time
Select 
    a.commuter_id,
    a.avg_commuter_time, 
    b.avg_time
    From ( 
    SELECT 
        city,
        commuter_id,
        FLOOR(AVG(TIMESTAMPDIFF(MINUTE, start_dt, end_dt))) as avg_commuter_time
        FROM rides 
        Where city = 'NY'
    group by 1,2      
    )  a 
    LEFT JOIN (
    SELECT 
        city,
        FLOOR(AVG(TIMESTAMPDIFF(MINUTE, start_dt, end_dt))) as avg_time
        FROM rides 
        Where city = 'NY'
    group by 1    
    ) b 
    on a.city = b.city 


-- https://www.interviewquery.com/questions/cumulative-reset
WITH daily_total AS (
    SELECT 
        DATE(created_at) AS dt 
       , COUNT(*) AS cnt
    FROM users
    GROUP BY 1
)

SELECT
    t.dt AS date
    , SUM(u.cnt) AS monthly_cumulative
FROM daily_total AS t
LEFT JOIN daily_total AS u
    ON t.dt >= u.dt
        AND MONTH(t.dt) = MONTH(u.dt)
        AND YEAR(t.dt) = YEAR(u.dt)
GROUP BY 1

-- note this could alos be done with a window function 
WITH cte as ( 
select 
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    DATE(created_at) AS date,
    count(distinct id) as new_users 
    from users
group by 1,2,3
)     
Select 
    date, 
    sum(new_users) over(partition by year,month
                        order by date asc 
                        rows between unbounded preceding and current row) monthly_cumulative
    from cte


-- https://www.interviewquery.com/questions/department-expenses
WITH cte as ( 
SELECT 
    d.name as department_name, 
    coalesce(sum(amount),0) as total_expense
    FROM departments d 
    LEFT Join expenses e 
        on d.id = e.department_id 
        and year(e.date) = 2022 
group by 1         
) 

Select 
    department_name,
    total_expense, 
    round(avg(total_expense) over(),2) as average_expense
    from cte 
group by 1,2     
order by total_expense desc 



-- https://www.interviewquery.com/questions/rolling-bank-transactions
WITH cte as ( 
select  
    date(created_at) as dt, 
    sum(transaction_value) as transaction_value
    from bank_transactions
    Where transaction_value > 0 
group by 1     
) 

Select 
    b.dt,
    AVG(a.transaction_value) AS rolling_three_day
    From cte a
    Join cte b
       ON a.dt > DATE_ADD(b.dt, INTERVAL -3 DAY)
       AND a.dt <= b.dt
group by 1
order by 1


-- https://www.interviewquery.com/questions/rolling-average-steps
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


-- https://www.interviewquery.com/questions/paired-products
WITH purchases AS (
    SELECT  
       user_id
       , created_at
       , products.name 
FROM transactions 
JOIN products 
    ON transactions.product_id = products.id 
)
    
SELECT 
     t1.name AS p1
   , t2.name AS p2
   , count(*) as qty
FROM purchases AS t1 
JOIN purchases AS t2 
    ON t1.user_id = t2.user_id 
    AND t1.name < t2.name
    AND t1.created_at = t2.created_at
GROUP BY 1,2 
ORDER BY  3 DESC, 2 ASC
LIMIT 5


WITH cte as ( 
SELECT 
    * 
    , ou.*
    ou.name as potential_friend_name,
    COUNT(DISTINCT f.friend_id) * 3 as mutual_friends, 
    COUNT(DISTINCT l.page_id)   * 2  as page_likes
    FROM users 
    JOIN users ou 
        on u.user_id != ou.friend_id 
    JOIN friends f 
        ON u.user_id = f.user_id
        AND ou.user_id = f.user_id 
        AND ou.user_id != f.friend_id
    JOIN likes l 
        ON u.user_id = l.user_id
        AND ou.user_id = l.user_id 
    JOIN blocks b
        ON u.user_id = b.user_id
        AND ou.user_id != b.blocked_id
    Where u.user_id = 3 
group by ou.name 
) 
    
Select
    potential_friend_name, 
    SUM(mutual_friends + page_likes) as friendship_points
    from cte 
