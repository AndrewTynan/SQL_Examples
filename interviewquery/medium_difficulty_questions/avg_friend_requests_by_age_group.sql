/* https://www.interviewquery.com/questions/avg-friend-requests-by-age-group */ 

/* 
Let’s say you’re working for a social media company trying to grow your user base. You know that people tend to use the same social network as their peers, 
so you want to target all your growth and marketing efforts on specific age groups so as to take advantage of network effects.

You wish to begin with the age group that is currently generating the most connections (fastest growing).

Write a SQL query to find the average number of accepted friend requests for each age group and order the results in descending order.

Note: The average number of accepted friend requests is calculated as the total number of friend requests sent by an age group that was accepted divided by the number of members in said age group.
We can assume the tables hold valid data in that there are no duplicate friend requests, friend requests are only accepted once, and user A can only accept a friend request from User B after B sends A a friend request.

The result should be rounded to two decimal places.
*/ 

SELECT 
    age_group,
       ROUND(COUNT(requester_id)/
             COUNT(DISTINCT user_id), 2) AS average_acceptance
FROM age_groups a 
LEFT JOIN requests_accepted r 
    ON a.user_id = r.requester_id
GROUP BY age_group
ORDER BY average_acceptance DESC
