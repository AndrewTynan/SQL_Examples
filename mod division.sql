
https://datalemur.com/questions/odd-even-measurements
# Write a query to calculate the sum of odd-numbered and even-numbered measurements separately for a particular day 
# and display the results in two different columns. Refer to the Example Output below for the desired format.

WITH measurement_date_cte as ( 
SELECT 
    measurement_id,
    measurement_value, 
    date(measurement_time) as measurement_day, 
    row_number() over(PARTITION BY date(measurement_time) 
                      ORDER BY measurement_time) as measure_num 
    FROM measurements
) 

SELECT  
    measurement_day, 
    SUM(CASE WHEN MOD(measure_num, 2) != 0 THEN measurement_value END) AS odd_sum, 
    SUM(CASE WHEN MOD(measure_num, 2) = 0 THEN measurement_value END) AS even_sum
    FROM measurement_date_cte
GROUP BY 1 
ORDER BY 1



https://www.interviewquery.com/questions/sample-time-series
Given a transactions table with date timestamps, sample every 4th row ordered by the date.

WITH cte as ( 
select 
    created_at, 
    product_id,
    MOD(row_number() over(order by created_at),4 ) as fours 
    from transactions 
order by 1     
) 
Select 
    created_at, 
    product_id     
    from cte     
    Where fours = 0 


DIV is the opposite of MOD 
it keeps the value in front of the decimal 
https://www.interviewquery.com/questions/ctr-by-age

SELECT 
    TIMESTAMPDIFF(year, date(birthdate), date(search_time)) DIV 10 as age_group,
    AVG(has_clicked) as ctr 
    FROM search_events s 
    join users u 
        on s.user_id = u.id 
    Where year(search_time) = 2021 
group by age_group   
order by 2 desc, 1      
limit 3 


