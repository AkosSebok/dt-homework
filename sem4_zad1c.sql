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


--#3
select stock_code, country, invoice_date, quantity, 
round( 
    avg(quantity) over (
        partition by stock_code, country order by invoice_date
        range between interval '7 days' preceding
        and current row
    ), 2
) as avg_quantity_7_days
from retail_sales
where quantity > 1
order by stock_code, country, invoice_date;


--#4
WITH unique_orders AS (
    SELECT DISTINCT customer_id, invoice_no, invoice_date::DATE AS invoice_date
    FROM retail_sales
), next_orders AS (
    SELECT customer_id, invoice_no, invoice_date, LEAD(invoice_date) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date, invoice_no
        ) AS next_invoice_date
    FROM unique_orders
) SELECT customer_id, invoice_no, invoice_date, next_invoice_date, (next_invoice_date - invoice_date) AS days_to_next_invoice
FROM next_orders
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

