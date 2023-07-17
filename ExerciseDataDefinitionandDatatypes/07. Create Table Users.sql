CREATE TABLE users
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    username        VARCHAR(30) NOT NULL,
    password        VARCHAR(26) NOT NULL,
    profile_picture BLOB,
    last_login_time DATETIME,
    is_deleted      BOOLEAN
);

insert into users (username, password)
values ('username1', 'password6'),
       ('username2', 'password7'),
       ('username3', 'password8'),
       ('username4', 'password9'),
       ('username5', 'password11');