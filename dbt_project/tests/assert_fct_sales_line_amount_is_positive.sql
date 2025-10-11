-- A custom data test to ensure that the line_amount in fct_sales is never negative.
-- The test will pass if this query returns no rows.

select
  *
from {{ ref('fct_sales') }}
where line_amount < 0
