{{ config(materialized='view') }}

with source_data as (
    select 
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        address,
        city,
        state,
        zip_code,
        registration_date
    from {{ var('raw_schema') }}.customers
    where customer_id is not null
),

transformed as (
    select 
        customer_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        trim(first_name) || ' ' || trim(last_name) as full_name,
        lower(trim(email)) as email,
        phone,
        address,
        city,
        upper(state) as state,
        zip_code,
        registration_date,
        case 
            when email is not null and email != '' then true 
            else false 
        end as has_valid_email,
        current_timestamp as created_at
    from source_data
)

select * from transformed