{{ config(materialized='view') }}

with source_data as (
    select 
        product_id,
        product_name,
        category,
        price,
        stock_quantity,
        supplier_id,
        created_date
    from {{ var('raw_schema') }}.products
    where product_id is not null
),

transformed as (
    select 
        product_id,
        trim(product_name) as product_name,
        trim(category) as category,
        price,
        stock_quantity,
        supplier_id,
        created_date,
        case 
            when price > 0 then true 
            else false 
        end as has_valid_price,
        case 
            when stock_quantity >= 0 then true 
            else false 
        end as has_valid_stock,
        current_timestamp as created_at
    from source_data
    where price > 0  -- Filter out invalid prices
)

select * from transformed