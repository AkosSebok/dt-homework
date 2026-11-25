-- Active: 1791381172066@@127.0.0.1@5432@northwind_elt

\set on_error_stop on \encoding utf8

create schema if not exists gold;

create table gold.sdim_day (
    day_id int not null primary key,
    day int,
    day_of_week varchar(45)
);
create table gold.sdim_month (
    month_id int not null primary key,
    month int,
    month_name varchar(45)
);
create table gold.sdim_quarter (
    quarter_id int not null primary key,
    quarter int,
    quarter_label varchar(45)
);
create table gold.dim_date (
    date_id int not null primary key,
    day int not null references gold.sdim_day (day_id),
    week int,
    month int not null references gold.sdim_month (month_id),
    year int,
    quarter int not null references gold.sdim_quarter (quarter_id)
);

create table gold.sdim_address (
    address_id int not null primary key,
    address varchar(50)
);
create table gold.sdim_city (
    city_id int not null primary key,
    city_name varchar(20)
);
create table gold.sdim_country (
    country_id int not null primary key,
    country_name varchar(15)
);
create table gold.dim_customer (
    customer_id int not null primary key,
    customer_name varchar(50),
    address int not null references gold.sdim_address (address_id),
    city int not null references gold.sdim_city (city_id),
    country int not null references gold.sdim_country (country_id)
);

create table gold.sdim_category (
    category_id int not null primary key,
    category_name varchar(25)
);
create table gold.sdim_supplier (
    supplier_id int not null primary key,
    supplier_name varchar(50),
    address varchar(45),
    city varchar(45),
    country varchar(45)
);
create table gold.dim_product (
    product_id int not null primary key,
    product_name varchar(50),
    category int not null references gold.sdim_category (category_id),
    product_unit varchar(25),
    supplier int not null references gold.sdim_supplier (supplier_id)
);

create table gold.dim_employee (
    employee_id int primary key,
    first_name varchar(15),
    last_name varchar(15)
);

create table gold.dim_shipper (
    shipper_id int primary key,
    shipper_name varchar(25)
);

create table gold.fact_order (
    order_id int not null,
    quantity int, 
    product_price numeric(10,0),
    customer_id int not null references gold.dim_customer (customer_id),
    employee_id int not null references gold.dim_employee (employee_id),
    date_id int not null references gold.dim_date (date_id),
    product_id int not null references gold.dim_product (product_id),
    shipper_id int not null references gold.dim_shipper (shipper_id)
);

create index on gold.fact_order (customer_id);
create index on gold.fact_order (employee_id);
create index on gold.fact_order (date_id);
create index on gold.fact_order (product_id);
create index on gold.fact_order (shipper_id);

begin;

truncate gold.fact_order, gold.dim_customer, gold.sdim_address, gold.sdim_city, gold.sdim_country, gold.dim_date, gold.sdim_day, gold.sdim_month, gold.sdim_quarter, gold.dim_product, gold.sdim_category, gold.sdim_supplier, gold.dim_shipper, gold.dim_employee;

insert into gold.sdim_day (day_id, day, day_of_week)
    select 
        row_number() over (order by day, day_of_week) as day_id,
        day,
        day_of_week
        from(
            select distinct
                extract(day from d)::int as day,
                trim(to_char(d, 'Day')) as day_of_week
            from generate_series(
                (select min(orderdate)::date from silver.stg_orders),
                (select max(orderdate)::date from silver.stg_orders),
                interval '1 day'
            ) as gs(d)
        ) as days;

insert into gold.sdim_month (month_id, month, month_name)
    select distinct
        extract(month from d)::int as month_id,
        extract(month from d)::int as month,
        trim(to_char(d, 'Month')) as month_name
    from generate_series(
        (select min(orderdate)::date from silver.stg_orders),
        (select max(orderdate)::date from silver.stg_orders),
        interval '1 day'
    ) as gs(d);

insert into gold.sdim_quarter (quarter_id, quarter, quarter_label)
    select distinct
        extract(quarter from d)::int as quarter_id,
        extract(quarter from d)::int as quarter,
        'Q' || extract(quarter from d)::text as quarter_label
    from generate_series(
        (select min(orderdate)::date from silver.stg_orders),
        (select max(orderdate)::date from silver.stg_orders),
        interval '1 day'
    ) as gs(d);

insert into gold.dim_date (date_id, day, week, month, year, quarter)
    select 
        to_char(d, 'YYYYMMDD')::int as date_id,
        s_d.day_id as day,
        extract (week from d)::int as week,
        s_m.month_id as month,
        extract (year from d)::int as year,
        s_q.quarter as quarter
    from generate_series(
        (select min(orderdate)::date from silver.stg_orders),
        (select max(orderdate)::date from silver.stg_orders),
        interval '1 day'
    ) as gs(d)
    inner join gold.sdim_day s_d on s_d.day = extract(day from gs.d)::int 
        and s_d.day_of_week = trim(to_char(gs.d, 'Day'))
    inner join gold.sdim_month s_m on s_m.month_id = extract(month from gs.d)::int
    inner join gold.sdim_quarter s_q on s_q.quarter_id = extract(quarter from d)::int;


insert into gold.sdim_address (address_id, address)
    select 
        row_number() over (order by address) as address_id,
        address 
    from (select distinct address from silver.stg_customers) as a;

insert into gold.sdim_city (city_id, city_name)
    select 
        row_number() over (order by city) as city_id,
        city
    from (select distinct city from silver.stg_customers) as a;

insert into gold.sdim_country (country_id, country_name)
    select 
        row_number() over (order by country) as country_id,
        country
    from (select distinct country from silver.stg_customers) as a;

insert into gold.dim_customer (customer_id, customer_name, address, city, country)
    select
        cu.customerid as customer_id,
        cu.customername as customer_name,
        a.address_id as address,
        c.city_id as city,
        co.country_id as country
    from silver.stg_customers cu
    inner join gold.sdim_address a on a.address = cu.address
    inner join gold.sdim_city c on c.city_name = cu.city
    inner join gold.sdim_country co on co.country_name = cu.country;


insert into gold.sdim_category (category_id, category_name)
    select 
        categoryid as category_id,
        categoryname as category_name
    from silver.stg_categories;

insert into gold.sdim_supplier (supplier_id, supplier_name, address, city, country)
    select 
        supplierid as supplier_id,
        suppliername as supplier_name,
        address, 
        city, 
        country
    from silver.stg_suppliers;

insert into gold.dim_product (product_id, product_name, category, product_unit, supplier)
    select 
        productid as product_id,
        productname as product_name,
        categoryid as category,
        unit as unit,
        supplierid as supplier
    from silver.stg_products;


insert into gold.dim_employee (employee_id, first_name, last_name)
    select 
        employeeid as employee_id,
        firstname as first_name,
        lastname as last_name
    from silver.stg_employees;


insert into gold.dim_shipper (shipper_id, shipper_name)
    select 
        shipperid as shipper_id,
        shippername as shipper_name
    from silver.stg_shippers;


insert into gold.fact_order (order_id, quantity, product_price, customer_id, employee_id, date_id, product_id, shipper_id)
    select 
        od.orderid as order_id,
        od.quantity,
        p.price as product_price,
        o.customerid as customer_id,
        o.employeeid as employee_id,
        to_char(o.orderdate, 'YYYYMMDD')::int as date_id,
        od.productid as product_id,
        o.shipperid as shipper_id
    from silver.stg_orderdetails od
    inner join silver.stg_products p on p.productid = od.productid
    inner join silver.stg_orders o on o.orderid = od.orderid;


commit;