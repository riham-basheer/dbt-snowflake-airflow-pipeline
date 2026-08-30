/*
  Mart Model: customer_order_summary
  Materialization: Table
  Purpose: Aggregates customer lifetime transaction history (total orders, total spend, activity dates)
*/

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_aggregates as (
    -- Aggregate metrics per customer
    select
        customer_id,
        
        -- Count total unique orders placed
        count(distinct order_id) as total_orders,
        
        -- Calculate total monetary spend (sum only completed purchases)
        sum(case when order_status = 'completed' then order_amount else 0 end) as total_spend,
        
        -- Customer transaction activity bounds
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from orders
    group by customer_id
)

select
    -- Dimension attributes
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    
    -- Aggregated fact metrics (default nulls to 0 for customers with no orders)
    coalesce(oa.total_orders, 0) as total_orders,
    coalesce(oa.total_spend, 0.00) as total_spend,
    oa.first_order_date,
    oa.most_recent_order_date
from customers c
left join order_aggregates oa using (customer_id)