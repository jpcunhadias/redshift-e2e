-- Create staging tables with data quality enhancements
CREATE TABLE IF NOT EXISTS staging.dim_customers (
    customer_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(101),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    registration_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP DEFAULT GETDATE()
);

CREATE TABLE IF NOT EXISTS staging.dim_products (
    product_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    supplier_id INTEGER,
    created_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP DEFAULT GETDATE()
);

CREATE TABLE IF NOT EXISTS staging.dim_suppliers (
    supplier_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    supplier_id INTEGER NOT NULL,
    supplier_name VARCHAR(100),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    full_address VARCHAR(500),
    address_street VARCHAR(200),
    address_city VARCHAR(50),
    address_state VARCHAR(2),
    address_zip VARCHAR(10),
    rating DECIMAL(3,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP DEFAULT GETDATE()
);

CREATE TABLE IF NOT EXISTS staging.fact_orders (
    order_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    order_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    order_date DATE,
    total_amount DECIMAL(10,2),
    order_status VARCHAR(20),
    shipping_address VARCHAR(500),
    payment_method VARCHAR(30),
    order_year INTEGER,
    order_month INTEGER,
    order_quarter INTEGER,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP DEFAULT GETDATE()
);

CREATE TABLE IF NOT EXISTS staging.fact_order_items (
    order_item_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    order_item_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP DEFAULT GETDATE()
);