{{ config(materialized='view') }}

with source_data as (
    select 
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_total
    from {{ var('raw_schema') }}.order_items
    where order_item_id is not null
      and order_id is not null
      and product_id is not null
),

transformed as (
    select 
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_total,
        case 
            when abs(line_total - (quantity * unit_price)) < 0.01 then true 
            else false 
        end as line_total_is_correct,
        current_timestamp as created_at
    from source_data
    where quantity > 0 
      and unit_price > 0
      and line_total > 0
)

select * from transformed