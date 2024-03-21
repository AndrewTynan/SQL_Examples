/* https://www.interviewquery.com/questions/month-over-month */ 

/* Given a table of transactions and products, write a function to get the month_over_month change in revenue for the year 2019. 
Make sure to round month_over_month to 2 decimal places. */ 

WITH sales_cte as ( 
select 
    month(created_at) as month,
    sum(quantity * price) as sales
    from transactions t 
    JOIN products p 
        ON t.product_id = p.id
    Where year(created_at) = 2019 
group by 1     
) 
  
Select 
    month, 
    ROUND((sales - lag(sales) over(order by month)) / 
                   lag(sales) over(order by month)
          , 2) AS month_over_month
    From sales_cte
order by month 
