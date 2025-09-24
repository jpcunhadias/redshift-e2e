-- Create raw tables for CSV data
CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    registration_date DATE
);

CREATE TABLE IF NOT EXISTS raw.products (
    product_id INTEGER,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    supplier_id INTEGER,
    created_date DATE
);

CREATE TABLE IF NOT EXISTS raw.orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    shipping_address VARCHAR(500),
    payment_method VARCHAR(30)
);

-- Create raw tables for JSON data
CREATE TABLE IF NOT EXISTS raw.order_items (
    order_item_id INTEGER,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS raw.suppliers (
    supplier_id INTEGER,
    supplier_name VARCHAR(100),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address_street VARCHAR(200),
    address_city VARCHAR(50),
    address_state VARCHAR(2),
    address_zip VARCHAR(10),
    rating DECIMAL(3,2)
);