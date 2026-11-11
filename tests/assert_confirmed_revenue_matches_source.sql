with source_total as (
    select coalesce(sum(o.total_amount), 0) as amount
    from {{ source('shop', 'orders') }} as o
    where o.status = 'paid'
      and exists (
          select 1
          from {{ source('shop', 'payments') }} as p
          where p.order_id = o.order_id
            and p.payment_status = 'success'
            and p.amount > 0
      )
),

mart_total as (
    select coalesce(sum(order_amount), 0) as amount
    from {{ ref('fct_orders') }}
    where is_confirmed
)

select
    source_total.amount as source_amount,
    mart_total.amount as mart_amount
from source_total
cross join mart_total
where abs(source_total.amount - mart_total.amount) > 0.01