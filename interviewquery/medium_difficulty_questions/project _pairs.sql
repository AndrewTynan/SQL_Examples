/* https://www.interviewquery.com/questions/project-pairs */ 

/* Write a query to return pairs of projects where the end date of one project matches the start date of another project.  */ 

select 
    p1.title as project_title_end,
    p2.title as project_title_start,
    p1.end_date AS date
    from projects p1 
    join projects p2 
        on p1.id != p2.id 
        and date(p1.end_date) = date(p2.start_date) 
