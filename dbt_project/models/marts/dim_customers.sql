{{ config(materialized='table') }}
select
  customer_id,
  initcap(first_name) as first_name,
  initcap(last_name)  as last_name,
  email,
  signup_ts::date     as signup_date
from {{ ref('stg_customers') }}
