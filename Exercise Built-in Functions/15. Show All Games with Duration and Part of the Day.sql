select name AS games,
       case
           when hour(start) between 0 and 11 then 'Morning'
           when hour(start) between 12 and 17 then 'Afternoon'
           when hour(start) between 18 and 23 then 'Evening'
           end as 'Part of the day',
       case
           when duration <= 3 then 'Extra Short'
           when duration between 4 and 6 then 'Short'
           when duration between 7 and 10 then 'Long'
           when duration between 7 and 10 then 'Long'
           else 'Extra Long'
           end as 'Duration'

from games
order by name;