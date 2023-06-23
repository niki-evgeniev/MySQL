select 
 user_name, 
 SUBSTRING_INDEX(email, '@', -1) as `email provider`
from users
order by `email provider`, `user_name`;