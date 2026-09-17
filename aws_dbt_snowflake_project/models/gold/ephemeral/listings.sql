{{ config(materialized='ephemeral') }}


with listings as (
    select
    listing_id,
    property_type,
    bathrooms,
    bedrooms,
    listing_created_at
    from {{ ref('obt') }}
)
select * from listings