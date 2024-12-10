

Select 
      d.name as Department 
    , e.name as Employee 
    , e.salary as Salary 
    from Employee e 
     join (SELECT
                  DepartmentId
                , MAX(Salary) dep_max_sal
                FROM Employee
            GROUP BY DepartmentId
          ) dms 
          on e.DepartmentId = dms.DepartmentId
          and e.salary = dms.dep_max_sal
    left join Department d 
        on e.DepartmentId = d.id 



Select 
      d.name as Department 
    , e.name as Employee
    , e.salary as Salary
    from Employee e
    left join (Select
                      DepartmentId
                    , salary
                    , rank() over(partition by DepartmentId
                                  order by Salary) salary_rank 
                    FROM Employee e 
                ) r 
                on e.DepartmentId = r.DepartmentId 
                and e.salary = r.salary
    left join Department d 
        on e.DepartmentId = d.id           
    Where r.salary_rank >= 3    