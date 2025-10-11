-- sql/03_copy_stage.sql
COPY raw_data.raw_customers
FROM 's3://rs-demo-project/raw/customers.csv'
IAM_ROLE 'arn:aws:iam::087432099930:role/service-role/AmazonRedshift-CommandsAccessRole-20251011T110923'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto';

COPY raw_data.raw_products
FROM 's3://rs-demo-project/raw/products.csv'
IAM_ROLE 'arn:aws:iam::087432099930:role/service-role/AmazonRedshift-CommandsAccessRole-20251011T110923'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto';

COPY raw_data.raw_orders
FROM 's3://rs-demo-project/raw/orders.csv'
IAM_ROLE 'arn:aws:iam::087432099930:role/service-role/AmazonRedshift-CommandsAccessRole-20251011T110923'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto';
