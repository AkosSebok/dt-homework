-- Active: 1791381172066@@127.0.0.1@5432@superstore

--#1
with customer_orders as (
    select c.customer_name, o.order_id, o.order_date, 
    row_number() over (
        partition by c.customer_id order by o.order_date desc
    ) as rows
    from customers c
    inner join orders o on c.customer_id = o.customer_id
)
select customer_name, order_id, order_date
from customer_orders
where rows <= 2
order by customer_name, rows;
