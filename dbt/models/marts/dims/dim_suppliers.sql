{{ config(materialized='table') }}

with suppliers_with_metrics as (
    select 
        s.*,
        count(distinct p.product_id) as total_products,
        coalesce(avg(p.price), 0) as avg_product_price,
        coalesce(sum(p.stock_quantity), 0) as total_stock_quantity
    from {{ ref('stg_suppliers') }} s
    left join {{ ref('stg_products') }} p 
        on s.supplier_id = p.supplier_id
    group by 
        s.supplier_id,
        s.supplier_name,
        s.contact_person,
        s.email,
        s.phone,
        s.address_street,
        s.address_city,
        s.address_state,
        s.address_zip,
        s.full_address,
        s.rating,
        s.rating_category,
        s.created_at
)

select 
    supplier_id as supplier_key,
    supplier_id,
    supplier_name,
    contact_person,
    email,
    phone,
    address_street,
    address_city,
    address_state,
    address_zip,
    full_address,
    rating,
    rating_category,
    total_products,
    avg_product_price,
    total_stock_quantity,
    case 
        when total_products >= 5 then 'large_catalog'
        when total_products >= 2 then 'medium_catalog'
        when total_products >= 1 then 'small_catalog'
        else 'no_products'
    end as catalog_size,
    current_timestamp as updated_at
from suppliers_with_metrics