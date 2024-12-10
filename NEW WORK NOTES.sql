
===================NEW WORK SUMMARY==================

--Notes on different types of queries 


===================Create Table======================

CREATE SET TABLE sandbox.AJT_Origin_Games_Play_Monthly 
	(
		Month_End_Date DATE FORMAT 'YYYY-MM-DD', 
		master_ttl_name VARCHAR(50), 
		Player_Count INTEGER
	)
UNIQUE PRIMARY INDEX ( Month_End_Date );

create set table SANDBOX.ORIGN_SALES_FORECAST 
(
	Order_Date DATE FORMAT 'YYYY-MM-DD',
	Forecast_Bookings DECIMAL(18,2),
	Actual_Bookings DECIMAL(18,2)
)
UNIQUE PRIMARY INDEX (order_date);

===================Casting Examples==================

CAST('word' AS CHAR(2)) AS truncation
CAST(333 AS CHAR(3)) AS num_to_char
CAST(122 AS INTEGER) AS Bigger
CAST(111.44 AS SMALLINT) AS whole_num
CAST(178.66 AS DECIMAL(3,0)) AS rounding
cast('2015-01-01' as date format 'yyyy-mm-dd')

Cast(NUNS.new_spenders as Decimal (18,8)) / NU.New_Users as Conversion

===================Condition Examples================
like '%Full Game%'


SELECT COALESCE(Country,'US') as Output


===================Extract Hour======================
where or conditions in where clause

===================Extract Hour======================

Select grant_date,  HourExtract, count(distinct a.User_account_Id)  as entitlements 
from 
(
	Select distinct E.User_account_Id, E.User_Account_Ss_Code, E.Grant_Date, Extract(Hour From e.Grant_Time) as HourExtract 
	FROM EADW_CORE_PUB.ENTITLEMENT e    
		JOIN EADW_CORE_PUB.OFFER_ITEM_DIM p
			ON p.edw_project_id = e.edw_project_id
		JOIN SANDBOX.origin_users OU
			on e.user_account_id = OU.user_account_id
			and e.user_account_ss_code = OU.user_account_ss_code
		where E.status_text IN ('ACTIVE  ', 'ACTIVE') 
		and Grant_Date between '2014-10-26' and current_date 
		and P.Master_Ttl_Name = 'CRUSADER-NO REMORSE'
		and P.Platform_code = 'PCWIN'
		AND e.Stndrd_Rptg_Entitlement_Tag_Cd = 'CRUSADER_NO_REMORSE_OTH'
		and Source_System_Offer_Item_Id in ('DR:231812900' )
) a 
Group By grant_date,  HourExtract
order by grant_date,  HourExtract;

==================Case Statement===================

Create	table  sandbox.at_BF_NP_lastplayed_groups
as (	
Select User_Id, last_played, 
case when (current_date - users.last_played) <= 30 then 'Played_within_30_Days' 
		  when ((current_date - users.last_played) > 30 And (current_date - users.last_played) <= 60) then 'Lapsed_31_to_60_Days' 
		  when ((current_date - users.last_played) > 60 And (current_date - users.last_played) <= 180) then 'Lapsed_61_to_180_Days'  
		  when ((current_date - users.last_played) > 180 And (current_date - users.last_played) <= 365) then 'Lapsed_181_to_365_Days'  
		  when (current_date - users.last_played) > 365 then 'Lapsed_365_Days' 
		  Else  'Other'
		  End as Activity 
From	sandbox.at_BF_nonprem_lastplayed users 
Group By  User_Id, last_played, 
case when (current_date - users.last_played) <= 30 then 'Played_within_30_Days' 
		  when ((current_date - users.last_played) > 30 And (current_date - users.last_played) <= 60) then 'Lapsed_31_to_60_Days' 
		  when ((current_date - users.last_played) > 60 And (current_date - users.last_played) <= 180) then 'Lapsed_61_to_180_Days'  
		  when ((current_date - users.last_played) > 180 And (current_date - users.last_played) <= 365) then 'Lapsed_181_to_365_Days'  
		  when (current_date - users.last_played) > 365 then 'Lapsed_365_Days' 
		  Else  'Other'
		  End 
) 
with data and statistics ;


create set volatile table Origin_G3_MAIN_1 as 
( 
	select distinct user_account_id, User_Account_Ss_Code, Sales_Order_Id, Edw_Offer_Item_Id, 
			Refund_Date, Order_Date,  Acquisition_Date, Sales_Channel, Reporting_Continent, master_ttl_name, User_Status, units, Revenue_amt,
		(Refund_Date - Order_Date) Days_to_Refund,
 		case when Days_to_Refund <= 7 OR (
			 (master_ttl_name = 'FIFA 14' and Refund_Date <= '2013-09-30') OR 
			 (master_ttl_name = 'NFS RIVALS (2014)' and Refund_Date <= '2013-11-22') OR 
			 (master_ttl_name = 'BATTLEFIELD 4' and Refund_Date <= '2013-11-05') OR 
			 (master_ttl_name = 'TITANFALL' and Refund_Date <= '2014-03-18') OR
			 (master_ttl_name = 'PLANTS VS ZOMBIES GARDEN WARFARE' and Refund_Date <= '2014-07-01') OR
			 (master_ttl_name = 'FIFA 15' and Refund_Date <= '2014-09-30') OR
			 (master_ttl_name = 'SIMS 4' and Refund_Date <= '2014-09-09') OR
			 (master_ttl_name = 'DRAGON AGE: INQUISITION' and Refund_Date <= '2014-11-25')
		 ) 
		 then 'G3 Refund'
		 	else 'Non-G3 Refund'
		 		end Refund_Type,
 		case when
			 ((master_ttl_name = 'FIFA 14' and Order_Date <= cast ('2013-09-30' as date format 'YYYY/MM/DD') + 120) OR 
			 (master_ttl_name = 'NFS RIVALS (2014)' and Order_Date <= cast ('2013-11-22' as date format 'YYYY/MM/DD') + 120) OR 
			 (master_ttl_name = 'BATTLEFIELD 4' and Order_Date <= cast ('2013-11-05' as date format 'YYYY/MM/DD') + 120) OR 
			 (master_ttl_name = 'TITANFALL' and Order_Date <= cast ('2014-03-18' as date format 'YYYY/MM/DD') + 120) OR
			 (master_ttl_name = 'PLANTS VS ZOMBIES GARDEN WARFARE' and Order_Date <= cast ('2014-07-01' as date format 'YYYY/MM/DD') + 120) OR
			 (master_ttl_name = 'FIFA 15' and Order_Date <= cast ('2014-09-30' as date format 'YYYY/MM/DD') + 120) OR
			 (master_ttl_name = 'SIMS 4' and Order_Date <= cast ('2014-09-09' as date format 'YYYY/MM/DD') + 120) OR
			 (master_ttl_name = 'DRAGON AGE: INQUISITION' and Order_Date <= cast ('2014-11-25' as date format 'YYYY/MM/DD') + 120)
		 ) 
		 then 'Frontline'
		 	else 'Non-Frontline'
		 		end Frontline_Status	 		
		from Origin_G3_MAIN
	group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16
)
with data on commit preserve rows 

=====================================================

--Origin BF3 purchasers cross over to BF4
select case when BF4_order_date <= BF3_order_date 
		then 'BF4 pre BF3'
			else 'BF3 pre BF4'
				end Attach_Status, 
		count(distinct a.user_account_id)
	from 
	(
	SELECT distinct ORR.User_Account_Id, ORR.User_Account_Ss_Code, order_date BF4_order_date
		from Origin_Pub.ORIGIN_REVENUE ORR 
		join eadw_core_pub.offer_item_dim oi
			on oi.Edw_Offer_Item_Id = ORR.Edw_Offer_Item_Id
		where Valid_Order_Flag = 'Y'
		and oi.master_ttl_name ='BATTLEFIELD 4'
		and oi.revenue_method_name IN ('DG FG', 'PG FG')	
		and order_date between '2013-03-01'  and  current_date --from start of pre-order
	) a 
join 
	(
	SELECT distinct ORR.User_Account_Id, ORR.User_Account_Ss_Code, order_date BF3_order_date
		from Origin_Pub.ORIGIN_REVENUE ORR 
		join eadw_core_pub.offer_item_dim oi
			on oi.Edw_Offer_Item_Id = ORR.Edw_Offer_Item_Id
		where Valid_Order_Flag = 'Y'
		and oi.master_ttl_name ='BATTLEFIELD #3'
		and oi.revenue_method_name IN ('DG FG', 'PG FG')	
		and order_date between  '2011-01-01'  and  current_date --from before start of pre-order
	) b
	on a.User_Account_Id = b.User_Account_Id
	and a.User_Account_Ss_Code = b.User_Account_Ss_Code
group by 1

===================================================

SELECT  Region_Name, count(distinct user_account_id) as User_Count 
	from 
		(select distinct a.User_Account_Id, a.User_Account_Ss_Code, geo.Region_Name --add the region_name 
			from origin_pub.origin_users a 
			JOIN (SELECT  distinct a.User_Account_Id, a.User_Account_Ss_Code 	--list of BF4 FG owners that do not own BF4 Premium
						 FROM 
						(--get the BF4 full game owners
						 SELECT distinct e.User_Account_Id, e.User_Account_Ss_Code 
							FROM EADW_CORE_PUB.ENTITLEMENT e    
							JOIN EADW_ADM_APP.PROJECT_DIM p
								ON p.edw_project_id = e.edw_project_id
							where e.status_text IN ('ACTIVE', 'BANNED', 'PENDING')
							AND  p.master_ttl_name =  'BATTLEFIELD 4'
							AND e.Stndrd_Rptg_Entitlement_Tag_Cd IN ( 'ONLINE_ACCESS' ) 
							AND e.grant_date between  '2013-03-01'  and  current_date 
							AND p.platform_code = 'PCWIN'    
							AND Revenue_Method_Name IN ( 'PG FG' , 'DG FG' ) 
							) a 
						LEFT JOIN 
							( --remove the users with BF4 Premium
							 SELECT distinct e.User_Account_Id, e.User_Account_Ss_Code 	
								FROM EADW_CORE_PUB.ENTITLEMENT e    
								JOIN EADW_ADM_APP.PROJECT_DIM p
								ON p.edw_project_id = e.edw_project_id
								AND e.status_text IN ('ACTIVE', 'BANNED', 'PENDING')
								AND  p.master_ttl_name =  'BATTLEFIELD 4'
								and p.Project_Ttl_Name = 'BATTLEFIELD 4 PREMIUM'   --check this 
								AND e.Stndrd_Rptg_Entitlement_Tag_Cd IN ( 'PREMIUM_ACCESS' ) 
								AND e.grant_date between  '2013-03-01'  and  current_date 
								AND p.platform_code = 'PCWIN'    
								AND Revenue_Method_Name IN ( 'SUBSC' ) 
							  ) b 					
							ON a.User_Account_Id = b.User_Account_Id
							AND a.user_account_ss_code = b.user_account_ss_code
						WHERE b.User_Account_Id is null 				
					) b		
						on a.User_account_Id = b.User_account_Id 
						and a.User_Account_Ss_Code = b.User_Account_Ss_Code
				JOIN ORIGIN_PUB.ORIGIN_GEOGRAPHY geo
					 on a.Country_Code = geo.Country_Code	
		 ) c
group by 1 		


SELECT distinct e.User_Account_Id, e.User_Account_Ss_Code 	
	FROM origin_pub.origin_users OU
	JOIN EADW_CORE_PUB.ENTITLEMENT e    
		on e.user_account_id = OU.user_account_id
		and e.user_account_ss_code = OU.user_account_ss_code	
	JOIN EADW_ADM_APP.PROJECT_DIM p
		ON p.edw_project_id = e.edw_project_id
	where e.status_text IN ('ACTIVE', 'ACTIVE ')
	AND  p.master_ttl_name =  'BATTLEFIELD 4'
	and p.Project_Ttl_Name = 'BATTLEFIELD 4 PREMIUM'   
	AND e.Stndrd_Rptg_Entitlement_Tag_Cd IN ( 'PREMIUM_ACCESS' ) 
	AND e.grant_date between  '2013-03-01'  and  current_date 
	AND p.platform_code = 'PCWIN'    
	AND Revenue_Method_Name IN ( 'SUBSC' ) 


SELECT distinct e.User_Account_Id, e.User_Account_Ss_Code 	
	FROM origin_pub.origin_users OU
	JOIN EADW_CORE_PUB.ENTITLEMENT e    
		on e.user_account_id = OU.user_account_id
		and e.user_account_ss_code = OU.user_account_ss_code	
	JOIN EADW_ADM_APP.PROJECT_DIM p
		ON p.edw_project_id = e.edw_project_id
	where e.status_text IN ('ACTIVE', 'ACTIVE ')
	AND  p.master_ttl_name =  'BATTLEFIELD 4' 
	AND e.Stndrd_Rptg_Entitlement_Tag_Cd = 'ONLINE_ACCESS'
	AND e.grant_date between  '2013-03-01'  and  current_date 
	AND p.platform_code = 'PCWIN'    
	AND Revenue_Method_Name IN ( 'DG FG', 'PG FG' ) 



===================================================

Select
	Master_Ttl_Name,
	Count(Distinct User_Account_Id) as UsersPlayed,
	Count(Source_Creation_Date) as NumDaysPlayed,
	((Sum(Cast(Non_Game_Duration as Decimal(38,0))) + Sum(Cast(Game_Play_Duration as Decimal(38,0)))) / 3600) as HoursPlayed
From
(
	SELECT
	A.User_Account_Id,
	Source_Creation_Date,
	Non_Game_Duration,
	Game_Play_Duration,
	Master_Ttl_Name
	FROM ActiveCombine A --Good idea to join a Cohort Group for your analysis so you know which users you're looking for
		JOIN EADW_ADM_APP.GAMER_HISTORY GH
			ON A.User_Account_Id = GH.User_Account_Id
		JOIN EADW_ADM_APP.PROJECT_DIM PD
			ON PD.Edw_Project_Id = GH.Edw_Project_Id
			AND PD.Platform_Code = 'PCWIN'		--PC only
	WHERE Source_Creation_Date >= (Current_Date - 90)
) x
Group by Master_Ttl_Name	

=====================================================

--Top 3 Items by ASP and Region
 Select  distinct Reporting_Region, 
		max(case when ranks = 1 then Master_Ttl_Name end)  item_ID_1,
		max(case when ranks = 1 then ASP end)  ASP_1,		
		max(case when ranks = 2 then Master_Ttl_Name end)  item_ID_2,
		max(case when ranks = 2 then ASP end)  ASP_2,
		max(case when ranks = 3 then Master_Ttl_Name end)  item_ID_3,
		max(case when ranks = 3 then ASP end)  ASP_3	
/*		max(case when ranks = 4 then Master_Ttl_Name end)  item_ID_4,
		max(case when ranks = 4 then ASP end)   ASP_4  */
From 
		(
		select a.*, rank() over (partition by Reporting_Region order by ASP DESC) as ranks
					 from 
							(
							Select Reporting_Region, Master_Ttl_Name, (sum( Gross_Bookings) / sum( Units) ) as ASP 
								from AJT_test
							Group By 1,2 
							) a 
			) b		
Group by 1 	
ORder by 1 

=====================================================

Create set volatile table Origin_TS4_gametime as
(
	select distinct e.User_Account_Id, e.User_Account_Ss_Code, min(Grant_Date) Grant_Date
		from EADW_CORE_PUB.ENTITLEMENT e
		join EADW_CORE_PUB.OFFER_ITEM_DIM PD
		on PD.Edw_Offer_Item_Id = e.Edw_Offer_Item_Id
		Join sandbox.origin_users b 
		on e.User_account_Id = b.User_account_Id 
		and e.User_Account_Ss_Code = b.User_Account_Ss_Code 
		where E.status_text IN ('ACTIVE  ', 'ACTIVE') 
		and Grant_Date between '2015-01-22' and current_date 
		and PD.Master_Ttl_Name = 'Sims 4'
		and PD.Platform_code = 'PCWIN'
		AND e.entitlement_tag_code = 'TRIAL_ONLINE_ACCESS' 
		and Source_System_Offer_Item_Id in ('Origin.OFR.50.0000589', 'Origin.OFR.50.0000588', 'Origin.OFR.50.0000587')
		Group By 1,2 
)
with data on commit preserve rows 


Select case when Date_Diff >= 30  then 'Active' 
		    when Date_Diff < 30  then 'Reactivated'  
		    when Date_Diff is null then 'New'
		else 'Other' 
			end Activity_Status,
		count(distinct a.user_account_id)			  
	from Origin_TS4_gametime a 
	left join 
		(Select distinct TS4.user_account_id, TS4.user_account_ss_code, TS4.Grant_Date, max(Event_Date) Max_Event_Date, (Grant_Date - Max_Event_Date) Date_Diff
				FROM Origin_TS4_gametime TS4 
					JOIN sandbox.origin_activity b   
						on b.user_account_id = TS4.user_account_id
						and b.user_account_ss_code = TS4.user_account_ss_code			
				where Event_Date < TS4.Grant_Date 
			group by 1,2,3
			) b 
	on b.user_account_id = a.user_account_id
	and b.user_account_ss_code = a.user_account_ss_code				
group by 1



===============Cross Over Origin Purchasers============

 --Origin franchise crossover
 --any type of purchase (eg full game, DLC, MTX)
select base.Franchise_Code, pivot.Franchise_Code, count(distinct base.user_account_id)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
from (          
SELECT distinct ORR.User_Account_Id, ORR.user_account_ss_code, oi.Franchise_Code 
from Origin_Pub.ORIGIN_REVENUE ORR 
join eadw_core_pub.offer_item_dim oi
on oi.Edw_Offer_Item_Id = ORR.Edw_Offer_Item_Id
where Valid_Order_Flag = 'Y'
and order_date between '2011-06-01' and current_date
and oi.Franchise_Code IN (  'Battlefield', 'The Sims', 'SimCity', 'Star Wars', 'New IP - Internal Tracking', 'Mass Effect', 'FIFA', 'Crysis', 'Need for Speed',
'Dead Space', 'Command and Conquer', 'Medal of Honor', 'Dragon Age', 'Spore', 'Titanfall', 'Plants vs Zombies', 'FIFA MANAGER' )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
) base                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
JOIN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
(                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
SELECT distinct ORR.User_Account_Id, ORR.user_account_ss_code, oi.Franchise_Code 
from Origin_Pub.ORIGIN_REVENUE ORR 
join eadw_core_pub.offer_item_dim oi
on oi.Edw_Offer_Item_Id = ORR.Edw_Offer_Item_Id
where Valid_Order_Flag = 'Y'
and order_date between '2011-06-01' and current_date
and oi.Franchise_Code IN (  'Battlefield', 'The Sims', 'SimCity', 'Star Wars', 'New IP - Internal Tracking', 'Mass Effect', 'FIFA', 'Crysis', 'Need for Speed',
'Dead Space', 'Command and Conquer', 'Medal of Honor', 'Dragon Age', 'Spore', 'Titanfall', 'Plants vs Zombies', 'FIFA MANAGER' ) 
) pivot                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
on base.user_account_id = pivot.user_account_id  
and base.user_account_ss_code = pivot.user_account_ss_code  
group by 1,2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
order by 1,2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               

================Average Entitlements================

--5.89
Select average(Entitlement_Count) 
	from 
	( Select distinct User_Account_Id, User_Account_Ss_Code, count(distinct master_ttl_name) as Entitlement_Count 
			From 
			( Select distinct PA.User_Account_Id, PA.User_Account_Ss_Code, master_ttl_name
			From EATRM_Views.LINK_PROD_ASSOC	PA
					Join EADW_ADM_APP.PROJECT_DIM	  PD
						On PA.Edw_Project_Id = PD.Edw_Project_Id
								Where PA.Product_Owner = 'Y' 
									and PD.Platform_Code = 'PCWIN'
									and  User_Account_Id IN (Select User_Account_Id from AJT_TOWN_LIFE_SP_ent_2 ) --users that entitled T L during the give away 
									and  master_ttl_name IN ( 
									'SIMS 3',
										 'SIMS 3 WORLD ADVENTURES (EP1)',
										 'SIMS 3 AMBITIONS (EP2)',
										 'SIMS 3 LATE NIGHT (EP3)',
										 'SIMS 3 GENERATIONS (EP4)',
										 'SIMS 3 PETS (EP5)',
										 'SIMS 3 SHOWTIME (EP6)',
										 'SIMS 3 SUPERNATURAL (EP7)',
										 'SIMS 3 SEASONS (EP8)',
										 'SIMS 3 UNIVERSITY LIFE (EP9)',
										 'SIMS 3 ISLAND PARADISE (EP10)',
										 'SIMS 3 INTO THE FUTURE (EP11)',
										 'SIMS 3 HIGH-END LOFT STUFF (SP1)',
										 'SIMS 3 FAST LANE STUFF (SP2)',
										 'SIMS 3 OUTDOOR LIVING STUFF (SP3)',
										 'SIMS 3 TOWN LIFE STUFF (SP4)',
										 'SIMS 3 MASTER SUITES STUFF (SP5)',
										 'SIMS 3 KATY PERRY SWEET TREATS (SP6)',
										 'SIMS 3 DIESEL STUFF (SP7)',
										 'SIMS 3 70S, 80S & 90S STUFF (SP8)',
										 'SIMS 3 MOVIE STUFF (SP9)',
										 'SIMS 3 HIDDEN SPRINGS',
										'THE SIMS 3 DRAGON VALLEY',
										'SIMS 3 MONTE VISTA', 
										'SIMS 3 BARNACLE BAY' ) 	
			) base 
			Group By 1,2 			
	) Base_1
