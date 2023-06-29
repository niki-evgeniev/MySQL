#1.	Table Design

create table players_coaches
(
    player_id int,
    coach_id  int,
    PRIMARY KEY (player_id, coach_id)
);

create table players
(
    id             int primary key auto_increment,
    first_name     VARCHAR(10)              not null,
    last_name      VARCHAR(20)              not null,
    age            int            default 0 not null,
    position       char(1)                  not null,
    salary         DECIMAL(10, 2) default 0 not null,
    hire_date      DATETIME,
    skills_data_id int                      not null,
    team_id        int
);

create table coaches
(
    id          int primary key auto_increment,
    first_name  VARCHAR(10)              not null,
    last_name   VARCHAR(20)              not null,
    salary      decimal(10, 2) default 0 not null,
    coach_level int            default 0 not null
);

create table skills_data
(
    id        int primary key auto_increment,
    dribbling int default 0,
    pace      int default 0,
    passing   int default 0,
    shooting  int default 0,
    speed     int default 0,
    strength  int default 0
);

create table teams
(
    id          int primary key auto_increment,
    name        varchar(45)          not null,
    established DATE                 not null,
    fan_base    bigint(20) default 0 not null,
    stadium_id  int                  not null
);

create table stadiums
(
    id       int primary key auto_increment,
    name     varchar(45) not null,
    capacity int         not null,
    town_id  int         not null
);

create table towns
(
    id         int primary key auto_increment,
    name       varchar(45) not null,
    country_id int         not null
);

create table countries
(
    id   int primary key auto_increment,
    name varchar(45) not null
);

ALTER table players
    ADD CONSTRAINT fk_player_teams
        FOREIGN KEY (team_id)
            REFERENCES teams (id),
    add constraint fk_pl_skills_data
        foreign key (skills_data_id)
            references skills_data (id);

ALTER TABLE players_coaches
    add constraint fk_players_coaches_players
        foreign key (player_id)
            references players (id),
    add constraint fk_players_coaches_coaches
        foreign key (coach_id)
            references coaches (id);

ALTER TABLE teams
    add constraint fk_teams_stadiums
        foreign key (stadium_id)
            references stadiums (id);

ALTER table stadiums
    add constraint fk_stadium_towns
        foreign key (town_id)
            references towns (id);

ALTER TABLE towns
    add constraint fk_towns_countries
        foreign key (country_id)
            references countries (id);

#2.	Insert

SELECT first_name,
       last_name,
       salary * 2,
       CHAR_LENGTH(first_name)
from players
where age >= 45;

insert into coaches(first_name, last_name, salary, coach_level)
    (SELECT first_name,
            last_name,
            salary * 2,
            CHAR_LENGTH(first_name)
     from players
     where age >= 45);

#3.	Update

UPDATE coaches as c
SET coach_level = coach_level + 1
WHERE (SELECT pc.coach_id
       from players_coaches as pc
       where first_name like 'A%'
         AND c.id = pc.coach_id
       group by c.id);

#04. Delete

DELETE
FROM players
WHERE age >= 45;

#05. Players

SELECT first_name, age, salary
FROM players
order by salary DESC;

#6.	Young offense players without contract

SELECT p.id,
       concat(p.first_name, ' ', p.last_name) AS full_name,
       p.age,
       p.position,
       p.hire_date
FROM players as p
         join skills_data sd on p.skills_data_id = sd.id
where p.age < 23
  AND p.position = 'A'
  AND p.hire_date IS NULL
  AND sd.strength > 50
ORDER BY p.salary, p.age;

#7.	Detail info for all teams

SELECT t.name              AS name,
       t.established       as established,
       t.fan_base          as fan_base,
       count(t.stadium_id) as players_count
FROM teams as t
         join players as p on t.id = p.team_id
group by p.team_id
ORDER BY players_count desc, t.fan_base desc;

#8.	The fastest player by towns

SELECT speed,
       t2.name
FROM skills_data AS sd
         join players p on sd.id = p.skills_data_id
         join teams t on p.team_id = t.id
         join stadiums s on t.stadium_id = s.id
         join towns t2 on s.town_id = t2.id
where t.name != 'Devify'
group by speed;

select * from players
 join skills_data sd on sd.id = players.skills_data_id
group by sd.speed




