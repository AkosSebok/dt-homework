-- Active: 1791381172066@@127.0.0.1@5432@superstore

create View high_value_customers as
select c.customer_id, c.customer_name, sum(o.sales) as total_sales
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.sales) > 2000;


create View regional_monthly_sales as
select c.region, date_trunc('month', o.order_date) as month, sum(o.sales) as monthly_sales
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.region, date_trunc('month', o.order_date);


create view analyst_orders as
select order_id, customer_id, product_id, sales, quantity, discount
from orders;
