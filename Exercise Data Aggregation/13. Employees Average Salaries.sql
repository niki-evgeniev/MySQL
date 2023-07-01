CREATE TABLE new_salary AS
SELECT *
FROM employees
WHERE salary > 30000;

DELETE FROM new_salary
WHERE manager_id = 42;

UPDATE new_salary
SET salary = salary + 5000
WHERE department_id = 1;

SELECT department_id, AVG(salary) FROM new_salary
GROUP BY department_id
ORDER BY department_id ASC ;