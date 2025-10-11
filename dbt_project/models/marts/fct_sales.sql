{{ config(materialized='incremental', unique_key='order_id') }}

-- explode items JSON into rows using SUPER/JSON functions
with base as (
  select
    order_id,
    order_ts,
    customer_id,
    order_status,
    subtotal, tax, shipping, total, currency,
    json_parse(items) as items_json
  from {{ ref('stg_orders') }}
)
, exploded as (
  select
    b.order_id,
    b.order_ts,
    b.customer_id,
    i.product_id::int    as product_id,
    i.qty::int           as qty,
    i.unit_price::decimal(12,2) as unit_price,
    (i.qty::int * i.unit_price::decimal(12,2)) as line_amount
  from base b, b.items_json i
)
select
  e.order_id,
  e.order_ts, -- The original timestamp is needed for the incremental logic
  e.order_ts::date as order_date,
  e.customer_id,
  e.product_id,
  e.qty,
  e.unit_price,
  e.line_amount
from exploded e

{% if is_incremental() %}

  -- this filter will only be applied on incremental runs
  where e.order_ts > (select max(order_ts) from {{ this }})

{% endif %}