CREATE TABLE people
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(200) NOT NULL,
    picture   BLOB,
    height    DOUBLE(5, 2),
    weight    DOUBLE(5, 2),
    gender    CHAR(1)      NOT NULL,
    birthdate DATE         NOT NULL,
    biography TEXT
);
insert into people(name, gender, birthdate)
values ('Test1', 'm', DATE(now())),
       ('Test2', 'f', DATE(now())),
       ('Test3', 'm', DATE(now())),
       ('Test4', 'f', DATE(now())),
       ('Test5', 'm', DATE(now()));