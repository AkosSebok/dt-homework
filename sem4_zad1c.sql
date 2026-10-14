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
