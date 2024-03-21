/* https://www.interviewquery.com/questions/branch-sales-pivot */ 

/* Your company, a multinational retail corporation, has been storing sales data from various branches worldwide in separate tables according to 
the year the sales were made. The current data structure is proving inefficient for business analytics and the management has requested your 
expertise to streamline the data.

Write a query to create a pivot table that shows total sales for each branch by year.
Note: Assume that the sales are represented by the total_sales column and are in USD. Each branch is represented by its unique branch_id. */

select
    branch_id,
    sum(21_sales) as total_sales_2021,
    sum(22_sales) as total_sales_2022
from
    (
        select
            branch_id,
            total_sales as 21_sales,
            0 as 22_sales
        from
            sales_2021
        union
        select
            branch_id,
            0 as 21_sales,
            total_sales as 22_sales
        from
            sales_2022
    ) as a
group by
    branch_id
