-- Active: 1791381172066@@127.0.0.1@5432@superstore

create View high_value_customers as
select c.customer_id, c.customer_name, sum(o.sales) as total_sales
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.sales) > 2000;
