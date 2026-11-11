{{ config(distributed_by='order_id', orientation='column') }}
with order_items_count as (
    select
        order_id,
        count(distinct product_id) as items_count
    from {{ ref('stg_shop__order_items') }}
    group by order_id
)
select
    order_id,
    customer_id,
    order_date,
    ordered_at,
    order_status,
    order_amount,
    paid_amount,
    refunded_amount,
    net_paid_amount,
    successful_payments_count,
    first_paid_at,
    is_confirmed,
    coalesce(order_items_count.items_count, 0) as items_count
from {{ ref('int_orders_with_payments') }}
left join order_items_count using (order_id)
where not is_test_order
