{{ config(
    materialized = 'incremental',
    unique_key = 'host_id'
) }}

select
    host_id,
    host_name,
    host_since,
    is_superhost,
    response_rate as host_response_rate,
    case when response_rate > 90 then 'SUPER ACTIVE HOST' 
    when response_rate > 70 and response_rate <= 90 then 'ACTIVE HOST'
    else 'INACTIVE HOST' 
    end as host_activity_status,
    created_at
from {{ ref('bronze_hosts') }}
