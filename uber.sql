
Tables

Table dim_merchant:

uuid: the UUID of the merchant (of type uuid);
eats_marketplace_fee: the commission rate Uber receives for every order (of type numeric);
eats_price_bucket: $, $$, or $$$ (of type text);
hexcluster_uuid: the UUID of the hexagon cluster that represents the merchant’s delivery zone (of type uuid);
is_active: boolean indicator of whether the merchant is still on Eats (of type boolean);
first_online_date: the first timestamp when the merchant was available to receive orders (of type int);
city_name: the city in which the merchant is located (of type text);
country_name: the country in which the merchant is located (of type text).
Table fact_eats_trip:

trip_uuid: of type uuid;
trip_date: the date the trip was requested (of type date);
trip_timestamp: the timestamp the trip was requested in UNIX seconds (of type int)
eater_delivery_fee_usd: of type int;
eater_surge_usd: of type int;
has_alcoholic_items: of type boolean;
is_curbside_dropoff: of type boolean;
is_completed: whether the delivery was successfully handed off to the eater (of type boolean);
is_cash_trip: whether the eater paid for the order with cash (of type boolean);
eater_uuid: of type uuid;
restaurant_uuid: of type uuid;
courier_uuid: of type uuid;
city_name: the city where the eater is located (of type text);
country_name: the country where the eater is located (of type text).
Table fact_trip_ratings:

trip_uuid: of type uuid;
reviewer: who submitted the rating - eater, courier, or restaurant (of type text);
subject: who the rating describes - eater, courier, or restaurant (of type text);
review_type: “stars” or “thumbs up” (of type text);
value: 1-5 for stars, 0-1 for thumbs up (of type int).
Queries

Queries to implement:

How many active restaurants are in each city?
How many active restaurants completed fewer than 5 trips per city?
What are the top 3 restaurants in each city by rating?
What was each restaurant’s average rating at the end of their 10th trip?

WITH cte as ( 
Select 
    m.uuid as merchant_uuid, 
    m.city_name,
    coalesce(count(distinct et.trip_uuid),0) as completed_trips
    from dim_merchant m 
    left join fact_eats_trip et 
        on et.restaurant_uuid = m.uuid 
        and et.is_completed is True 
    Where m.is_active is True 
group by 1,2     
having count(distinct et.trip_uuid) < 5 
) 
Select 
    city_name, 
    coalesce(count(disitnct merchant_uuid),0) as merchant_uuid_count 
    From cte     
group by city_name


With cte as ( 
Select 
    t.city_name, 
    restaurant_uuid, 
    avg(value) as avg_value 
    From fact_trip_ratings r 
    join fact_eats_trip t 
        on r.trip_uuid = t.trip_uuid
    Where reviewer = 'eater'
    and review_type = 'stars'
group by 1,2 
) 
, cte2 as ( 
Select 
    city_name, 
    restaurant_uuid, 
    avg_value, 
    row_number() over(partition by city_name
                      order by avg_value desc) as rk 
    From cte 
) 
Select 
    city_name, 
    restaurant_uuid,
    avg_value
    From cte2 
    Where rk <= 3 
        