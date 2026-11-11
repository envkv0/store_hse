{{ config(distributed_by='order_id', orientation='column') }}

select
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    o.customer_id,
    o.order_date,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.line_amount,
    o.is_confirmed
from {{ ref('stg_shop__order_items') }} as oi
inner join {{ ref('int_orders_with_payments') }} as o
    on oi.order_id = o.order_id
where not o.is_test_order