{{ config(materialized='view') }}

with src as (
  select
    product_id,
    sku,
    product_name,
    category,
    price::decimal(12,2) as price
  from {{ source('raw_data', 'raw_products') }}
)
select * from src
