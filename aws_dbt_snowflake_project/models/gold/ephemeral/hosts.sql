{{ config(materialized='ephemeral') }}


with hosts as (
    select
    host_id,
    host_name,
    host_since,
    is_superhost,
    host_activity_status,
    created_at as host_created_at
    from {{ ref('obt') }}
)
select * from hosts