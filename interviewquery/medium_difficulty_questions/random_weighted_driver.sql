/* https://www.interviewquery.com/questions/random-weighted-driver */

/* 
Let’s say we want to improve the matching algorithm for drivers and riders for Uber. 
The engineering team has added a new column to the drivers table called weighting. 
It contains a weighted value, which they hope will lead to better matching.
Given this table of drivers, write a query to perform a weighted random selection of a driver based on the driver weight.
*/ 

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
