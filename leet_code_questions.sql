
# 550. Game Play Analysis IV
# users who login on the day after their join date? 
WITH cte as ( 
Select 
    player_id, 
    event_date, 
    min(event_date)    over(partition by player_id) as first_login_date, 
    lead(event_date,1) over(partition by player_id
                            order by     event_date) as next_login_date
    From activity
) 


# 619. Biggest Single Number
# Find the largest single number. If there is no single number, report null.
WITH cte as ( 
Select 
    num, 
    count(*) over (partition by num) as num_cnt
    From MyNumbers
) 

Select 
    max(num) as num
    From cte 
    Where num_cnt = 1 


# community answer 
SELECT MAX(num) AS num
FROM (
    SELECT num
    FROM MyNumbers
    GROUP BY num
    HAVING COUNT(num) = 1
) AS unique_numbers;

# community answer 
Select (SELECT num 
			FROM MyNumbers 
			GROUP BY num 
			HAVING COUNT(num) = 1 
			ORDER BY num 
			DESC LIMIT 1) AS num;




# seat excchange 
SELECT id, 
       CASE 
         WHEN mod(id, 2) = 1 AND lead(id) OVER(ORDER BY id) IS NOT NULL THEN lead(student) OVER(ORDER BY id)
         WHEN mod(id, 2) = 0 THEN lag(student) OVER(ORDER BY id)
         ELSE student
       END AS student
FROM seat
ORDER BY id;




Select 
    ROUND(
    1. * COUNT(DISTINCT IF(event_date = first_login_date AND datediff(next_login_date, event_date) = 1, player_id, null)) /
         COUNT(DISTINCT player_id)
         ,2
        ) AS fraction
    From cte 


585. Investments in 2016
Get the sum of all total investment values in 2016 , for all policyholders who:
	have the same tiv_2015 value as one or more other policyholders, and
	are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
Round tiv_2016 to two decimal places.


select
    round(sum(tiv_2016), 2) as tiv_2016
from
    (
        select
            *
            , count(*) over (partition by tiv_2015) as tiv_2015_cnt
            , count(*) over (partition by lat, lon) as location_cnt
        from
            insurance
    ) t -- every derived table must have its own alias
where tiv_2015_cnt > 1 and location_cnt = 1


SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN (SELECT tiv_2015 FROM insurance GROUP BY tiv_2015 HAVING COUNT(*) > 1)
AND (lat, lon) IN (SELECT lat, lon FROM insurance GROUP BY lat, lon HAVING COUNT(*) = 1)




# Write your MySQL query statement below
WITH Insurance_2 as ( 
Select 
    a.pid, 
    a.tiv_2015, 
    concat(a.lat, a.lon) as lat_lon, 
    COUNT(DISTINCT b.pid) as matching_tiv_2015
    From Insurance a 
    Left Join Insurance b 
        on a.pid != b.pid 
        AND a.tiv_2015 = b.tiv_2015
Group by 1,2,3
) 

, same_city_pid as ( 
Select 
    a.pid 
    from Insurance_2 a
    join Insurance_2 b
        on a.lat_lon = b.lat_lon 
        and a.pid != b.pid
) 

Select 
    
    # ROUND(sum(tiv_2016),2) as tiv_2016
    from Insurance a 
    left join same_city_pid b 
        on a.pid = b.pid
    Where b.pid is null 



Table: Employee

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
| department  | varchar |
| managerId   | int     |
+-------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table indicates the name of an employee, their department, and the id of their manager.
If managerId is null, then the employee does not have a manager.
No employee will be the manager of themself.
 

Write a solution to find managers with at least five direct reports.

Return the result table in any order.

The result format is in the following example.

Example 1:

Input: 
Employee table:
+-----+-------+------------+-----------+
| id  | name  | department | managerId |
+-----+-------+------------+-----------+
| 101 | John  | A          | None      |
| 102 | Dan   | A          | 101       |
| 103 | James | A          | 101       |
| 104 | Amy   | A          | 101       |
| 105 | Anne  | A          | 101       |
| 106 | Ron   | B          | 101       |
+-----+-------+------------+-----------+
Output: 
+------+
| name |
+------+
| John |
+------+


SELECT E1.name
FROM Employee E1
JOIN (
    SELECT managerId, COUNT(*) AS directReports
    FROM Employee
    GROUP BY managerId
    HAVING COUNT(*) >= 5
) E2 ON E1.id = E2.managerId;

SELECT e.name
FROM Employee AS e 
INNER JOIN Employee AS m ON e.id=m.managerId 
GROUP BY m.managerId 
HAVING COUNT(m.managerId) >= 5

SELECT name 
FROM Employee 
WHERE id IN (
    SELECT managerId 
    FROM Employee 
    GROUP BY managerId 
    HAVING COUNT(*) >= 5)

SELECT a.name 
FROM Employee a 
JOIN Employee b ON a.id = b.managerId 
GROUP BY b.managerId 
HAVING COUNT(*) >= 5

SELECT e1.name
FROM employee e1
LEFT JOIN employee e2 ON e1.id=e2.managerId
GROUP BY e1.id
HAVING COUNT(e2.name) >= 5;




https://leetcode.com/problems/customers-who-bought-all-products/submissions/

WITH cust as ( 
Select 
    customer_id, 
    count(distinct product_key) as cus_total_products
    From Customer 
group by 1     
)

, prod as (
Select 
    count(distinct product_key) as total_products
    From Product
) 

, main as ( 
Select  
    c.customer_id,
    c.cus_total_products, 
    p.total_products
    From cust c
    cross join prod p
group by 1,2,3     
having c.cus_total_products = p.total_products
) 

Select distinct 
    customer_id
    From main


WITH cust as ( 
Select 
    customer_id, 
    count(distinct product_key) as cus_total_products
    From Customer 
group by 1     
)

, prod as (
Select 
    count(distinct product_key) as total_products
    From Product
) 

, main as ( 
Select 
    customer_id, 
    cus_total_products,
    (Select total_products from prod) as total_products  
    From cust 
group by 1,2,3
having  cus_total_products = total_products
) 

Select customer_id from main 




https://leetcode.com/problems/second-highest-salary/submissions/


# 2nd highest 
SELECT MAX(Salary) AS SecondHighestSalary 
FROM Employee
WHERE Salary NOT IN (
    SELECT MAX(Salary) FROM Employee
)


WITH cte as ( 
Select 
    id,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC)  AS salary_rnk
    From Employee
)

Select 
    IF(max(salary_rnk) >=2, salary, null) as SecondHighestSalary
    From cte 
    WHERE salary_rnk = 2    







WITH cte1 as
(SELECT visited_on, SUM(amount) as total_amount
FROM Customer
GROUP BY visited_on),

cte2 as 
(SELECT 
        visited_on, 
        SUM(total_amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as amount, 
        ROUND(AVG(total_amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as average_amount
FROM cte1)

SELECT *
FROM cte2
WHERE visited_on >= (SELECT visited_on FROM Customer ORDER BY visited_on LIMIT 1) + 6
ORDER BY visited_on


