create database finance ;
use finance;
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    age INT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    income_level VARCHAR(20),
    customer_segment VARCHAR(20),
    join_date DATE
);


CREATE TABLE dim_accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    bank_name VARCHAR(100),
    account_status VARCHAR(20),
    open_date DATE
);


CREATE TABLE dim_merchants (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50)
);


CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    weekday VARCHAR(20),
    is_weekend BOOLEAN
);

CREATE TABLE fact_transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    account_id INT,
    merchant_id INT,
    date_id INT,
    amount DECIMAL(10,2),
    transaction_type VARCHAR(20),
    payment_mode VARCHAR(50),
    status VARCHAR(20),
    fee_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    net_amount DECIMAL(10,2)
);
   
   
   select * from fact_transactions;
   select * from dim_accounts;
   select * from dim_merchants;
   select * from dim_date;
   select * from dim_customers;
