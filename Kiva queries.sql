
-- Question 1 

Select 
        count (distinct  kiva_user_id) 
     From "KIVA_DEV"."ANALYTICS_EXERCISE"."KIVA_USERS"


-- Question 2 

With Conflict_Zones_and_Vulnerable_Groups_Loans as (
Select 
     distinct ltfm.loan_id
    From "KIVA_DEV"."ANALYTICS_EXERCISE"."LOAN_THEME_FILTERS_MAPPER" ltfm
    Join "KIVA_DEV"."ANALYTICS_EXERCISE"."LOAN_THEME_FILTERS" ltf
      on ltfm.LOAN_THEME_FILTER_ID = ltf.LOAN_THEME_FILTER_ID
    Where ltf.name IN ('Conflict Zones','Vulnerable Groups')
) 

SELECT sum(amount_lent) as total_amount_lent
    From "KIVA_DEV"."ANALYTICS_EXERCISE"."TRANSACTIONS"  
    Where loan_id in (Select loan_id from Conflict_Zones_and_Vulnerable_Groups_Loans) 


-- Question 3

With campaigns as ( 
    Select * 
        From (Select 
                    kiva_user_id 
                  , event_id
                  , cookie_id 
                  , session_id
                  , mkt_campaign    
                  , mkt_medium
                  -- attribute transactions to the first campaign parameters found in a session
                  -- marketing campaigns associated with a page view are found under the MKT_SOURCE, MKT_MEDIUM, and MKT_CAMPAIGN columns. 
                  , row_number() over(partition by session_id, mkt_source, mkt_medium, mkt_campaign 
                                      order by event_time) as row_num
                From "KIVA_DEV"."ANALYTICS_EXERCISE"."EVENTS" 
              -- make sure marketing campaigns are not all null values across mkt_source, mkt_medium, mkt_campaign fields 
              Where (mkt_medium is not null 
                     and mkt_medium is not null 
                     and mkt_medium is not null) 
             ) 
       Where row_num = 1
)
 
, email_campaign_transaction_counts as ( 
Select 
        tc.mkt_campaign
      , count(distinct t.transaction_id) as transaction_count -- get number loan transactions
  From "KIVA_DEV"."ANALYTICS_EXERCISE"."TRANSACTIONS" t 
  Left Join campaigns tc 
    on  t.kiva_user_id = tc.kiva_user_id  
    and t.cookie_id    = tc.cookie_id    
    and t.session_id   = tc.session_id 
  Where tc.mkt_medium = 'email' 
Group By tc.mkt_campaign
) 

Select top 10
      mkt_campaign
    , transaction_count
  from email_campaign_transaction_counts
group by mkt_campaign, transaction_count
order by transaction_count desc 


--Question 4 

-- A 
With campaigns as ( 
    Select * 
        From (Select 
                    kiva_user_id 
                  , event_id
                  , cookie_id 
                  , session_id
                  , mkt_campaign    
                  , mkt_medium
                  -- attribute transactions to the first campaign parameters found in a session
                  -- marketing campaigns associated with a page view are found under the MKT_SOURCE, MKT_MEDIUM, and MKT_CAMPAIGN columns. 
                  , row_number() over(partition by session_id, mkt_source, mkt_medium, mkt_campaign 
                                      order by event_time) as row_num
                From "KIVA_DEV"."ANALYTICS_EXERCISE"."EVENTS" 
              -- make sure marketing campaigns are not all null values across mkt_source, mkt_medium, mkt_campaign fields 
              Where (mkt_medium is not null 
                     and mkt_medium is not null 
                     and mkt_medium is not null) 
             ) 
       Where row_num = 1
)


Select top 5 -- filterting to top campaigns 
        upper(tc.mkt_campaign)  as mkt_campaign
      , count(distinct t.session_id) as session_count      
      , count(distinct t.transaction_id) as transaction_count       
      , count(distinct tc.kiva_user_id) as transacting_user_count 
      , (count(distinct t.transaction_id) / count(distinct tc.kiva_user_id)) as transactions_per_user 
      , (count(distinct t.transaction_id) / count(distinct t.session_id)) as transactions_per_session       
  From "KIVA_DEV"."ANALYTICS_EXERCISE"."TRANSACTIONS" t 
  Left Join campaigns tc 
    on  t.kiva_user_id = tc.kiva_user_id  
    and t.cookie_id    = tc.cookie_id    
    and t.session_id   = tc.session_id 
  Where tc.mkt_medium = 'email' 
Group By upper(tc.mkt_campaign) 
//having count(distinct t.transaction_id) > 5000
order by count(distinct t.transaction_id) desc 


-- B 
With campaigns as ( 
    Select * 
        From (Select 
                    kiva_user_id 
                  , event_id
                  , cookie_id 
                  , session_id
                  , mkt_campaign    
                  , mkt_medium
                  -- attribute transactions to the first campaign parameters found in a session
                  -- marketing campaigns associated with a page view are found under the MKT_SOURCE, MKT_MEDIUM, and MKT_CAMPAIGN columns. 
                  , row_number() over(partition by session_id, mkt_source, mkt_medium, mkt_campaign 
                                      order by event_time) as row_num
                From "KIVA_DEV"."ANALYTICS_EXERCISE"."EVENTS" 
              -- make sure marketing campaigns are not all null values across mkt_source, mkt_medium, mkt_campaign fields 
              Where (mkt_medium is not null 
                     and mkt_medium is not null 
                     and mkt_medium is not null) 
             ) 
       Where row_num = 1
)

Select 
       case when CONTAINS(lower(tc.mkt_campaign), 'repayment') then 'loan repayment'
            when CONTAINS(lower(tc.mkt_campaign), 'erl') then 'sufficient balance'
            when CONTAINS(lower(tc.mkt_campaign), 'journal_entry') then 'borrow update'       
            when CONTAINS(lower(tc.mkt_campaign), 'iwd') then 'intl women day'
            else 'other'
            end mkt_campaign_types     
      , count(distinct t.transaction_id) as transaction_count       
      , count(distinct tc.kiva_user_id) as transacting_user_count 
      , sum(amount_lent) as amount_lent
      , sum(amount_lent) / count(distinct t.transaction_id) as amount_lent_per_transaction
      , sum(amount_lent) / count(distinct tc.kiva_user_id) as amount_lent_per_user 
  From "KIVA_DEV"."ANALYTICS_EXERCISE"."TRANSACTIONS" t 
  Left Join campaigns tc 
    on  t.kiva_user_id = tc.kiva_user_id  
    and t.cookie_id    = tc.cookie_id    
    and t.session_id   = tc.session_id 
  Where tc.mkt_medium is not null 
Group By 1
order by count(distinct t.transaction_id) desc 

