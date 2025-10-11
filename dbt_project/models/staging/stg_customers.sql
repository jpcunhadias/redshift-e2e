{{ config(materialized='view') }}

with src as (
  select
    customer_id,
    first_name,
    last_name,
    email,
    signup_ts::timestamp as signup_ts
  from {{ source('raw_data', 'raw_customers') }}
)
select * from src
