{{ config(materialized='table', distributed_replicated=true, orientation='column') }}

select
    p.product_id,
    p.product_name,
    p.brand,
    categories.category_name,
    categories.parent_category_name,
    categories.root_category_name
from {{ ref('stg_shop__products') }} as p
left join {{ ref('int_product_categories_hierarchy') }} as categories
    on p.category = categories.category_name