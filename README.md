# Airbnb Analytics Engineering with AWS, Snowflake, and dbt

An end-to-end analytics engineering project that transforms Airbnb listings, hosts, and bookings CSV data into analytics-ready Snowflake datasets. Raw Airbnb data is loaded through AWS into Snowflake, and dbt manages the transformation pipeline, history tracking, testing, and documentation.

## Highlights

- AWS-hosted Airbnb CSV data loaded to Snowflake staging tables
- Bronze → Silver → Gold dbt architecture
- Incremental Bronze and Silver models
- One Big Table (OBT) for reporting
- SCD Type 2 dimensions with dbt snapshots
- Custom SQL/Jinja macros
- dbt singular data-quality test
- Snowflake as the analytics warehouse

## Architecture

```text
Airbnb CSV files (AWS)
          │
          ▼
Snowflake STAGING
  ├── listings
  ├── hosts
  └── bookings
          │
          ▼
Bronze incremental models
          │
          ▼
Silver business transformations
          │
          ▼
Gold OBT, ephemeral models, fact model, and SCD2 snapshots
```

## Data models

### Sources

The `staging` source contains the raw `listings`, `hosts`, and `bookings` tables.

### Bronze

`bronze_listings`, `bronze_hosts`, and `bronze_bookings` copy source data with minimal transformation. They use `is_incremental()` and load only records with a `CREATED_AT` later than the maximum timestamp already in the target table.

### Silver

| Model | Key | Business logic |
| --- | --- | --- |
| `silver_bookings` | `BOOKING_ID` | Calculates `total_booking_amount` from booking, cleaning, and service fees. |
| `silver_hosts` | `HOST_ID` | Classifies hosts as Super Active, Active, or Inactive from their response rate. |
| `silver_listings` | `LISTING_ID` | Classifies listings as Affordable or Expensive from nightly price. |

### Gold

- `obt` joins bookings, listings, and hosts into a One Big Table for reporting.
- Ephemeral booking, host, and listing models compile as CTEs rather than permanent warehouse objects.
- `fact` is a fact-oriented Gold model based on the OBT and dimension relations.

## SCD Type 2 history

dbt snapshots maintain historical versions of booking, host, and listing records.

| Snapshot | Business key | Change timestamp |
| --- | --- | --- |
| `dim_bookings` | `booking_id` | `created_at` |
| `dim_hosts` | `host_id` | `host_created_at` |
| `dim_listings` | `listing_id` | `listing_created_at` |

Snapshots use the `timestamp` strategy and create dbt metadata fields such as `dbt_valid_from`, `dbt_valid_to`, and `dbt_scd_id`. This supports both current-state and historical reporting.

## Macro

The custom `multiply` macro calculates a rounded multiplication expression:

```jinja
{{ multiply('nights_booked', 'booking_amount', 2) }}
```

It compiles to:

```sql
round((nights_booked * booking_amount), 2)
```

## Data quality

The project includes a singular dbt test that identifies bookings where `booking_amount < 200`. It is configured with warning severity, so failed rows are reported without failing the run.

## Repository structure

```text
AWS_DBT_Snowflake/
├── aws_dbt_snowflake_project/
│   ├── models/
│   │   ├── sources/       # Raw Snowflake source definitions
│   │   ├── bronze/        # Incremental raw models
│   │   ├── silver/        # Cleaned and enriched models
│   │   └── gold/          # OBT, fact, and ephemeral models
│   ├── macros/            # Custom Jinja/SQL macros
│   ├── snapshots/         # SCD Type 2 snapshot definitions
│   ├── tests/             # Singular dbt data tests
│   ├── dbt_project.yml
│   └── profiles.yml
└── README.md
```

## Setup

Prerequisites:

- Python, dbt Core, and the `dbt-snowflake` adapter
- Snowflake account, warehouse, database, role, and credentials
- Airbnb source tables loaded to `AIRBNB.STAGING`

Configure Snowflake credentials in the dbt profile using environment variables; never commit passwords or other secrets.

```yaml
account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
user: "{{ env_var('SNOWFLAKE_USER') }}"
password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
database: AIRBNB
```

## Run the project

Run commands inside `aws_dbt_snowflake_project/`:

```bash
dbt debug       # validate profile and Snowflake connectivity
dbt parse       # validate project parsing
dbt run         # build transformations
dbt snapshot    # update SCD Type 2 history
dbt test        # execute data tests
dbt build       # run models and tests together
dbt docs generate
dbt docs serve
```

To fully reload an incremental model:

```bash
dbt run --select bronze_bookings --full-refresh
```

## Future improvements

- Add `unique`, `not_null`, and relationship tests.
- Use `ref()` consistently in Gold models instead of hard-coded relation names.
- Use SCD2 dimension surrogate keys in the fact model for historical accuracy.
- Add source freshness checks, descriptions, and CI for `dbt build`.
