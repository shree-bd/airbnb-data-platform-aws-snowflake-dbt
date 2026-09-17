{% set configs = [
    {
        "table": "AIRBNB.GOLD.OBT",
        "columns": "gold_obt.booking_id, gold_obt.listing_id, gold_obt.host_id, 
        gold_obt.total_booking_amount, 
        gold_obt.host_response_rate, gold_obt.bedrooms, gold_obt.bathrooms",
        "alias": "gold_obt"
    },
    {
        "table": "AIRBNB.GOLD.DIM_LISTINGS",
        "columns": "",
        "alias": "gold_dim_listings",
        "join_condition": "gold_obt.listing_id = gold_dim_listings.listing_id"
    },
    {
        "table": "AIRBNB.GOLD.DIM_HOSTS",
        "columns": "",
        "alias": "gold_dim_hosts",
        "join_condition": "gold_obt.host_id = gold_dim_hosts.host_id"
    }
] %}

select
 {{ configs[0].columns }}
from {{ configs[0].table }} as {{ configs[0].alias }}

{% for config in configs[1:] %}
left join {{ config.table }} as {{ config.alias }}
    on {{ config.join_condition }}
{% endfor %}