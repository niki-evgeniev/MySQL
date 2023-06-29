SET GLOBAL log_bin_trust_function_creators = 1;
SET SQL_SAFE_UPDATES = 0;

#01.	Table Design

CREATE TABLE countries
(
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE cities
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(40) not null UNIQUE,
    population int,
    country_id INT         NOT NULL,
    CONSTRAINT fk_cities_countries
       FOREIGN KEY (country_id)
            REFERENCES countries (id)
);

CREATE TABLE universities
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(60)    NOT NULL UNIQUE,
    address         VARCHAR(80)    NOT NULL UNIQUE,
    tuition_fee     DECIMAL(19, 2) NOT NULL,
    number_of_staff INT,
    city_id         INT,
    CONSTRAINT fk_universities_cities
        FOREIGN KEY (city_id)
            REFERENCES cities (id)
);

CREATE TABLE students
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(40)  NOT NULL,
    last_name    VARCHAR(40)  NOT NULL,
    age          INT,
    phone        VARCHAR(20)  NOT NULL UNIQUE,
    email        VARCHAR(255) NOT NULL UNIQUE,
    is_graduated TINYINT(1)   NOT NULL,
    city_id      INT,
    CONSTRAINT fk_students_cities
        FOREIGN KEY (city_id)
            REFERENCES cities (id)
);

CREATE TABLE courses
(
    id             INT PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(40) NOT NULL UNIQUE,
    duration_hours DECIMAL(19, 2),
    start_date     DATE,
    teacher_name   VARCHAR(60) NOT NULL UNIQUE,
    description    TEXT,
    university_id  INT,
    CONSTRAINT fk_courses_universities
        FOREIGN KEY (university_id)
            REFERENCES universities (id)
);

CREATE TABLE students_courses
(
    grade      DECIMAL(19, 2) NOT NULL,
    student_id INT            NOT NULL,
    course_id  INT            NOT NULL,
    CONSTRAINT fk_students_courses_students
       FOREIGN KEY (student_id)
            REFERENCES students (id),
    CONSTRAINT fk_students_courses_courses
        FOREIGN KEY (course_id)
            REFERENCES courses (id)
);

#02.	Insert

SELECT CONCAT(c.teacher_name, ' ', 'course'),
       CHAR_LENGTH(name) / 10,
       DATE_ADD(start_date, INTERVAL 5 DAY),
       REVERSE(teacher_name),
       CONCAT('Course ', teacher_name, REVERSE(description)),
       start_date
FROM courses as c
WHERE c.id <= 5;

SELECT CONCAT('Course ', teacher_name, REVERSE(description))
FROM courses;

INSERT INTO courses(name, duration_hours, start_date, teacher_name, description, university_id)
    (SELECT CONCAT(c.teacher_name, ' ', 'course'),
            CHAR_LENGTH(name) / 10,
            DATE_ADD(start_date, INTERVAL 5 DAY),
            REVERSE(teacher_name),
            CONCAT('Course ', teacher_name, REVERSE(description)),
            DAY(c.start_date)
     FROM courses as c
     WHERE c.id <= 5);

#03.	Update

SELECT *
FROM universities
WHERE id BETWEEN 5 AND 12;

UPDATE universities
SET tuition_fee = tuition_fee + 300
WHERE id BETWEEN 5 AND 12;

#04.	Delete

SELECT *
FROM universities
WHERE number_of_staff IS NULL;

DELETE
FROM universities AS w
WHERE number_of_staff IS NULL;

#05.	Cities

SELECT *
FROM cities
ORDER BY population DESC;

#06.	Students age

SELECT first_name,
       last_name,
       age,
       phone,
       email
FROm students
WHERE AGE >= 21
ORDER BY first_name DESC, email, id
LIMIT 10;

#07.	New students

SELECT *
FROM students
         left join students_courses sc on students.id = sc.student_id;
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
       SUBSTRING(email, 2, 10)            AS username,
       REVERSE(phone)                     as password
FROM students
         left join students_courses sc on students.id = sc.student_id
WHERE grade IS NULL
ORDER BY password DESC;

#08.	Students count

SELECT count(student_id) as students_count,
       u.name            as university_name
FROM students_courses
         join courses c on c.id = students_courses.course_id
         join universities u on u.id = c.university_id
GROUP BY u.name
HAVING students_count >= 8
ORDER BY students_count DESC, university_name DESC;

#09.	Price rankings

SELECT u.name,
       c.name,
       u.address,
       (CASE
            WHEN u.tuition_fee < 800 THEN 'cheap'
            WHEN u.tuition_fee < 1200 THEN 'normal'
            WHEN u.tuition_fee < 2500 THEN 'high'
            ELSE 'expensive'
           end) as price_rank,
       u.tuition_fee
FROM universities as u
         join cities c on c.id = u.city_id
ORDER BY tuition_fee;

#10.	Average grades

SELECT AVG(sc.grade)
FROM courses as c
         join students_courses sc on c.id = sc.course_id
         join students s on sc.student_id = s.id
where name = 'Quantum Physics'
  AND is_graduated = 1
GROUP BY c.id;

DELIMITER //

CREATE FUNCTION udf_average_alumni_grade_by_course_name(course_name VARCHAR(60))
    RETURNS DECIMAL(20, 2)
    RETURN (SELECT AVG(sc.grade)
            FROM courses as c
                     join students_courses sc on c.id = sc.course_id
                     join students s on sc.student_id = s.id
            where name = course_name
              AND is_graduated = 1
            GROUP BY c.id);

DELIMITER ;


SELECT c.name, udf_average_alumni_grade_by_course_name('Quantum Physics') as average_alumni_grade
FROM courses c
WHERE c.name = 'Quantum Physics';

#11.	Graduate students

DELIMITER //
CREATE PROCEDURE udp_graduate_all_students_by_year(year_started INT)
BEGIN
    UPDATE students as s
        JOIN students_courses sc2 on s.id = sc2.student_id
        JOIN courses c2 on sc2.course_id = c2.id
    SET is_graduated = 1
    WHERE YEAR(start_date) = year_started
      AND c2.id = sc2.course_id
      AND s.id = sc2.student_id;
end //

SELECT *
FROM courses
         JOIN students_courses sc on courses.id = sc.course_id
         JOIN students s on sc.student_id = s.id
WHERE YEAR(start_date) = '2017';
