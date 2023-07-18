Alter table users
    modify column last_login_time DATETIME DEFAULT now();