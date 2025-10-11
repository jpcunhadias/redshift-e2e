-- sql/02_stage_tables.sql
create table if not exists raw_data.raw_customers (
  customer_id   int   encode az64,
  first_name    varchar(100),
  last_name     varchar(100),
  email         varchar(256),
  signup_ts     timestamp
);

create table if not exists raw_data.raw_products (
  product_id    int   encode az64,
  sku           varchar(64),
  product_name  varchar(256),
  category      varchar(128),
  price         decimal(12,2)
);

create table if not exists raw_data.raw_orders (
  order_id      int   encode az64,
  order_ts      timestamp,
  customer_id   int,
  order_status  varchar(32),
  subtotal      decimal(12,2),
  tax           decimal(12,2),
  shipping      decimal(12,2),
  total         decimal(12,2),
  currency      varchar(8),
  items         varchar(max) -- keep raw JSON; we’ll parse in dbt/core
);
