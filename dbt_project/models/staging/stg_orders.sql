{{ config(materialized='view') }}

with src as (
  select
    order_id,
    order_ts::timestamp as order_ts,
    customer_id,
    order_status,
    subtotal::decimal(12,2) as subtotal,
    tax::decimal(12,2) as tax,
    shipping::decimal(12,2) as shipping,
    total::decimal(12,2) as total,
    currency,
    items
  from {{ source('raw_data', 'raw_orders') }}
)
select * from src
