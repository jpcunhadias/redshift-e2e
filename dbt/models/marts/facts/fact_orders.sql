{{ config(materialized='table') }}

with order_details as (
    select 
        o.*,
        count(oi.order_item_id) as item_count,
        sum(oi.quantity) as total_quantity,
        sum(oi.line_total) as calculated_total
    from {{ ref('stg_orders') }} o
    left join {{ ref('stg_order_items') }} oi 
        on o.order_id = oi.order_id
    group by 
        o.order_id,
        o.customer_id,
        o.order_date,
        o.total_amount,
        o.order_status,
        o.shipping_address,
        o.payment_method,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,
        o.order_status_group,
        o.created_at
)

select 
    order_id as order_key,
    customer_id as customer_key,
    order_id,
    customer_id,
    order_date,
    total_amount,
    calculated_total,
    order_status,
    order_status_group,
    shipping_address,
    payment_method,
    order_year,
    order_month,
    order_quarter,
    order_day_of_week,
    item_count,
    total_quantity,
    case 
        when abs(total_amount - calculated_total) < 0.01 then true
        else false
    end as amounts_match,
    case 
        when total_amount >= 200 then 'high_value'
        when total_amount >= 100 then 'medium_value'
        when total_amount >= 50 then 'low_value'
        else 'very_low_value'
    end as order_value_category,
    current_timestamp as updated_at
from order_details