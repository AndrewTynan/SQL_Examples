
# https://leetcode.com/problems/customers-who-bought-all-products/
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