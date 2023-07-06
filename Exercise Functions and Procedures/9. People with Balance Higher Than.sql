DROP PROCEDURE usp_get_holders_with_balance_higher_than;
DELIMITER //
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(number DECIMAL(20, 4))
BEGIN
    SELECT ah.first_name, ah.last_name
    FROM account_holders AS ah
             JOIN accounts AS a on ah.id = a.account_holder_id
    GROUP BY ah.id
    HAVING SUM(a.balance) >= number
    ORDER BY ah.id;
end //

DELIMITER ;

CALL usp_get_holders_with_balance_higher_than(7000);