/*
  Staging Model: stg_customers
  Purpose: Type-casts customer identifier and demographic fields
*/

with source as (
    -- Read from the raw_customers seed table
    select * from {{ ref('raw_customers') }}
)

select
    -- Cast ID to integer for clean relational joins
    cast(customer_id as integer) as customer_id,
    
    -- Cast text attributes to standard varchar
    cast(first_name as varchar)  as first_name,
    cast(last_name as varchar)   as last_name,
    cast(city as varchar)        as city
from source