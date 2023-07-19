SELECT e.employee_id,
       e.first_name,
       e.manager_id,
       d.first_name
FROM employees AS e
         JOIN
     employees AS d ON e.manager_id = d.employee_id
WHERE e.manager_id IN (3, 7)
ORDER BY e.first_name;