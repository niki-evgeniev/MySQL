#1.	Table Design

CREATE TABLE addresses
(
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name varchar(100) not null
);

create table categories
(
    id   int primary key auto_increment,
    name varchar(10) not null
);

create table clients
(
    id           int primary key auto_increment,
    full_name    varchar(50) not null,
    phone_number varchar(20) not null
);

create table drivers
(
    id         int primary key auto_increment,
    first_name varchar(30) not null,
    last_name  varchar(30) not null,
    age        int         not null,
    rating     FLOAT DEFAULT 5.5
);

create table cars
(
    id          int primary key auto_increment,
    make        varchar(20)   not null,
    model       varchar(20),
    year        int default 0 not null,
    mileage     int default 0,
    `condition` CHAR(1)       not null,
    category_id INT           not null,
    constraint fk_cars_categories
        foreign key (category_id)
            references categories (id)
);
create table courses
(
    id              int primary key auto_increment,
    from_address_id int      not null,
    start           DATETIME not null,
    bill            decimal(10, 2) default 10,
    car_id          int      not null,
    client_id       int      not null,
    constraint fk_courses_addreses
        foreign key (from_address_id)
            references addresses (id),
    constraint fk_courses_cars
        foreign key (car_id)
            references cars (id),
    constraint fk_courses_clients
        foreign key (client_id)
            references clients (id)
);

CREATE TABLE cars_drivers
(
    car_id    int not null,
    driver_id int not null,
    PRIMARY KEY (car_id, driver_id),
    constraint fk_car_drivers_cars
        foreign key (car_id)
            references cars (id),
    constraint fk_car_drivers_drivers
        foreign key (driver_id)
            references drivers (id)
);

#2.	Insert

#test
select concat(first_name, ' ', last_name),
       concat('(088) 9999', d.id * 2)
from drivers as d
WHERE id BETWEEN 10 AND 20;

SELECT *
from clients;

#submit
INSERT INTO clients (full_name, phone_number)
    (select concat(first_name, ' ', last_name),
            concat('(088) 9999', d.id * 2)
     from drivers as d
     WHERE id BETWEEN 10 AND 20);

#03. Update

#test

SELECT *
from cars as c
where c.year <= '2010'
  AND (c.mileage >= 800000
    or c.mileage is null)
  AND c.make != 'Mercedes-Benz';

select COUNT(*)
from cars
where `condition` = 'C';

#submit
update cars as c
set `condition` = 'C'
where c.year <= '2010'
  AND (c.mileage >= 800000
    or c.mileage is null)
  AND c.make != 'Mercedes-Benz';

#4.	Delete

select *
from clients
         left join courses c on clients.id = c.client_id
where bill is null
  and char_length(full_name) > 3;

delete cl
from clients AS cl
         left join courses c on cl.id = c.client_id
where bill is null
  and char_length(full_name) > 3;

#5.	Cars

select make,
       model,
       `condition`
from cars
order by id;

#6.	Drivers and Cars

select first_name, last_name, c.make, c.model, c.mileage
from drivers
         join cars_drivers cd on drivers.id = cd.driver_id
         join cars c on cd.car_id = c.id
where c.mileage IS NOT NULL
order by c.mileage desc, first_name asc;

#7.	Number of courses for each car
#############################
# select c2.car_id, c.make, c.mileage, count(c2.car_id) as count_of_courses, ROUND(AVG(c2.bill), 2) as avg_bill
# from cars as c
#          join courses as c2 on c.id = c2.car_id
# group by c.id
# having count_of_courses != 2
# order by count_of_courses desc, c.id;
##############################
select c.id, c.make, c.mileage, count(c2.bill) as count_of_courses, ROUND(AVG(c2.bill), 2) as avg_bill
from cars as c
         left join courses as c2 on c.id = c2.car_id
group by c.id
having count_of_courses != 2
order by count_of_courses desc, c.id;

#8.	Regular clients
select cl.full_name, count(c.bill) as count_of_cars, SUM(c.bill)
from clients AS cl
         join courses c on cl.id = c.client_id
where cl.full_name like '_a%'
group by cl.full_name
having count_of_cars > 1
order by cl.full_name;

#9.	Full information of courses

select *
from courses
where DAY(start) between 6 AND 20;

select a.name   as name,
       (case
            WHEN HOUR(start) between 6 AND 20 THEN 'Day'
#     WHEN HOUR(start) between 5 AND 21 THEN 'Night'
            ELSE 'Night'
           end) as day_time,
       c.bill,
       c2.full_name,
       c3.make,
       c3.model,
       c4.name  as category_name
from courses as c
         join addresses a on a.id = c.from_address_id
         join clients c2 on c2.id = c.client_id
         join cars c3 on c.car_id = c3.id
         join categories c4 on c3.category_id = c4.id
order by c.id;

################################################
select a.name                                             as name,
       (IF(HOUR(start) between 6 AND 20, 'Day', 'Night')) as day_time,
       c.bill,
       c2.full_name,
       c3.make,
       c3.model,
       c4.name                                            as category_name
from courses as c
         join addresses a on a.id = c.from_address_id
         join clients c2 on c2.id = c.client_id
         join cars c3 on c.car_id = c3.id
         join categories c4 on c3.category_id = c4.id
order by c.id;

#10.	Find all courses by client’s phone number

select count(full_name) as count
from clients as cl
         join courses c on cl.id = c.client_id
where phone_number = '(704) 2502909'
group by cl.full_name;

CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR(20))
    RETURNS int
    return (select count(full_name) as count
            from clients as cl
                     join courses c on cl.id = c.client_id
            where phone_number = phone_num
            group by cl.full_name);

SELECT udf_courses_by_client('(803) 6386812') as `count`;
SELECT udf_courses_by_client('(831) 1391236') as `count`;
SELECT udf_courses_by_client('(704) 2502909') as `count`;

#11.	Full info for address



DELIMITER //
CREATE PROCEDURE udp_courses_by_address (address_name VARCHAR(100))
BEGIN
    select a.name as name,
           c2.full_name,
           (case
                when c.bill <= 20 then 'Low'
                when c.bill <= 30 then 'Medium'
                else 'High'
               end) as level_of_bill,
           c3.make,
           c3.condition as 'condition',
           c4.name as cat_name
    from courses as c
             join addresses a on a.id = c.from_address_id
             join clients c2 on c2.id = c.client_id
             join cars c3 on c3.id = c.car_id
             join categories c4 on c3.category_id = c4.id
    where a.name = address_name
    order by c3.make,c2.full_name;
end //

DELIMITER ;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');