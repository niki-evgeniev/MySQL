SET GLOBAL log_bin_trust_function_creators = 1;
SET SQL_SAFE_UPDATES = 0;

#01
CREATE DATABASE exam15october2022;
CREATE TABLE products
(
    id    INT PRIMARY KEY AUTO_INCREMENT,
    name  VARCHAR(30)    NOT NULL UNIQUE,
    type  VARCHAR(30)    NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE clients
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    birthdate  DATE        NOT NULL,
    card       VARCHAR(50),
    review     TEXT
);

CREATE TABLE tables
(
    id       INT PRIMARY KEY AUTO_INCREMENT,
    floor    INT NOT NULL,
    reserved TINYINT(1),
    capacity INT NOT NULL
);

CREATE TABLE waiters
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(50) NOT NULL,
    phone      VARCHAR(50),
    salary     DECIMAL(10, 2)
);

CREATE TABLE orders
(
    id           INT PRIMARY KEY AUTO_INCREMENT,
    table_id     INT  NOT NULL,
    waiter_id    INT  NOT NULL,
    order_time   TIME NOT NULL,
    payed_status TINYINT(1),
    CONSTRAINT fk_orders_tables
        FOREIGN KEY (table_id)
            REFERENCES tables (id),
    CONSTRAINT fk_orders_waiters
        FOREIGN KEY (waiter_id)
            REFERENCES waiters (id)
);

CREATE TABLE orders_clients
(
    order_id  INT,
    client_id INT,
    CONSTRAINT fk_oc_orders
        FOREIGN KEY (order_id)
            REFERENCES orders (id),
    CONSTRAINT fk_oc_clients
        FOREIGN KEY (client_id)
            REFERENCES clients (id)

);

CREATE TABLE orders_products
(
    order_id   INT,
    product_id INT,
    CONSTRAINT fk_op_orders
        FOREIGN KEY (order_id)
            REFERENCES orders (id),
    CONSTRAINT fk_op_products
        FOREIGN KEY (product_id)
            REFERENCES products (id)
);

#02.	Insert

SELECT COUNT(*)
FROM products;

INSERT INTO products(name, type, price)
    (SELECT CONCAT(last_name, ' ', 'specialty'),
            'Cocktail',
            CEILING(salary * 0.01)
     FROM waiters
     WHERE id > 6);

#03.	Update

SELECT *
FROM orders
WHERE id BETWEEN 12 AND 23;

UPDATE orders
SET table_id = table_id - 1
WHERE id BETWEEN 12 AND 23;

#04.	Delete

SELECT w.id,
       (SELECT COUNT(*) FROM orders where waiter_id = w.id) AS to_delete
FROM waiters AS w

HAVING to_delete = 0;

DELETE
FROM waiters AS w
WHERE (SELECT COUNT(*) FROM orders where waiter_id = w.id) = 0;

#05.	Clients

SELECT *
FROM clients
ORDER BY birthdate DESC, id DESC;

#06.	Birthdate

SELECT first_name,
       last_name,
       birthdate,
       review
FROM clients
WHERE card IS NULL
  AND YEAR(birthdate) BETWEEN '1978' AND '1993'
ORDER BY last_name DESC, id ASC
LIMIT 5;

#07.	Accounts

SELECT CONCAT(last_name, first_name, CHAR_LENGTH(first_name), 'Restaurant') AS username,
       REVERSE(SUBSTRING(email, 2, 12))                                     as password
FROM waiters
WHERE salary IS NOT NULL
ORDER BY password DESC;

#08.	Top from menu

SELECT id, name, COUNT(name) AS count
FROM products AS p
         JOIN orders_products AS op on p.id = op.product_id
GROUP BY p.name
HAVING count >= 5
ORDER BY count DESC, p.name ASC;

#09. Availability

SELECT t.id,
       t.capacity,
       COUNT(oc.order_id) AS count_clients,
       (CASE
            WHEN t.capacity > COUNT(oc.order_id) THEN 'Free seats'
            WHEN t.capacity = COUNT(oc.order_id) THEN 'Full'
            WHEN t.capacity < COUNT(oc.order_id) THEN 'Extra seats'
           END
           )
FROM tables as t
         JOIN orders AS o ON t.id = o.table_id
         JOIN orders_clients AS oc ON o.id = oc.order_id
WHERE floor = 1
GROUP BY t.id
ORDER BY t.id DESC;

#10.	Extract bill

DELIMITER //
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
    RETURNS DECIMAL
    RETURN (SELECT c.first_name,
                   c.last_name,
                   SUM(p.price) AS price
            FROM clients as c
                     JOIN orders_clients AS oc ON c.id = oc.client_id
                     JOIN orders AS o ON oc.order_id = o.id
                     JOIN orders_products AS op on o.id = op.order_id
                     JOIN products p on op.product_id = p.id
            WHERE first_name LIKE 'Silvio'
            GROUP BY c.id);
DELIMITER ;

SELECT c.first_name, c.last_name, udf_client_bill('Silvio Blyth') as 'bill'
FROM clients c
WHERE c.first_name = 'Silvio'
  AND c.last_name = 'Blyth';

#10 - 2 #####################################################

DELIMITER //
CREATE FUNCTION udf_client_bill2(full_name VARCHAR(50))
    RETURNS DECIMAL(20, 2)
    RETURN (SELECT SUM(p.price) AS bill
            FROM clients as c
                     JOIN orders_clients AS oc ON c.id = oc.client_id
                     JOIN orders AS o ON oc.order_id = o.id
                     JOIN orders_products AS op on o.id = op.order_id
                     JOIN products p on op.product_id = p.id
            WHERE CONCAT(first_name, ' ', last_name) LIKE full_name
            GROUP BY c.id);
DELIMITER ;

SELECT c.first_name, c.last_name, udf_client_bill2('Silvio Blyth') as 'bill'
FROM clients c
WHERE c.first_name = 'Silvio'
  AND c.last_name = 'Blyth';


#11.	Happy hour

# SELECT * FROM products
# WHERE price >= 10 AND type = 'Cognac'
# UPDATE price = price * 0.8;

# UPDATE products
# SET price = price * 0.8
# WHERE price >= 10
#   AND type = 'Cognac';

DELIMITER //
CREATE PROCEDURE udp_happy_hour(type_name VARCHAR(50))
BEGIN
    UPDATE products
    SET price = price * 0.8
    WHERE price >= 10
      AND type = type_name;

end //

DELIMITER ;

CALL udp_happy_hour ('Cognac');

SELECT * FROM products
WHERE type = 'Cognac';
