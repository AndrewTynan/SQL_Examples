
https://www.interviewquery.com/questions/random-weighted-driver#comments
Random Weighted Driver
WITH RECURSIVE cte AS(
    SELECT id, weighting, 1 AS cnt
    FROM drivers
    UNION ALL
    SELECT id, weighting, cnt+1
    FROM cte
    WHERE cnt < weighting
)
SELECT id
FROM cte
ORDER BY RAND()
LIMIT 1;


https://builtin.com/data-science/advanced-sql
2. Recursive CTEs

A recursive CTE is a CTE that references itself, just like a recursive function in Python. Recursive CTEs are especially useful when querying hierarchical data like organization charts, file systems, a graph of links between web pages, and so on.

A recursive CTE has three parts:

The anchor member, which is an initial query that returns the base result of the CTE.
The recursive member is a recursive query that references the CTE. This is UNION ALLed with the anchor member
A termination condition that stops the recursive member.
Here’s an example of a recursive CTE that gets the manager ID for each staff ID:

with org_structure as (
   SELECT id
          , manager_id
   FROM staff_members
   WHERE manager_id IS NULL
   UNION ALL
   SELECT sm.id
          , sm.manager_id
   FROM staff_members sm
   INNER JOIN org_structure os
      ON os.id = sm.manager_id
) 

