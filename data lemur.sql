
# playing around 
# Repeat Purchases on Multiple Days
# Stitch Fix

SELECT 
      * 
    , extract(HOUR FROM last_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) first_purchase_hour 
    , extract(HOUR FROM first_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) last_purchase_hour 
    , lead(quantity) OVER (PARTITION BY user_id
                          ORDER BY purchase_date) as next_quantity 
    , row_number() OVER (PARTITION BY user_id 
                         ORDER BY user_id) user_row_num 
    , dense_rank() OVER (ORDER BY user_id) user_row_num        
    FROM purchases
ORDER BY user_id, purchase_date


# cross join example 
WITH purchases_plus as ( 
SELECT 
      * 
    , extract(HOUR FROM last_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) first_purchase_hour 
    , extract(HOUR FROM first_value(purchase_date) OVER (PARTITION BY user_id
                                                        ORDER BY user_id)) last_purchase_hour 
    , lead(quantity) OVER (PARTITION BY user_id
                          ORDER BY purchase_date) as next_quantity 
    , row_number() OVER (PARTITION BY user_id 
                         ORDER BY user_id) user_row_num 
    , dense_rank() OVER (ORDER BY user_id) user_row_num        
    FROM purchases
ORDER BY user_id, purchase_date
) 

, mini_tbl as ( 
Select 
      user_id 
    , product_id 
    , quantity
    From purchases_plus
) 

Select 
      user_id 
    , row_count      
    , count(*) as user_row_count
    from (Select 
              * 
             , count(*) over() as row_count
             From purchases
          ) a 
GROUP BY 1,2 

-- Select 
--       a.user_id 
--     , count(*) as row_count
--     from mini_tbl a 
--     cross join mini_tbl b 
-- GROUP BY 1 


# Signup Confirmation Rate
# Tiktok 
SELECT 
round(count(DISTINCT case when signup_action = 'Confirmed' then user_id end) / cast(count(DISTINCT user_id) as decimal),2) as confirmation_rate
    From (SELECT
                e.user_id
              , t.signup_action
              FROM emails as e 
              LEFT JOIN texts as t
                on e.email_id = t.email_id
        ) a     


# Data Science Skills
# Twitter 
WITH skils_plus as ( 
SELECT 
      candidate_id
    , max(case when skill = 'Python' then 1 end) Python
    , max(case when skill = 'Tableau' then 1 end) Tableau
    , max(case when skill = 'PostgreSQL' then 1 end) PostgreSQL
    FROM candidates
Group by 1     
) 

Select 
      candidate_id
    from skils_plus sp 
    Where Python = 1 
    and Tableau = 1 
    and PostgreSQL = 1 
order by 1   





WITH power_creator_tbl as ( 
SELECT 
    pp.profile_id 
  , pp.name 
  , pp.followers 
  , pp.employer_id 
  , cp.followers
  , case when pp.followers >  cp.followers then 'yes' end power_creator 
  FROM personal_profiles as pp
  LEFT JOIN company_pages as cp 
    on pp.employer_id = cp.company_id
Group by 1,2,3,4,5,6
) 

Select 
    profile_id
    From power_creator_tbl
Group By 1 
Order by 1 



With first_transaction_date_tbl as ( 
SELECT 
      user_id
    , min(transaction_date) as first_transaction_date
    -- , first_value(transaction_date) OVER (partition by user_id) as first_transaction_date
    FROM user_transactions
Group by 1     
) 

, ftd_w_spend as ( 
Select 
      ftd.user_id
    , ftd.first_transaction_date
    , ut.spend 
    From first_transaction_date_tbl ftd 
    LEft join user_transactions ut 
      on ftd.user_id = ut.user_id
      and ftd.first_transaction_date = ut.transaction_date
GROUP BY 1,2,3 
having ut.spend >= 50) 

Select 
    count(distinct user_id) as users 
    From ftd_w_spend






