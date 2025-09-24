-- Copy CSV data from S3 to raw tables
-- Note: Replace 'your-s3-bucket' with your actual S3 bucket name
-- Note: Replace 'your-iam-role-arn' with your actual IAM role ARN

-- Copy customers data
COPY raw.customers
FROM 's3://your-s3-bucket/data/csv/customers.csv'
IAM_ROLE 'your-iam-role-arn'
CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TRUNCATECOLUMNS
BLANKSASNULL
EMPTYASNULL;

-- Copy products data
COPY raw.products
FROM 's3://your-s3-bucket/data/csv/products.csv'
IAM_ROLE 'your-iam-role-arn'
CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TRUNCATECOLUMNS
BLANKSASNULL
EMPTYASNULL;

-- Copy orders data
COPY raw.orders
FROM 's3://your-s3-bucket/data/csv/orders.csv'
IAM_ROLE 'your-iam-role-arn'
CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TRUNCATECOLUMNS
BLANKSASNULL
EMPTYASNULL;