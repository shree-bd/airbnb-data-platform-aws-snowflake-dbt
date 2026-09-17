{% set configs = [
    {
        "table": "AIRBNB.SILVER.SILVER_BOOKINGS",
        "columns": "silver_bookings.*",
        "alias": "silver_bookings"
    },
    {
        "table": "AIRBNB.SILVER.SILVER_LISTINGS",
        "columns": "silver_listings.host_id, silver_listings.property_type, silver_listings.bathrooms, silver_listings.bedrooms, silver_listings.created_at as listing_created_at, silver_listings.price_category",
        "alias": "silver_listings",
        "join_condition": "silver_bookings.listing_id = silver_listings.listing_id"
    },
    {
        "table": "AIRBNB.SILVER.SILVER_HOSTS",
        "columns": "silver_hosts.host_name, silver_hosts.host_since, silver_hosts.is_superhost, silver_hosts.host_response_rate, silver_hosts.host_activity_status, silver_hosts.created_at as host_created_at",
        "alias": "silver_hosts",
        "join_condition": "silver_listings.host_id = silver_hosts.host_id"
    }
] %}

select
    {% for config in configs %}
        {{ config.columns }}{% if not loop.last %}, {% endif %}
    {% endfor %}
from {{ configs[0].table }} as {{ configs[0].alias }}

{% for config in configs[1:] %}
left join {{ config.table }} as {{ config.alias }}
    on {{ config.join_condition }}
{% endfor %}