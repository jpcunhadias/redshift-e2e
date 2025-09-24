{{ config(materialized='table') }}

select 
    order_item_id as order_item_key,
    order_id as order_key,
    product_id as product_key,
    customer_id as customer_key,
    oi.*,
    o.customer_id,
    o.order_date,
    o.order_status_group,
    p.category as product_category,
    p.supplier_id,
    case 
        when oi.line_total >= 100 then 'high_value'
        when oi.line_total >= 50 then 'medium_value'
        when oi.line_total >= 25 then 'low_value'
        else 'very_low_value'
    end as line_item_value_category,
    current_timestamp as updated_at
from {{ ref('stg_order_items') }} oi
inner join {{ ref('stg_orders') }} o 
    on oi.order_id = o.order_id
inner join {{ ref('stg_products') }} p 
    on oi.product_id = p.product_id