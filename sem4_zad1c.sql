-- Active: 1791381172066@@127.0.0.1@5432@retail

--#1
create DATABASE retail;
create Table retail_sales (
    invoice_no varchar(20),
    stock_code varchar(50),
    description text,
    quantity integer,
    invoice_date timestamp,
    unit_price decimal(10,2),
    customer_id integer,
    country varchar(100)
);
select * from retail_sales;


--#2
select customer_id, invoice_no, invoice_date, quantity, unit_price, (quantity * unit_price) as revenue, 
sum(quantity * unit_price) over (
    partition by customer_id order by invoice_date 
    range between interval '14 days' preceding 
    and current row
    ) as revenue_last_14_days
from retail_sales
where customer_id is not null
order by customer_id, invoice_date;


