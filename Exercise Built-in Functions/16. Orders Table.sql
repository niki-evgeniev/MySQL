select product_name,
       order_date,
       date_add(order_date, interval 3 day ) as pay_due,
       date_add(order_date, interval  1 month ) as deliver_due
from orders;