select *
from {{ source('shop', 'products') }}