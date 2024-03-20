
-- TOP N 
select * from table order by Num descc limit 25

    
-- 4 to 9 rows 
SELECT 
    employee_id, first_name, last_name
FROM
    employees
ORDER BY first_name
LIMIT 5 OFFSET 3;


-- top 1 
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary
FROM employees
ORDER BY 
    salary DESC
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;


-- second highest 
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary
FROM
    employees
ORDER BY 
  salary DESC
LIMIT 1 OFFSET 1;


/* if there are 2 or more ppl with the second highest salary 
use a subquery to get the salary that is second highest and fillter on it */ 

SELECT 
    employee_id, first_name, last_name, salary
FROM
    employees
WHERE
    salary = (SELECT DISTINCT
            salary
        FROM
            employees
        ORDER BY salary DESC
        LIMIT 1 , 1);


/* /https://www.interviewquery.com/questions/top-5-turnover-risk
Given two tables, employees and projects, find the five lowest-paid employees who have completed at least three projects */ 

SELECT 
    emp.id as employee_id
FROM employees emp 
JOIN projects proj 
    ON emp.id = proj.employee_id
GROUP BY 1
HAVING COUNT(end_dt) >= 3
ORDER BY salary
LIMIT 5


-- List the departments where the average salary is higher than the company’s overall average salary.
SELECT department
FROM employees
GROUP BY department
HAVING AVG(salary) > (
  SELECT AVG(salary)
  FROM employees)


-- Correlated Subquery
SELECT product_name, product_price
FROM products p
WHERE product_price > (SELECT AVG(product_price) 
                            FROM products 
                            WHERE p.category_id = category_id)


/* List the products that have been sold in all cities where the company operates.
In essence, this query finds products that do not have a single city where they have not been sold. 
These are the products that have been sold in all  cities where the company operates. */ 

SELECT p.product_name
FROM products p
WHERE NOT EXISTS (
  SELECT c.city_name
  FROM cities c
  WHERE NOT EXISTS (
    SELECT s.product_id
    FROM sales s
    WHERE s.product_id = p.product_id
    AND s.city_id = c.city_id
  )
)

 -- Find customers who have made a purchase every month for the last six months
SELECT customer_id
FROM purchases
WHERE purchase_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY customer_id
HAVING COUNT(DISTINCT EXTRACT(YEAR_MONTH FROM purchase_date)) = 6;


-- Retrieve the top 10 customers who have spent the most on their single purchase.
SELECT
  customer_id,
  MAX(purchase_amount) AS max_purchase_amount
FROM purchases
GROUP BY customer_id
ORDER BY max_purchase_amount DESC
LIMIT 10;


/* mod division 
https://leetcode.com/problems/not-boring-movies/ */ 
Select 
    *
    From Cinema
    Where id % 2 = 1 
    AND description != 'boring'
order by rating desc 


--  having examples 
SELECT product_name 
FROM products 
GROUP BY product_name 
HAVING MIN(product_cost) < 3;


SELECT product_name
FROM products
GROUP BY product_name
HAVING AVG(product_cost) > (SELECT AVG(product_cost) FROM products);


select class
from courses 
group by class
having count(student) >= 5 


/* Last Transaction (for each day)
https://www.interviewquery.com/questions/last-transaction */ 
    
WITH cte as ( 
select 
    created_at, 
    transaction_value, 
    id, 
    row_number() over(partition by date(created_at)
                      order by created_at DESC) as daily_trx_rev_rank
    from bank_transactions
) 
Select 
    created_at, 
    transaction_value, 
    id
    From cte 
    Where daily_trx_rev_rank = 1 


-- basic aggregations 

/* https://leetcode.com/problems/top-travellers/submissions/
good reminder to group by primary key */ 
    
Select 
    u.name, 
    coalesce(sum(r.distance),0) as travelled_distance
    From users u 
    left join rides r 
        on u.id = r.user_id 
group by u.id, u.name 
order by sum(distance) desc, u.name asc 


select 
      a.user_account_id, 
      count(distinct User_Game_Smry_Date) Days_Played,
      sum(BGS.Sess_Duration_In_Sec) Sess_Duration_In_Sec,
      sum(cast(BGS.Game_Play_Cnt as decimal(38,2))) Game_Play_Cnt,
      sum(cast(BGS.Game_Play_Duration_In_Sec as decimal(38,2))) Game_Play_Duration_In_Sec


Select 
    activity_date as day, 
    count(distinct user_id) as active_users
    From Activity
    Where activity_date between date_add('2019-07-27', interval -29 day) and date('2019-07-27')
group by 1 


-- active  status 
Select case when Date_Diff <= 30 then 'Active' 
        when Date_Diff > 30 then 'Reactivated'  
        when Date_Diff is null then 'New'
    else 'Other' 
      end Activity_Status, count(distinct user_account_id)        
   from ( select distinct a.user_account_id, a.user_account_ss_code, a.Join_Date, 
                    max(Event_Date) Max_Active_Date, (Join_Date - Max_Active_Date) Date_Diff
         ) 

-- get crossover  
SELECT base.Ea_Fiscal_Year_Nbr, pivot.Ea_Fiscal_Year_Nbr, COUNT(DISTINCT base.user_account_id) counts
    FROM
      (SELECT DISTINCT CAL.Ea_Fiscal_Year_Nbr, ORR.User_Account_Id
          FROM revenue_tbl
          WHERE Valid_Order_Flag = 'Y'
          AND  order_date BETWEEN  '2011-01-01'  AND CURRENT_DATE 
      ) base
    JOIN
      (SELECT DISTINCT CAL.Ea_Fiscal_Year_Nbr, ORR.User_Account_Id 
          FROM revenue_tbl ORR 
          WHERE Valid_Order_Flag = 'Y'
          AND order_date BETWEEN  '2011-01-01'  AND CURRENT_DATE
      ) pivot
    ON base.user_account_id = pivot.user_account_id  
GROUP BY 1,2
ORDER BY 1,2     


-- 1.How many members ever worked at Microsoft prior to working at Google?
Select 
    count(distinct a.Member_id) as count
    from employee_info a 
    join employee_info b
        on a.Member_id = b.Member_id
        and a.Company = 'Microsoft'
        and b.Company = 'Google'
        and a.Year_Start < b.Year_Start


-- pivot wider and multi-crieria filter 
WITH skils_plus as ( 
SELECT 
      candidate_id
    , max(case when skill = 'Python' then 1 end) Python
    , max(case when skill = 'Tableau' then 1 end) Tableau
    , max(case when skill = 'PostgreSQL' then 1 end) PostgreSQL
    FROM candidates
Group by 1     
) 

Select 
      candidate_id
    from skils_plus sp 
    Where Python = 1 
    and Tableau = 1 
    and PostgreSQL = 1 
order by 1   


-- Confirmation Rate
SELECT 
    round(count(DISTINCT case when signup_action = 'Confirmed' then user_id end) / 
          cast(count(DISTINCT user_id) as decimal),2) as confirmation_rate
    From (SELECT
                e.user_id 
              , t.signup_action
              FROM emails as e 
              LEFT JOIN texts as t
                on e.email_id = t.email_id
          ) a     


-- users w/ $50+ spent on first transaction date 
With first_transaction_date_tbl as ( 
SELECT 
      user_id
    , min(transaction_date) as first_transaction_date
    -- , first_value(transaction_date) OVER (partition by user_id) as first_transaction_date
    FROM user_transactions
Group by 1     
) 

, ftd_w_spend as ( 
Select 
      ftd.user_id
    , ftd.first_transaction_date
    , ut.spend 
    From first_transaction_date_tbl ftd 
    LEft join user_transactions ut 
      on ftd.user_id = ut.user_id
      and ftd.first_transaction_date = ut.transaction_date
GROUP BY 1,2,3 
having ut.spend >= 50) 

Select 
    count(distinct user_id) as users 
    From ftd_w_spend


-- employye w/ highest salery in each dept 
Select 
      d.name as Department 
    , e.name as Employee 
    , e.salary as Salary 
    from Employee e 
    join (SELECT
                  DepartmentId
                , MAX(Salary) dep_max_sal
                FROM Employee
            GROUP BY DepartmentId
          ) dms 
          on e.DepartmentId = dms.DepartmentId
          and e.salary = dms.dep_max_sal
    left join Department d 
        on e.DepartmentId = d.id 


-- write a query to get the distribution of the number of conversations created by each user by day in 2020? 
Select 
    msg_number, 
    count() as frequency 
    FROM (Select 
            user,
            date, 
            COUNT(user2) as msg_number, 
            COUNT(DISTINCT user2) as unique_msg_number # this would be unique message recipients 
            From messages 
            Where year(date) = '2020'
          GROUP BY user1, date 
          ) 
GROUP BY msg_number
    

-- https://leetcode.com/problems/product-price-at-a-given-date/
with base as ( 
Select 
    product_id, 
    10 as price
    From products 
group by 1,2 
)
,last_change as ( 
Select 
    product_id, 
    max(change_date) last_change_date
    From products 
    Where change_date <= '2019-08-16'
group by 1     
)
Select 
    b.product_id, 
    case when l.last_change_date is not null then p.new_price 
         when l.last_change_date is     null then b.price
         end price
    from base b 
    left join last_change l
        on b.product_id = l.product_id
    left join products p
        on b.product_id = p.product_id
        and l.last_change_date = p.change_date
group by 1,2 


-- https://www.interviewquery.com/questions/top-three-salaries
WITH cte as ( 
select 
    concat(first_name, ' ', last_name) as employee_name, 
    d.name as department_name,
    e.salary,
    dense_rank() over(partition by d.name
                      order by salary desc) dept_salary_rank
    from departments d 
    join employees e 
        on d.id = e.department_id
) 

Select 
    employee_name, 
    department_name, 
    salary
    From cte 
    Where  dept_salary_rank <=  3 
order by department_name, salary desc 

