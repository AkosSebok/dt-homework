-- Active: 1791381172066@@127.0.0.1@5432@northwind_elt

-- create database northwind_elt;

\set on_error_stop on \encoding utf8

create schema if not exists bronze;

create table if  not exists bronze.products (
    productid text,
    productname text,
    supplierid text,
    categoryid text,
    unit text,
    price text,
    _source_file text default 'products.csv',
    _loaded_at timestamptz default now()
);

create table if not exists bronze.customers (
    customerid text,
    customername text,
    contactname text,
    address text,
    city text,
    postalcode text,
    country text,
    _source_file text default 'customers.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.orderdetails (
    orderdetailid text,
    orderid text,
    productid text,
    quantity text,
    _source_file text default 'orderdetails.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.categories (
    categoryid text,
    categoryname text,
    description text,
    _source_file text default 'categories.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.employees (
    employeeid text,
    lastname text,
    firstname text,
    birthdate text,
    photo text,
    notes text,
    _source_file text default 'employees.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.orders (
    orderid text,
    customerid text,
    employeeid text,
    orderdate text,
    shipperid text,
    _source_file text default 'orders.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.suppliers (
    supplierid text,
    suppliername text,
    contactname text,
    address text,
    city text,
    postalcode text,
    country text,
    phone text,
    _source_file text default 'suppliers.csv',
    _loaded_at timestamptz default now()
);

create table if  not exists bronze.shippers (
    shipperid text,
    shippername text,
    phone text,
    _source_file text default 'shippers.csv',
    _loaded_at timestamptz default now()
);

begin;

truncate bronze.products, bronze.customers, bronze.orderdetails, bronze.categories, bronze.employees, bronze.orders, bronze.suppliers, bronze.shippers; 

\copy bronze.products (productid, productname, supplierid, categoryid, unit, price) from 'data/products.csv' with (format csv, header true, delimiter ';')
\copy bronze.customers (customerid, customername, contactname, address, city, postalcode, country) from 'data/customers.csv' with (format csv, header true, delimiter ';')
\copy bronze.orderdetails (orderdetailid, orderid, productid, quantity) from 'data/orderdetails.csv' with (format csv, header true, delimiter ';')
\copy bronze.categories (categoryid, categoryname, description) from 'data/categories.csv' with (format csv, header true, delimiter ';')
\copy bronze.employees (employeeid, lastname, firstname, birthdate, photo, notes) from 'data/employees.csv' with (format csv, header true, delimiter ';')
\copy bronze.orders (orderid, customerid, employeeid, orderdate, shipperid) from 'data/orders.csv' with (format csv, header true, delimiter ';')
\copy bronze.suppliers (supplierid, suppliername, contactname, address, city, postalcode, country, phone) from 'data/suppliers.csv' with (format csv, header true, delimiter ';')
\copy bronze.shippers (shipperid, shippername, phone) from 'data/shippers.csv' with (format csv, header true, delimiter ';')

commit;