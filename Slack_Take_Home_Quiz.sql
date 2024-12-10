DROP TABLE employees;
DROP TABLE employees_projects;
DROP TABLE departments;
DROP TABLE projects;

/*
Time: You should feel free to spend as much time on this assignment as necessary to feel comfortable with your answers. In general, candidates typically spend somewhere between 1 - 2 hours.

Background on the Data: 
Slack has a system that allows apps to send alerts to Slack users in 3 channels (banner, push, sidebar). 

We log two separate events into a table called alerts:
1. Whenever a user sees an alert (impression or 'imp')
2. Whenever a user clicks on an alert ('clk')

The table contains data for a single day. This logging is new and hasn't been vetted yet. Trust nothing, callout bad data, and work to clean the data as necessary to get the best answer.

Columns in the table:
user_id: numeric, unique and persistent id for each user
team_id: numeric, unique and persistent id for each team. Each userid belongs to exactly one team.
app_id: numeric, unique and persistent id for each app
event: string with values 'imp' (as in impression, so it was seen) or 'clk' (the user interacted with it)
primary_browser: string, the browser the user was using
alert_type: string, alert was in a banner/sidebar/push
eventtime: the timestamp of when the interaction happened

Questions:
#1 What is the best performing alert type?
#2 What apps are the best and worst performing?
#3 I’m curious about what the first alert a team clicked on in this day? For each alert_type, compute how many teams clicked an alert of that type as their first alert in a day.

Process
You should document your final solution in the left hand pane including any relevant thought process and exploration as well as your final answer to the questions. You may also interact with the data in the right hand pane as you work (but this won't be saved!). We'll be looking at the final product in the left hand pane but may also replay your entire session to see how you worked through the questions.
*/

#########################
###### DATA CHECKS ######
#########################

# Example of raw data 
SELECT * FROM alerts LIMIT 5; 

# get a sense for how many users and teams there are 
Select 
    count(distinct user_id) user_id_count,
    count(distinct team_id) team_id_count
from alerts;

# these are small teams, with an average of only 2.5 per team 
Select 
      avg(user_id_count) avg_user_id_count_per_team
    From (Select 
                team_id,
                count(distinct user_id) user_id_count
            from alerts
          Group By 1 
         ) a;
         
###### MISSING DATA CHECKS ######         

# look for nulls and blank data 
SELECT 
  cast(eventtime as date) as event_date,         
  count(case when user_id is null or user_id = '' then 1 else null end) as user_null_count,
  count(case when team_id is null or team_id = '' then 1 else null end) as team_null_count,
  count(case when app_id is null or app_id = '' then 1 else null end) as app_null_count,
  count(case when event is null or event = '' then 1 else null end) as event_null_count,
  count(case when primary_browser is null or primary_browser = '' then 1 else null end) as browser_null_count,   
  count(case when alert_type is null or alert_type = '' then 1 else null end) as alert_type_null_count,
  count(case when eventtime is null then 1 else null end) as eventtime_null_count # blank test not possible here
 from alerts 
group by 1;

# here we confirm that this is due to blank values and that these are surfaced in the sql result a 0
Select 
    app_id
  from alerts 
 Where app_id = ''
 Group By 1;
 
 # now check some of the raw impacted data 
 Select 
    *
  from alerts 
 Where app_id = ''
Limit 20;

# NOTE: looking at the distribution of events by app_id, we can see that the missing data would not be much 
# of an impact on the more frequent app_id events, but if it is focused more in the infrequent app_id 
# events then this could have a big impact on correctly tracking use
Select
  app_id as app_id,
  count(*) as row_count
 from alerts 
group by 1
Order by 2 desc;

# check to see that the app_id data issue is limited to only about 2% of the rows 
Select 
    app_null_count / (app_count + app_null_count) as null_app_id_percnt 
    From (SELECT 
            count(case when app_id is not null or app_id != '' then 1 else null end) app_count,
            count(case when app_id is null or app_id = '' then 1 else null end) as app_null_count
           from alerts
      ) a;    
      
      
# is this small amount clustered in one team or user ? 
# 

# NOTE: HERE WE ARE COUNTING the metadata that are associated with the app_id data problem
# and here we see the blank app_id values appear as a 0 (which is a MySQL issue)
SELECT  
  count(distinct user_id) as user_null_count,
  count(distinct team_id) as team_null_count,
  count(distinct app_id) as app_null_count,
  count(distinct event) as event_null_count,
  count(distinct primary_browser) browser_null_count,   
  count(distinct alert_type) as alert_type_null_count,
  count(distinct eventtime) as eventtime_null_count    
 from alerts 
Where app_id is null or app_id = '';


# check by event 
# shows that this is hapening more with clk 3% of the time and 2% of time for imp, pretty similar 
Select 
    a.*,
    round(blanks / total,2) as blanks_percentage
    From (SELECT  
              event,
              count(case when app_id is null or app_id = '' then 1 else null end) as blanks,
              count(*) as total
           from alerts 
         Group By 1 
         ) a 
Order by 4 desc;

# check by browser
# shows that this is hapening more with 'other' browsers than either Safari or Chrome 
# Safari is working best, in terms of lowest percentage of blank app_id errors 
Select 
        a.*,
        round(blanks / total,2) as blanks_percentage
    From (SELECT  
              primary_browser,
              count(case when app_id is null or app_id = '' then 1 else null end) as blanks,
              count(*) as total
            from alerts 
          Group By 1 
         ) a 
Order by 4 desc;

# check by alert_type
# shows that this is hapening more with banner_alert and push_alert; and rarely with sidebar_alert 
Select 
    a.*,
    round(blanks / total,2) as blanks_percentage
    From (SELECT  
              alert_type,
              count(case when app_id is null or app_id = '' then 1 else null end) as blanks,
              count(*) as total
           from alerts 
         Group By 1 
         ) a 
Order by 4 desc;



# the blank app_id data is fairly evently distributed by hour
# but there is an increase in the percentage of events with blank app_id between hour 12 and 15
Select 
    a.event_hour as hour,
    a.null_app_id_event_count as null_app_id_event_count,
    b.event_count as event_count,
    round(a.null_app_id_event_count / b.event_count,2) as null_app_id_percentage
    From (SELECT 
              extract(hour from eventtime) as event_hour, 
              count(*) as null_app_id_event_count
            From alerts 
           Where (app_id is null or app_id = '')
          group by 1
          ) a 
   Left Join (SELECT 
              extract(hour from eventtime) as event_hour, 
              count(*) as event_count
            From alerts 
          group by 1
          ) b
          on a.event_hour = b.event_hour
order by 1;      

# looking at the existing app_id values, all numbers between 1 and 40 are there except 
# 32,35,36 adn 40. We should talk with Engineering & Product Management to determine if 
# there are app_ids with these values we should be seeing in the data 
# this might help identify where the logging issues are, if it is indeed corresponding to live missing apps
SELECT  
      app_id
   from alerts 
  Where app_id > 0
 Group By 1 
 order by 1;


###### INCORRECT DATA CHECKS ######     

## SUMMARY 

# NOTE: please un-comment to run the WITH statement temp tables in this section
# and also either delete or comment the SQL in the other sections 

# in the process of the null & blank data check above, it was determined that most metadata is valid
# for example, there are 3 values for both primary_browser and alert_type
# there are 2 values for event
# and we know the events and errors with the app_id are farily evenly distribution by hour 

# BUT based on this, we still need to check the user_id and team_id values

# user_id and / or team_id might have a data problem, 60% of user_id have 9 characters 
# and 39% have 8 characters. the remaining 1% being 7 or 5 characters 
# would need to investigate whether this is a bug 
# with totals_TBL as (
#   Select 
#        count(distinct user_id) as total_user_id_count,
#        count(distinct team_id) as total_team_id_count
#     From alerts
# ),

# user_id_length_TBL as (
#   SELECT 
#         user_id,
#         length(user_id) as user_id_length
#    from alerts 
#   group by 1
# ),

# user_id_length_count_TBL as (
#   Select 
#       user_id_length,
#       count(distinct user_id) as user_id_count
#     From user_id_length_TBL
#   group by 1
# ),

# user_id_summary_TBL as (
# Select 
#       'user_id' as id_type,
#       a.user_id_length as id_length,
#       a.user_id_count as sub_total,
#       b.total_user_id_count as total,
#       round(a.user_id_count / b.total_user_id_count,2) as percentage
#     From user_id_length_count_TBL as a 
#     Cross Join totals_TBL as b 
# order by 2 desc
# ),

# team_id_length_TBL as (
#   SELECT 
#         team_id,
#         length(team_id) as team_id_length
#    from alerts 
#   group by 1
# ),

# team_id_length_count_TBL as (
#   Select 
#       team_id_length,
#       count(distinct team_id) as team_id_count
#     From team_id_length_TBL
#   group by 1
# ),

# team_id_summary_TBL as (
# Select 
#       'team_id' as id,  
#       a.team_id_length as id_length,
#       a.team_id_count as id_sub_total,
#       b.total_team_id_count as id_total,
#       round(a.team_id_count / b.total_team_id_count,2) as id_percentage
#     From team_id_length_count_TBL as a 
#     Cross Join totals_TBL as b 
# order by 2 desc
# )

# Select 
#       *
#     from (Select 
#                 *
#             From user_id_summary_TBL
#   union all 
#           Select 
#                 *
#             From team_id_summary_TBL
#         ) a 
# Order By 1,3 desc 


# SELECT 
#         cast(eventtime as date) as event_date, 
#         alert_type as alert_type,
#         count(*) as row_count,   
#         count(concat(eventtime, user_id)) as user_event_count,          
#         count(distinct user_id) as user_count,
#         sum(case when event = 'imp' then 1 else null end) impressions,
#         sum(case when event = 'clk' then 1 else null end) clicks
#       from alerts 
# group by 1,2
# order by 3 desc

# SELECT 
#         cast(eventtime as date) as event_date, 
#         primary_browser as primary_browser,
#         count(*) as row_count,   
#         count(concat(eventtime, user_id)) as user_event_count,          
#         count(distinct user_id) as user_count,
#         sum(case when event = 'imp' then 1 else null end) impressions,
#         sum(case when event = 'clk' then 1 else null end) clicks
#       from alerts 
# group by 1,2
# order by 3 desc;

# SELECT 
#         cast(eventtime as date) as event_date, 
#         app_id as app_id,
#         count(*) as row_count,   
#         count(concat(eventtime, user_id)) as user_event_count,          
#         count(distinct user_id) as user_count,
#         sum(case when event = 'imp' then 1 else null end) impressions,
#         sum(case when event = 'clk' then 1 else null end) clicks
#       from alerts 
# group by 1,2
# order by 3 desc;




/* Example Answer
e.g. There are 5850 alerts in this table. This seems high (or low), etc.
*/


#########################
######  QUESTIONS  ######
#########################

# 1) What is the best performing alert type?

# sidebar_alert accounts for 45% of the overall alerts 
Select 
     row_number() over(order by c.percentage desc) as overall_alert_ranking,
     c.*
    From (Select 
                b.*,
                round(sub_total / total,2) as percentage
              From (Select 
                          a.*,
                          sum(sub_total) over() as total
                        From (SELECT  
                                  alert_type,
                                  count(*) as sub_total
                               from alerts 
                             Group By 1 
                             ) a 
                    ) b 
      ) c 
Order by 1;


# however,when adding the event we see that sidebar_alert is most frequent alert for the clk event 
# BUT push_alert tied with sidebar_alert for the imp event 
# SO we see that for both clk and imp the sidebar is effective, but that the push_alert gererates 
# just as many impression events as the sidebar
# lastly, we see the banner_alert performs better in terms of click engagement than the push_alert
Select 
    row_number() over(partition by event order by c.event_percentage desc) as event_alert_ranking,
    c.*
  From (Select 
              b.*,
              round(event_sub_total / event_total,2) as event_percentage
            From (Select 
                        a.*,
                        sum(event_sub_total) over(partition by event) as event_total
                      From (SELECT  
                                alert_type,
                                event,
                                count(*) as event_sub_total
                             from alerts 
                           Group By 1,2
                           ) a 
                  ) b 
        ) c      
Order by 3,1;


# event alerting types are fairly stable by hour as well 
Select
      a.event_hour as hour,
      round(b.sub_total / a.total,2) as banner_alert_percentage,
      round(c.sub_total / a.total,2) as push_alert_percentage,
      round(d.sub_total / a.total,2) as sidebar_alert_percentage
    From (SELECT
              extract(hour from eventtime) as event_hour,
              count(*) as total
            From alerts
          group by 1
          ) a
   Left Join (SELECT
              extract(hour from eventtime) as event_hour,
              alert_type,
              count(*) as sub_total
            From alerts
           Where alert_type = 'banner_alert'
          group by 1
          ) b
          on a.event_hour = b.event_hour
   Left Join (SELECT
              extract(hour from eventtime) as event_hour,
              alert_type,
              count(*) as sub_total
            From alerts
           Where alert_type = 'push_alert'
          group by 1
          ) c
          on a.event_hour = c.event_hour
   Left Join (SELECT
              extract(hour from eventtime) as event_hour,
              alert_type,
              count(*) as sub_total
            From alerts
           Where alert_type = 'sidebar_alert'
          group by 1
          ) d
          on a.event_hour = d.event_hour          
order by 1;


# 2) What apps are the best and worst performing?

# NOTE: in this section filters out the app_id > 0
# this is to filter out the blank app_id values that appear to coerce to 0 in when numeric 

# NOTE: it appears that some app_id numbers are either skipped or are not present in this dataset 
# there are comments above in the data checks section regarding this 

# apps 1 & 2 account for 40% of the overall alerts events
# on the other end of the spectrum, the apps 29, 30, 31, 32, & 33 all account for less than 1% of alerts
# the overall distribution is fairly long tailed, and we might discuss reducing the number of apps to
# better concentrate engagement adn reduce tech overhead 
Select 
     row_number() over(order by c.percentage desc) as overall_app_ranking,
     c.*
    From (Select 
                b.*,
                round(sub_total / total,2) as percentage
              From (Select 
                          a.*,
                          sum(sub_total) over() as total
                        From (SELECT  
                                  app_id,
                                  count(*) as sub_total
                               from alerts 
                              Where app_id > 0
                             Group By 1 
                             ) a 
                    ) b 
      ) c 
Order by 1;


# 3) I’m curious about what the first alert a team clicked on in this day? For each alert_type, compute how many teams clicked an alert of that type as their first alert in a day.

# NOTE: one team had two events associated with the same min eventtime
# the impact on the business decision is minimal, but this was deduped  using row_number and where clause

Select 
    rank() over(order by team_count desc) as first_alert_ranking,
    alert_type,
    team_count
  From (Select 
                alert_type as alert_type,
                count(distinct team_id) as team_count  
              From (Select 
                          row_number() over(partition by a.team_id) as row_num,
                          a.team_id as team_id,
                          b.alert_type as alert_type
                        from (Select 
                                  team_id, 
                                  min_event_time
                                  From (Select 
                                              team_id,
                                              min(eventtime) as min_event_time
                                            From alerts
                                        Group By 1 
                                        ) aa
                              ) a 
                        Left Join alerts b 
                            on a.team_id  = b.team_id
                            and a.min_event_time = b.eventtime
                    ) bb
            Where row_num = 1 
          Group By 1
        ) b;


# it appears one team has the same first eventtime 
Select 
    count(distinct team_id) as team_count,
    367 + 372 + 701 as check1
  From alerts ;





