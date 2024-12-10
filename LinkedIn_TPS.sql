print('Hello world - Python!')

Member_id, Company, Year_Start
1, Microsoft, 2000
1, Google, 2006
1, Facebook, 2012
2, Microsoft, 2001
2, Oracle, 2004
2, Google, 2007

we can assume that for each member in each year, there is only one company

 1.How many members ever worked at Microsoft prior to working at Google?

Select 
    count(distinct a.Member_id) as count
    from employee_info a 
    join employee_info b
        on a.Member_id = b.Member_id
        and a.Company = 'Microsoft'
        and b.Company = 'Google'
        and a.Year_Start < b.Year_Start


microsoft = [] 
for i in employee_info[0][1]: 
    if Company == 'Microsoft':
        microsoft.append(employee_info[0][1][i])

Google = [] 
for i in employee_info: 
    if Company == 'Google':
        microsoft.append(i)

overlapped_employees = []
for i in microsoft: 
    if i in Google:
        overlapped_employees.append(i)


Question 2: How many members moved directly from Microsoft to Google? (Member 2 does not count since Microsoft -> Oracle -> Google)


Select 
    count(distinct Member_id) as count 
    from (Select 
                Member_id,
                Company,
                Year_Start,
                lag(Company, 1) over(partition by Member_id Order by Year_Start) as previous_company,
                lag(Member_id, 1) over(partition by Member_id Order by Year_Start) as previous_Member_id
            From employee_info 
          ) a 
   Where Company = 'Google' 
   And previous_company = 'Microsoft'
   and Member_id = previous_Member_id









