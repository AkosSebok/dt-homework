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



create index idx_orders_customer_id 
on orders(customer_id);



create index idx_orders_order_date
on orders(order_date);
select date_trunc('month', order_date) as month, sum(sales)
from orders
group by date_trunc('month', order_date);



create index idx_orders_region_category
on orders(customer_id, order_date);
select o.*
from orders o
inner join customers c on o.customer_id = c.customer_id
where c.region = 'West' and o.order_date >= '2024-01-01';