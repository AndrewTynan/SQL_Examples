question 1:

The `order` table has each order's ID, creation date, user_id and revenue amount. (Same day may have multiple orders from different users)

order_id | date           | user_id | revenue 
1964     | 2021-01-01 | 1           | $100
2778     | 2021-01-03 | 1           | $120
2007     | 2021-01-01 | 2           | $99

The `spend` table has each marketing campaign’s daily clicks and spend 

Date       | channel | campaign      | clicks | spend
2021-01-01 | google  | gl-sem        |  5     | 6
2021-01-01 | google  | gl-pla        |  20    | 38
2021-01-03 | facebook| fb-1          | 10     | 15

1a. Write a SQL query to get the daily total revenue ordered by date

Select 
     date
    ,coalesce(sum(revenue),0) as total_revenue
    From order 
group by date 
order by date 

1b. Write a SQL query to get the daily total spend ordered by date

Select  
     Date 
    ,coalesce(sum(spend),0) as total_spend
    From spend 
group by Date 

1c. Write a SQL query to get the daily ROAS (return on ad spend) ordered by date 

WITH revenue_cte as ( 
Select 
     date
    ,coalesce(sum(revenue),0) as total_revenue
    From order 
group by date 
) 

, spend_cte as (
Select  
     Date as date 
    ,coalesce(sum(spend),0) as total_spend
    From spend 
group by 1     
)

Select 
     r.date
    ,1. * total_revenue / total_spend as roas 
    from revenue_cte r 
    Left join spend_cte s 
        on r.date = s.date
order by r.date

Q2

-- The `order` table has each order's ID, creation date, product id and revenue amount. 
The table is at order_id and product_id level
	Ex: If an order consists of two products, then there will be two rows

-- order_id | date       | product_id  | revenue 
-- 1964     | 2023-04-01 | 1           | $100
-- 2778     | 2023-04-02 | 2           | $120
-- 2007     | 2023-04-03 | 3           | $99

-- Product Mapping table
This table ‘product_mapping’ is at product id level, containing the category name for each product

-- product_id | category_name
-- 1          | dining table
-- 2          | dining chair
-- 3          | lighting

 Write a SQL query to get the top N products that cover upto 30% of revenue in their respective categories.
The N varies from category to category, where for dining tables, it can be just 50 products whereas for lighting it can be 100 products.
WITH cte as ( 
Select 
      o.product_id
     ,p.category_name
     ,sum(revenue) as revenue 
    From order o 
    Join product_mapping p 
        on o.product_id = p.product_id
group by 1,2 
) 
, cte2 as ( 
Select 
     *
     ,sum(revenue) over(partition by category_name) as category_revenue
     ,1. * revenuev / sum(revenue) over(partition by category_name) as category_revenue_percent 
    from cte 
group by     
) 
, cte3 as ( 
Select 
    *
    sum(category_revenue_percent) over(partition by category_name
                                       order by revenue desc) cumsum_category_revenue_percent
    From cte2
)
Select 
     category_name
    ,product_id
    ,category_revenue_percent
    from cte3
    Where cumsum_category_revenue_percent <= .3
order by category_revenue_percent desc 

The team has recently developed a new ranking model. We want to evaluate the success of this new model. 
How will you design it?


we run a randomized experiment and 
find that the 95% confidence interval for CTR in the new model vs the control is [-2.2%, +4.1%].

What would you conclude based on these results?


CA: [-16.2%, -2.5%] (p-value: 0.04)
TX: [-8.3%, -0.7%]  (p-value = 0.03)
NY: [6.1%, 16.1%]   (p-value = 0.02)
FL: [-12.1%, -2.0%] (p-value: 0.04)



