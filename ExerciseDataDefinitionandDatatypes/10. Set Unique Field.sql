ALTER TABLE users
    drop primary key,
    add constraint pk_users
        primary key users (id),
    change column username
        username varchar(30) unique;