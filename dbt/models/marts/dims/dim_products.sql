{{ config(materialized='table') }}

with products_with_metrics as (
    select 
        p.*,
        s.supplier_name,
        s.rating as supplier_rating,
        s.rating_category as supplier_rating_category,
        count(oi.order_item_id) as total_orders,
        coalesce(sum(oi.quantity), 0) as total_quantity_sold,
        coalesce(sum(oi.line_total), 0) as total_revenue,
        coalesce(avg(oi.unit_price), p.price) as avg_selling_price
    from {{ ref('stg_products') }} p
    left join {{ ref('stg_suppliers') }} s 
        on p.supplier_id = s.supplier_id
    left join {{ ref('stg_order_items') }} oi 
        on p.product_id = oi.product_id
    group by 
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        p.stock_quantity,
        p.supplier_id,
        p.created_date,
        p.has_valid_price,
        p.has_valid_stock,
        p.created_at,
        s.supplier_name,
        s.rating,
        s.rating_category
)

select 
    product_id as product_key,
    product_id,
    product_name,
    category,
    price,
    stock_quantity,
    supplier_id,
    supplier_name,
    supplier_rating,
    supplier_rating_category,
    created_date,
    has_valid_price,
    has_valid_stock,
    total_orders,
    total_quantity_sold,
    total_revenue,
    avg_selling_price,
    case 
        when total_quantity_sold > 50 then 'high_volume'
        when total_quantity_sold > 20 then 'medium_volume'
        when total_quantity_sold > 0 then 'low_volume'
        else 'no_sales'
    end as sales_volume_category,
    current_timestamp as updated_at
from products_with_metrics