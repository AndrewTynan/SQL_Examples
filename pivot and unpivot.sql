
https://docs.aws.amazon.com/dms/latest/sql-server-to-aurora-mysql-migration-playbook/chap-sql-server-aurora-mysql.tsql.pivot.html
https://ubiq.co/database-blog/unpivot-table-mysql/

Create a simple PIVOT for the number of orders for each day. Days of month from 5 to 31 are omitted for example simplicity.

SELECT 'Number of Orders Per Day' AS DayOfMonth,
    COUNT(CASE WHEN DAY(OrderDate) = 1 THEN 'OrderDate' ELSE NULL END) AS '1',
    COUNT(CASE WHEN DAY(OrderDate) = 2 THEN 'OrderDate' ELSE NULL END) AS '2',
    COUNT(CASE WHEN DAY(OrderDate) = 3 THEN 'OrderDate' ELSE NULL END) AS '3',
    COUNT(CASE WHEN DAY(OrderDate) = 4 THEN 'OrderDate' ELSE NULL END) AS '4' /*...[31]*/
FROM Orders AS O;


PIVOT for number of orders for each day for each customer.

SELECT Customer,
    COUNT(CASE WHEN DAY(OrderDate) = 1 THEN 'OrderDate' ELSE NULL END) AS '1',
    COUNT(CASE WHEN DAY(OrderDate) = 2 THEN 'OrderDate' ELSE NULL END) AS '2',
    COUNT(CASE WHEN DAY(OrderDate) = 3 THEN 'OrderDate' ELSE NULL END) AS '3',
    COUNT(CASE WHEN DAY(OrderDate) = 4 THEN 'OrderDate' ELSE NULL END) AS '4' /*...[31]*/
FROM Orders AS O
GROUP BY Customer;



Unpivot employee sales for each date into individual rows for each employee.

SELECT SaleDate,
    Employee,
    SaleAmount
FROM
(
    SELECT SaleDate,
        Employee,
        CASE
            WHEN Employee = 'John' THEN John
            WHEN Employee = 'Kevin' THEN Kevin
            WHEN Employee = 'Mary' THEN Mary
        END AS SaleAmount
    FROM EmployeeSales
    CROSS JOIN
    (
        SELECT 'John' AS Employee
        UNION ALL
        SELECT 'Kevin'
        UNION ALL
        SELECT 'Mary'
    ) AS Employees
) AS UnpivotedSet;








