-- Data quality checks for raw data
-- Run these queries to validate data integrity after loading

-- Check for duplicate customers
SELECT 'Duplicate customers' as check_name, COUNT(*) as issue_count
FROM (
    SELECT customer_id, COUNT(*) as cnt
    FROM raw.customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
);

-- Check for missing customer information
SELECT 'Missing customer email' as check_name, COUNT(*) as issue_count
FROM raw.customers
WHERE email IS NULL OR email = '';

-- Check for invalid product prices
SELECT 'Invalid product prices' as check_name, COUNT(*) as issue_count
FROM raw.products
WHERE price <= 0 OR price IS NULL;

-- Check for orphaned orders (orders without valid customers)
SELECT 'Orphaned orders' as check_name, COUNT(*) as issue_count
FROM raw.orders o
LEFT JOIN raw.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check for orphaned order items (order items without valid orders)
SELECT 'Orphaned order items' as check_name, COUNT(*) as issue_count
FROM raw.order_items oi
LEFT JOIN raw.orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for invalid order totals
SELECT 'Invalid order totals' as check_name, COUNT(*) as issue_count
FROM raw.orders
WHERE total_amount <= 0 OR total_amount IS NULL;

-- Check data counts
SELECT 'Customers loaded' as metric, COUNT(*) as count FROM raw.customers
UNION ALL
SELECT 'Products loaded' as metric, COUNT(*) as count FROM raw.products
UNION ALL
SELECT 'Orders loaded' as metric, COUNT(*) as count FROM raw.orders
UNION ALL
SELECT 'Order items loaded' as metric, COUNT(*) as count FROM raw.order_items
UNION ALL
SELECT 'Suppliers loaded' as metric, COUNT(*) as count FROM raw.suppliers;

-- Check date ranges
SELECT 
    'Customer registration dates' as metric,
    MIN(registration_date) as min_date,
    MAX(registration_date) as max_date,
    COUNT(*) as total_records
FROM raw.customers
UNION ALL
SELECT 
    'Order dates' as metric,
    MIN(order_date) as min_date,
    MAX(order_date) as max_date,
    COUNT(*) as total_records
FROM raw.orders;