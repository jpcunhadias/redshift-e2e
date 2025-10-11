{{ config(materialized='table') }}
select
  product_id,
  sku,
  product_name,
  category,
  price
from {{ ref('stg_products') }}
