
# Flight Records from interviewquery
# Write a query to create a new table, named flight routes, that displays unique pairs of two locations.
SELECT DISTINCT destination_one, destination_two
FROM
    (
            SELECT source_location as destination_one,
                destination_location as destination_two 
            FROM FLIGHTS
        UNION ALL
            SELECT destination_location, source_location
            FROM FLIGHTS
    ) a
WHERE destination_one <  destination_two



    case when DATE_FORMAT(start_date, "%M %Y") != 
              DATE_FORMAT(end_date, "%M %Y") then 'retained'
         else 'lapsed'
         end retained_status, 

