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


--#2
with customer_profit as (
    select c.customer_name, c.region, sum(o.profit) as total_profit
    from customers c
    inner join orders o on c.customer_id = o.customer_id
    group by c.region, c.customer_name, c.customer_id
)
select region, customer_name, total_profit,
rank() over (
    partition by region order by total_profit desc
) as profit_rank,
dense_rank() over (
    partition by region order by total_profit desc
) as profit_dense_rank
from customer_profit
order by region, profit_rank, customer_name;


--#3
with customer_sales as (
    select c.customer_id, c.customer_name, sum(o.sales) as total_sales
    from customers c
    inner join orders o on c.customer_id = o.customer_id
    group by c.customer_id, c.customer_name
)
select customer_name, total_sales, 
ntile(4) over (
    order by total_sales desc
) as quartile
from customer_sales
order by total_sales desc;


--#4
with monthly_sales as (
    select date_trunc('month', order_date)::date as month, sum(sales) as monthly_sales
    from orders
    group by date_trunc('month', order_date)::date
)
select month, monthly_sales,
lag(monthly_sales, 1) over (
    order by month
) as previous_month_sales,
lead(monthly_sales, 1) over (
    order by month
) as next_month_sales
from monthly_sales
order by month;

--#5
with product_sales as (
    select p.category, p.product_name, sum(o.sales) as product_sales
    from orders o
    inner join products p on o.product_id = p.product_id
    group by p.category, p.product_name
)
select category, product_name, product_sales, sum(product_sales) over (
    partition by category
) as category_total,
round(
    product_sales * 100.0 / sum(product_sales) over (
        partition by category
    ), 2
) as pct_of_category
from product_sales
order by category, product_name;

