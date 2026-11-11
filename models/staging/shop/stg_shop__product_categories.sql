select *
from {{ source('shop', 'product_categories') }}