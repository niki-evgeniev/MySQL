DELIMITER //
CREATE PROCEDURE usp_get_towns_starting_with(town_start_with VARCHAR(1))
BEGIN
    SELECT name as town_name
    FROM towns
    WHERE name Like CONCAT(town_start_with, '%')
    ORDER BY town_name;
end //
DELIMITER ;

CALL usp_get_towns_starting_with('b');