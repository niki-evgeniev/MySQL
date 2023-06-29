#01.	Table Design

CREATE TABLE brands
(
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE categories
(
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE reviews
(
    id           INT PRIMARY KEY AUTO_INCREMENT,
    content      TEXT,
    rating       DECIMAL(10, 2) NOT NULL,
    picture_url  VARCHAR(80)    NOT NULL,
    published_at DATETIME       NOT NULL
);

CREATE TABLE products
(
    id                INT PRIMARY KEY AUTO_INCREMENT,
    name              VARCHAR(40)    NOT NULL,
    price             DECIMAL(19, 2) NOT NULL,
    quantity_in_stock INT,
    description       TEXT,
    brand_id          INT            NOT NULL,
    category_id       INT            NOT NULL,
    review_id         INT,

    CONSTRAINT fk_products_brands
        FOREIGN KEY (brand_id)
            REFERENCES brands (id),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
            REFERENCES categories (id),
    CONSTRAINT fk_products_reviews
        FOREIGN KEY (review_id)
            REFERENCES reviews (id)
);

CREATE TABLE customers
(
    id            INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(20) NOT NULL,
    last_name     VARCHAR(20) NOT NULL,
    phone         VARCHAR(30) NOT NULL UNIQUE,
    address       VARCHAR(60) NOT NULL,
    discount_card BIT(1)

);

CREATE TABLE orders
(
    id             INT PRIMARY KEY AUTO_INCREMENT,
    order_datetime DATETIME NOT NULL,
    customer_id    INT      NOT NULL,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
            REFERENCES customers (id)
);

CREATE TABLE orders_products
(
    order_id   INT,
    product_id INT,
    CONSTRAINT fk_orders_products_orders
        FOREIGN KEY (order_id)
            REFERENCES orders (id),
    CONSTRAINT fk_orders_product_product
        FOREIGN KEY (product_id)
            REFERENCES products (id)
);

#02.	Insert

SELECT SUBSTRING(description, 1, 15),
       REVERSE(name),
       '2010-10-10',
       price / 8
FROM products;


INSERT INTO reviews(content, picture_url, published_at, rating)
    (SELECT SUBSTRING(description, 1, 15),
            REVERSE(name),
            '2010-10-10',
            price / 8
     FROM products
     WHERE id >= 5);

#03.	Update

UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock BETWEEN 60 AND 70;

#04.	Delete

SELECT *
FROM customers
         LEFT JOIN orders o on customers.id = o.customer_id
WHERE o.customer_id IS NULL;

DELETE c
FROM customers AS c
         LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL;

#05.	Categories

SELECT id, name
FROM categories
ORDER BY name DESC;

#06.	Quantity

SELECT id, brand_id, name, quantity_in_stock
FROM products
WHERE price > 1000
  AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

#07.	Review

SELECT id, content, rating, picture_url, published_at
FROM reviews
WHERE content LIKE 'My%'
  AND CHAR_LENGTH(content) > 61
ORDER BY rating DESC;

#08.	First customers

SELECT CONCAT(first_name, ' ', last_name) AS first_name,
       address,
       order_datetime
FROM customers
         JOIN orders AS o ON customers.id = o.customer_id
WHERE o.order_datetime <= DATE('2018-12-31')
ORDER BY first_name DESC;

#09.	Best categories

SELECT COUNT(c.name)          AS items_count,
       c.name,
       SUM(quantity_in_stock) as total_quantity
FROM categories AS c
         JOIN products p on c.id = p.category_id
GROUP BY c.name
ORDER BY items_count DESC, total_quantity ASC
LIMIT 5;

#10. Extract client cards count


CREATE FUNCTION udf_customer_products_count(name VARCHAR(30))
    returns INT
    RETURN (SELECT count(op.product_id) AS total_product
            FROM customers AS c
                     JOIN orders o on c.id = o.customer_id
                     JOIN orders_products op on o.id = op.order_id
            WHERE first_name = name
            group by c.id);

SELECT c.first_name, c.last_name, udf_customer_products_count('Shirley') as `total_products`
FROM customers c
WHERE c.first_name = 'Shirley';

#11.   Reduce price

DELIMITER //
CREATE PROCEDURE udp_reduce_price(category_name  VARCHAR(50))
BEGIN
    UPDATE products AS p
        JOIN reviews r on p.review_id = r.id
        JOIN categories c on p.category_id = c.id
    SET price = price * 0.7
    WHERE c.name = category_name
      AND r.rating < 4;

end //

DELIMITER ;

CALL udp_reduce_price ('Phones and tablets');

SELECT p.name,
       p.price
FROM products AS p
         JOIN reviews r on p.review_id = r.id
         JOIN categories c on p.category_id = c.id
WHERE c.name = 'Phones and tablets'
  AND r.rating < 4;