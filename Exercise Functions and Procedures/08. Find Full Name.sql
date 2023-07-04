DELIMITER //
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
    SELECT CONCAT_WS(' ', first_name, last_name) AS full_name
    FROM account_holders
    ORDER BY first_name, id;
end //
DELIMITER ;

CALL usp_get_holders_full_name();
