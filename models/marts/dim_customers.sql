{{ config(materialized='table', distributed_replicated=true, orientation='column') }}

with confirmed_orders as (
    select *
    from {{ ref('fct_orders') }}
    where is_confirmed
),

customer_metrics as (
    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from confirmed_orders
    group by customer_id
),

ranked_orders as (
    select
        customer_id,
        order_id,
        ordered_at,
        row_number() over (
            partition by customer_id
            order by ordered_at, order_id
        ) as order_rank
    from confirmed_orders
),

first_orders as (
    select
        customer_id,
        order_id as first_confirmed_order_id,
        ordered_at as first_confirmed_at
    from ranked_orders
    where order_rank = 1
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    f.first_confirmed_order_id,
    f.first_confirmed_at,
    coalesce(m.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(m.confirmed_revenue, 0) as confirmed_revenue,
    coalesce(m.confirmed_orders_count, 0) > 0 as is_buyer
from {{ ref('stg_shop__customers') }} as c
left join customer_metrics as m
    on c.customer_id = m.customer_id
left join first_orders as f
    on c.customer_id = f.customer_id