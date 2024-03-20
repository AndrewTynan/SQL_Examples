/* https://www.interviewquery.com/questions/closest-sat-scores */ 

/* 
Given a table of students and their SAT test scores, write a query to return the two students with the closest test scores with the score difference.
If there are multiple students with the same minimum score difference, select the student name combination that is higher in the alphabet. 
*/ 

select 
    s1.student as one_student,
    s2.student as other_student, 
    abs(s1.score - s2.score) as score_diff
    from scores s1 
    join scores s2 
        on s1.id != s2.id 
group by 1,2 
order by abs(s1.score - s2.score) asc,  s1.student, s2.student
limit 1 
