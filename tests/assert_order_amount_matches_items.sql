with item_totals as (
    select
        order_id,
        sum(line_amount) as total_line_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.order_amount,
    coalesce(i.total_line_amount, 0) as total_line_amount
from {{ ref('fct_orders') }} as o
left join item_totals as i
    on o.order_id = i.order_id
where abs(o.order_amount - coalesce(i.total_line_amount, 0)) > 0.01