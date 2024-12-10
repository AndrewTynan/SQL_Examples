
# Card Launch Success 
WITH card_name_cte as( 
SELECT 
    issue_month, 
    issue_year, 
    MAKE_DATE(issue_year, issue_month, 1) as year_month,     
    MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER(PARTITION BY card_name) as first_year_month,    
    card_name, 
    issued_amount 
    FROM monthly_cards_issued
)     
    
SELECT  
    card_name, 
    issued_amount
    FROM card_name_cte
    WHERE year_month = first_year_month
ORDER BY issued_amount DESC


# Compressed Mode
# Write a query to retrieve the mode of the order occurrences. 
# Additionally, if there are multiple item counts with the same mode, the results should be sorted in ascending order.
WITH mode_order_occurrences_cte as ( 
SELECT 
    item_count,
    order_occurrences, 
    max(order_occurrences) OVER() as mode_order_occurrences
    FROM items_per_order
) 

SELECT  
    item_count
    FROM mode_order_occurrences_cte
    Where order_occurrences = mode_order_occurrences
ORDER BY item_count ASC 


-- Repeated Payments - Hard 
-- https://datalemur.com/questions/repeated-payments
SELECT 
  merchant_id, 
  credit_card_id, 
  amount,
  transaction_timestamp,
  EXTRACT(EPOCH FROM transaction_timestamp - 
    LAG(transaction_timestamp) OVER(
      PARTITION BY merchant_id, credit_card_id, amount 
      ORDER BY transaction_timestamp)
  )/60 AS minute_difference 
FROM transactions;




