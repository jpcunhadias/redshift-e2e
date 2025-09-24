{{ config(materialized='view') }}

with source_data as (
    select 
        supplier_id,
        supplier_name,
        contact_person,
        email,
        phone,
        address_street,
        address_city,
        address_state,
        address_zip,
        rating
    from {{ var('raw_schema') }}.suppliers
    where supplier_id is not null
),

transformed as (
    select 
        supplier_id,
        trim(supplier_name) as supplier_name,
        trim(contact_person) as contact_person,
        lower(trim(email)) as email,
        phone,
        address_street,
        address_city,
        upper(address_state) as address_state,
        address_zip,
        trim(address_street) || ', ' || 
        trim(address_city) || ', ' || 
        upper(address_state) || ' ' || 
        address_zip as full_address,
        rating,
        case 
            when rating >= 4.5 then 'excellent'
            when rating >= 4.0 then 'good'
            when rating >= 3.5 then 'average'
            else 'poor'
        end as rating_category,
        current_timestamp as created_at
    from source_data
    where rating between 0 and 5  -- Valid rating range
)

select * from transformed