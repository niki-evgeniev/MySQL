CREATE TABLE students
(
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(50)
);

CREATE TABLE exams
(
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    name    VARCHAR(50)
);

ALTER TABLE exams
    AUTO_INCREMENT = 101;

CREATE TABLE students_exams
(
    student_id INT,
    exam_id    INT,
    CONSTRAINT pk_order PRIMARY KEY (student_id, exam_id),
    CONSTRAINT fk_order_students
        FOREIGN KEY (student_id)
            REFERENCES students (student_id),
    CONSTRAINT fk_order_exams
        FOREIGN KEY (exam_id)
            REFERENCES exams (exam_id)
);

INSERT INTO exams (name) VALUES
                             ('Spring MVC'),
                             ('Neo4j'),
                             ('Oracle 11g');
INSERT INTO students (name) VALUES
                                ('Mila'),
                                ('Toni'),
                                ('Ron');

INSERT INTO students_exams (student_id, exam_id) VALUES
                                                     (1, 101),
                                                     (1, 102),
                                                     (2, 101),
                                                     (3, 103),
                                                     (2, 102),
                                                     (2, 103);


