DELIMITER //
CREATE FUNCTION ufn_get_salary_level(salary_level DECIMAL(20, 2))
    RETURNS VARCHAR(10)
    RETURN (
        CASE
            WHEN salary_level < 30000 THEN 'Low'
            WHEN salary_level <= 50000 THEN 'Average'
            WHEN salary_level > 50000 THEN 'High'
            END
        );
DELIMITER ;

SELECT ufn_get_salary_level(30000);
SELECT ufn_get_salary_level(13500);
SELECT ufn_get_salary_level(50001);
