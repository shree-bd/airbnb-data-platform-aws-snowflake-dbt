{{ config(
    materialized='incremental',
    unique_key='LISTING_ID'
) }}

select
    listing_id,
    host_id,
    property_type,
    room_type,
    city,
    country,
    bedrooms,
    bathrooms,
    case
        when price_per_night < 150 then 'AFFORDABLE'
        else 'EXPENSIVE'
    end as price_category,
    created_at
from {{ ref('bronze_listings') }}