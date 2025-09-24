-- Copy JSON data from S3 to raw tables
-- Note: Replace 'your-s3-bucket' with your actual S3 bucket name
-- Note: Replace 'your-iam-role-arn' with your actual IAM role ARN

-- Copy order items data (JSON)
COPY raw.order_items
FROM 's3://your-s3-bucket/data/json/order_items.json'
IAM_ROLE 'your-iam-role-arn'
JSON 'auto'
TRUNCATECOLUMNS
BLANKSASNULL
EMPTYASNULL;

-- Copy suppliers data (JSON with nested address)
-- First, create a temporary staging table for complex JSON structure
CREATE TEMP TABLE temp_suppliers_json (
    json_data SUPER
);

COPY temp_suppliers_json
FROM 's3://your-s3-bucket/data/json/suppliers.json'
IAM_ROLE 'your-iam-role-arn'
JSON 'auto';

-- Parse and insert into raw.suppliers table
INSERT INTO raw.suppliers (
    supplier_id,
    supplier_name,
    contact_person,
    email,
    phone,
    address_street,
    address_city,
    address_state,
    address_zip,
    rating
)
SELECT 
    json_data.supplier_id::INTEGER,
    json_data.supplier_name::VARCHAR(100),
    json_data.contact_person::VARCHAR(100),
    json_data.email::VARCHAR(100),
    json_data.phone::VARCHAR(20),
    json_data.address.street::VARCHAR(200),
    json_data.address.city::VARCHAR(50),
    json_data.address.state::VARCHAR(2),
    json_data.address.zip::VARCHAR(10),
    json_data.rating::DECIMAL(3,2)
FROM temp_suppliers_json;

DROP TABLE temp_suppliers_json;