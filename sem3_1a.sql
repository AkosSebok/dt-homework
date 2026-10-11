-- Active: 1791381172066@@127.0.0.1@5432@retail_sales

--#1
create View high_value_customers as
select c.customer_id, c.customer_name, sum(o.sales) as total_sales
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.sales) > 2000;


--#2
create View regional_monthly_sales as
select c.region, date_trunc('month', o.order_date) as month, sum(o.sales) as monthly_sales
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.region, date_trunc('month', o.order_date);


--#3
create view analyst_orders as
select order_id, customer_id, product_id, sales, quantity, discount
from orders;


--#4
create index idx_orders_customer_id 
on orders(customer_id);


--#5
create index idx_orders_order_date
on orders(order_date);
select date_trunc('month', order_date) as month, sum(sales)
from orders
group by date_trunc('month', order_date);


--#6
create index idx_orders_region_category
on orders(customer_id, order_date);
select o.*
from orders o
inner join customers c on o.customer_id = c.customer_id
where c.region = 'West' and o.order_date >= '2024-01-01';


--#7
explain analyze
select *
from orders
where customer_id = 'C001';


--#8
create database retail_sales;
create table orders (
    order_id varchar(20) primary key,
    customer_id varchar(20) not null,
    product_id varchar(20) not null,
    order_date date not null,
    region varchar(20) not null,
    category varchar(50) not null,
    ship_mode varchar(30) not null,
    sales numeric(10, 2) not null,
    profit numeric(10, 2) not null
);
alter database retail_sales 
set datestyle to 'ISO, MDY';
select * from orders;
show datestyle;


--#9
create procedure get_customer_sales(p_customer_id varchar(20))
language plpgsql
as $procedure$
declare v_total_sales numeric(10, 2);
begin
    select sum(sales) into v_total_sales from orders where customer_id = p_customer_id;
    raise notice 'customer_id: %, total_sales: %', p_customer_id, v_total_sales;
end;
$procedure$;
call get_customer_sales('C001');


--#10
create procedure apply_regional_discount(p_region varchar(20), p_discount_rate numeric(5, 2))
language plpgsql
as $$
begin
    update orders
    set sales = sales * (1 - p_discount_rate)
    where customer_id in (select customer_id from orders where region = p_region);
    raise notice 'p_region: %, p_discount_rate: %', p_region, p_discount_rate;
end
$$;
call apply_regional_discount('West', 0.10);