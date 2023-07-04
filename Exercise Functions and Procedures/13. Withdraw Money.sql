DELIMITER //
CREATE PROCEDURE usp_withdraw_money(
    account_id INT, money_amount DECIMAL(19, 4))
BEGIN
    IF money_amount > 0 THEN
        START TRANSACTION;

        UPDATE `accounts` AS a
        SET a.balance = a.balance - money_amount
        WHERE a.id = account_id;

        IF (SELECT a.balance
            FROM `accounts` AS a
            WHERE a.id = account_id) < 0
        THEN
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //
DELIMITER ;

CALL usp_withdraw_money(1, 10);

SELECT a.id AS 'account_id',
       a.account_holder_id,
       a.balance
FROM `accounts` AS a
WHERE a.id = 1;

DROP PROCEDURE IF EXISTS usp_withdraw_money;