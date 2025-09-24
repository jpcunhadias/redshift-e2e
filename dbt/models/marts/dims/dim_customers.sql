{{ config(materialized='table') }}

with customers_with_metrics as (
    select 
        c.*,
        count(o.order_id) as total_orders,
        coalesce(sum(o.total_amount), 0) as total_spent,
        coalesce(avg(o.total_amount), 0) as avg_order_value,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date,
        case 
            when max(o.order_date) >= current_date - interval '30 days' then 'active'
            when max(o.order_date) >= current_date - interval '90 days' then 'lapsed'
            when max(o.order_date) is not null then 'inactive'
            else 'prospect'
        end as customer_segment
    from {{ ref('stg_customers') }} c
    left join {{ ref('stg_orders') }} o 
        on c.customer_id = o.customer_id
        and o.order_status_group = 'completed'
    group by 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.full_name,
        c.email,
        c.phone,
        c.address,
        c.city,
        c.state,
        c.zip_code,
        c.registration_date,
        c.has_valid_email,
        c.created_at
)

select 
    customer_id as customer_key,
    customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone,
    address,
    city,
    state,
    zip_code,
    registration_date,
    has_valid_email,
    total_orders,
    total_spent,
    avg_order_value,
    first_order_date,
    last_order_date,
    customer_segment,
    current_timestamp as updated_at
from customers_with_metrics