
EXTRACT
DATEDIFF(a.RecordDate, b.RecordDate) = 1

DATEDIFF(year, '2017/08/25', '2011/08/25') AS DateDiff;
DATEDIFF(hour, '2017/08/25 07:00', '2017/08/25 12:45') AS DateDiff;

    
DATE_ADD, DATE_SUB
DATE_TRUNC


POSITION('A' IN descript) AS a_position

STRPOS(descript, 'A') AS a_position


-- https://database.guide/how-make_date-works-in-postgresql/


MAKEDATE(year, day)
SELECT MAKEDATE(2017, 175);
SELECT CONCAT("SQL ", "Tutorial ", "is ", "fun!") AS ConcatenatedString;


DATEDIFF(date1, date2)
Parameter Description
date1, date2  Required. Two dates to calculate the number of days between. (date1 - date2)


TIMESTAMPDIFF(MINUTE, start_dt, end_dt) as duration_minutes
SELECT DATE_ADD("2017-06-15", INTERVAL 10 DAY);
SELECT DATE_ADD("2017-06-15 09:34:21", INTERVAL -3 HOUR);
SELECT DATE_ADD("2017-06-15 09:34:21", INTERVAL 15 MINUTE);


https://www.w3schools.com/sql/func_mysql_date_format.asp

DATE_FORMAT(trans_date, '%Y-%m') AS month, 
DATE_FORMAT("2017-06-15", "%Y")


https://mode.com/sql-tutorial/sql-string-functions-for-cleaning

SELECT cleaned_date,
       EXTRACT('year'   FROM cleaned_date) AS year,
       EXTRACT('month'  FROM cleaned_date) AS month,
       EXTRACT('day'    FROM cleaned_date) AS day,
       EXTRACT('hour'   FROM cleaned_date) AS hour,
       EXTRACT('minute' FROM cleaned_date) AS minute,
       EXTRACT('second' FROM cleaned_date) AS second,
       EXTRACT('decade' FROM cleaned_date) AS decade,
       EXTRACT('dow'    FROM cleaned_date) AS day_of_week
  FROM tutorial.sf_crime_incidents_cleandate


SELECT incidnt_num,
   day_of_week,
   LEFT(date, 10) AS cleaned_date,
   CONCAT(day_of_week, ', ', LEFT(date, 10)) AS day_and_date
FROM tutorial.sf_crime_incidents_2014_01


SELECT incidnt_num,
   date,
   LEFT(date, 10) AS cleaned_date,
   RIGHT(date, 17) AS cleaned_time
FROM tutorial.sf_crime_incidents_2014_01


SELECT incidnt_num,
       descript,
       COALESCE(descript, 'No Description')
  FROM tutorial.sf_crime_incidents_cleandate
 ORDER BY descript DESC
