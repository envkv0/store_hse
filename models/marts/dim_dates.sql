{{ config(materialized='table', distributed_replicated=true, orientation='column') }}

with date_spine as (
    select generated_day::date as date_day
    from generate_series(
        (select min(order_date)::timestamp from {{ ref('fct_orders') }}),
        (select max(order_date)::timestamp from {{ ref('fct_orders') }}),
        interval '1 day'
    ) as dates(generated_day)
)

select
    date_day,
    extract(year from date_day)::int as year,
    extract(quarter from date_day)::int as quarter,
    extract(month from date_day)::int as month,
    extract(day from date_day)::int as day,
    extract(isodow from date_day)::int as day_of_week,
    extract(isodow from date_day) in (6, 7) as is_weekend
from date_spine