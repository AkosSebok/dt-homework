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


--#5
with price_comparison as (
    select stock_code, invoice_no, invoice_date,
    lag(unit_price) over (
        partition by stock_code order by invoice_date
    ) as previous_price, unit_price as current_price
    from retail_sales
)
select stock_code, invoice_no, invoice_date, previous_price, current_price, (current_price - previous_price) as price_difference
from price_comparison
where previous_price is not null
and current_price <> previous_price
order by invoice_date;


--#6
with customer_sales as (
    select customer_id, sum(quantity * unit_price) as total_amount 
    from retail_sales
    where customer_id is not null
    group by customer_id
)
select customer_id, total_amount, ntile(4) over (
    order by total_amount desc) as sales_quartile
from customer_sales
order by total_amount desc;


--#7
with monthly_sales as (
    select country, date_trunc('month', invoice_date)::DATE as month, sum(quantity * unit_price) as total_amount
    from retail_sales
    group by country, date_trunc('month', invoice_date)
)
select country, month, total_amount, ntile(4) over (
    partition by country order by total_amount desc) as sales_quartile
from monthly_sales
order by country, month;


--#8
with ranked_orders as (
    select customer_id, invoice_no, invoice_date, stock_code, description, quantity, unit_price,
    row_number() over (
        partition by customer_id order by invoice_date
    ) as rows
    from retail_sales
)
select customer_id, invoice_no, invoice_date, stock_code, description, quantity, unit_price
from ranked_orders
where rows = 1
order by customer_id;


--#9
with ranked_products as (
    select invoice_no, stock_code, description, quantity, unit_price, quantity * unit_price as amount, 
    row_number() over (
        partition by invoice_no order by quantity * unit_price desc
    ) as row_num
    from retail_sales
)
select invoice_no, stock_code, description, quantity, unit_price, amount, row_num
from ranked_products
where row_num <= 3
order by invoice_no, row_num;


--#10
with monthly_sales as (
    select country, date_trunc('month', invoice_date)::date as month, customer_id, sum(quantity * unit_price) as total_amount
    from retail_sales
    where customer_id is not null
    group by country, date_trunc('month', invoice_date)::date, customer_id
), 
ranked_customers as (
    select country, month, customer_id, total_amount,
    dense_rank() over (
        partition by country, month order by total_amount desc
    ) as sales_rank
    from monthly_sales
)
select country, month, customer_id, total_amount, sales_rank
from ranked_customers
where sales_rank <= 5
order by country, month, sales_rank, customer_id;


