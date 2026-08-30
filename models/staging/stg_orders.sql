/*
  Staging Model: stg_orders
  Purpose: Normalizes transaction records, parses order dates, and standardizes amounts.
*/

with source as (
    -- Read from the raw_orders seed table
    select * from {{ ref('raw_orders') }}
)

select
    -- Cast primary and foreign keys
    cast(order_id as integer)       as order_id,
    cast(customer_id as integer)    as customer_id,
    
    -- Parse dates and monetary fields
    cast(order_date as date)        as order_date,
    cast(amount as numeric(10, 2))  as order_amount,
    
    -- Transaction status (completed, cancelled, etc.)
    cast(status as varchar)         as order_status
from source