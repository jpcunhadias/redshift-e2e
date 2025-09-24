{{ config(materialized='view') }}

with source_data as (
    select 
        order_id,
        customer_id,
        order_date,
        total_amount,
        status,
        shipping_address,
        payment_method
    from {{ var('raw_schema') }}.orders
    where order_id is not null
      and customer_id is not null
),

transformed as (
    select 
        order_id,
        customer_id,
        order_date,
        total_amount,
        trim(lower(status)) as order_status,
        shipping_address,
        trim(lower(payment_method)) as payment_method,
        extract(year from order_date) as order_year,
        extract(month from order_date) as order_month,
        extract(quarter from order_date) as order_quarter,
        extract(dow from order_date) as order_day_of_week,
        case 
            when trim(lower(status)) in ('completed', 'shipped', 'delivered') then 'completed'
            when trim(lower(status)) in ('pending', 'processing') then 'pending'
            when trim(lower(status)) in ('cancelled', 'refunded') then 'cancelled'
            else 'other'
        end as order_status_group,
        current_timestamp as created_at
    from source_data
    where total_amount > 0  -- Filter out invalid amounts
)

select * from transformed