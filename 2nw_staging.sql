-- Active: 1791381172066@@127.0.0.1@5432@northwind_elt

create schema if not exists silver;

create view silver.stg_categories as 
    select trim(categoryid)::int as categoryid, 
    trim(categoryname) as categoryname, 
    trim(description) as description
from bronze.categories;  

create view silver.stg_customers as
    select trim(customerid)::int as customerid, 
    trim(customername) as customername, 
    trim(address) as address, 
    trim(city) as city, 
    trim(postalcode) as postalcode, 
    trim(country) as country
from bronze.customers;

create view silver.stg_employees as
    select trim(employeeid)::int as employeeid, 
    trim(lastname) as lastname, 
    trim(firstname) as firstname, 
    trim(birthdate)::timestamp as birthdate, 
    trim(photo) as photo,
    trim(notes) as notes
from bronze.employees;

create view silver.stg_orderdetails as
    select trim(orderdetailid)::int as orderdetailid, 
    trim(orderid)::int as orderid, 
    trim(productid)::int as productid, 
    trim(quantity)::int as quantity
from bronze.orderdetails;

create view silver.stg_orders as
    select trim(orderid)::int as orderid, 
    trim(customerid)::int as customerid, 
    trim(employeeid)::int as employeeid, 
    trim(orderdate)::timestamp as orderdate, 
    trim(shipperid)::int as shipperid
from bronze.orders;

create view silver.stg_products as
    select trim(productid)::int as productid, 
    trim(productname) as productname, 
    trim(supplierid)::int as supplierid, 
    trim(categoryid)::int as categoryid, 
    trim(unit) as unit, 
    trim(price)::numeric(5, 2) as price
from bronze.products;

create view silver.stg_shippers as
    select trim(shipperid)::int as shipperid, 
    trim(shippername) as shippername, 
    trim(phone) as phone
from bronze.shippers;

create view silver.stg_suppliers as
    select trim(supplierid)::int as supplierid, 
    trim(suppliername) as suppliername, 
    trim(contactname) as contactname, 
    trim(address) as address, 
    trim(city) as city, 
    trim(postalcode) as postalcode, 
    trim(country) as country, 
    trim(phone) as phone
from bronze.suppliers;
