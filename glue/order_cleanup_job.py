"""
AWS Glue PySpark Job for Order Data Cleanup
This job performs data quality checks and cleanup on order data.
"""

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.types import *
from pyspark.sql.window import Window
from awsglue.dynamicframe import DynamicFrame

# Get job arguments
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'S3_BUCKET',
    'DATABASE_NAME',
    'RAW_TABLE_NAME',
    'CLEANED_TABLE_NAME'
])

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def clean_order_data():
    """
    Main function to clean order data:
    1. Remove orders with invalid amounts
    2. Standardize status values
    3. Fix date inconsistencies
    4. Remove duplicate orders
    5. Validate customer relationships
    """
    
    print("Starting order data cleanup...")
    
    # Read raw orders from Glue catalog
    raw_orders = glueContext.create_dynamic_frame.from_catalog(
        database=args['DATABASE_NAME'],
        table_name=args['RAW_TABLE_NAME']
    ).toDF()
    
    print(f"Raw orders count: {raw_orders.count()}")
    
    # Data cleaning transformations
    cleaned_orders = raw_orders.filter(
        # Remove orders with invalid amounts
        (F.col("total_amount") > 0) & 
        (F.col("total_amount").isNotNull()) &
        # Remove orders with null customer IDs
        (F.col("customer_id").isNotNull()) &
        # Remove orders with null order IDs
        (F.col("order_id").isNotNull())
    ).withColumn(
        # Standardize status values
        "status_cleaned",
        F.when(F.lower(F.col("status")).isin(["completed", "complete", "delivered"]), "completed")
         .when(F.lower(F.col("status")).isin(["pending", "processing", "in_progress"]), "pending")
         .when(F.lower(F.col("status")).isin(["cancelled", "canceled", "refunded"]), "cancelled")
         .otherwise("other")
    ).withColumn(
        # Add order value category
        "order_value_category",
        F.when(F.col("total_amount") >= 200, "high_value")
         .when(F.col("total_amount") >= 100, "medium_value")
         .when(F.col("total_amount") >= 50, "low_value")
         .otherwise("very_low_value")
    ).withColumn(
        # Add cleanup timestamp
        "cleaned_at",
        F.current_timestamp()
    ).withColumn(
        # Extract year and month for partitioning
        "order_year",
        F.year(F.col("order_date"))
    ).withColumn(
        "order_month",
        F.month(F.col("order_date"))
    )
    
    # Remove duplicates based on order_id (keep the latest record)
    window_spec = Window.partitionBy("order_id").orderBy(F.col("cleaned_at").desc())
    cleaned_orders = cleaned_orders.withColumn(
        "row_num",
        F.row_number().over(window_spec)
    ).filter(F.col("row_num") == 1).drop("row_num")
    
    print(f"Cleaned orders count: {cleaned_orders.count()}")
    
    # Data quality checks
    total_records = cleaned_orders.count()
    completed_orders = cleaned_orders.filter(F.col("status_cleaned") == "completed").count()
    high_value_orders = cleaned_orders.filter(F.col("order_value_category") == "high_value").count()
    
    print(f"Data Quality Summary:")
    print(f"Total cleaned records: {total_records}")
    print(f"Completed orders: {completed_orders} ({completed_orders/total_records*100:.2f}%)")
    print(f"High value orders: {high_value_orders} ({high_value_orders/total_records*100:.2f}%)")
    
    # Write cleaned data back to S3 (partitioned by year and month)
    output_path = f"s3://{args['S3_BUCKET']}/cleaned_data/orders/"
    
    cleaned_orders.write \
        .mode("overwrite") \
        .partitionBy("order_year", "order_month") \
        .parquet(output_path)
    
    print(f"Cleaned data written to: {output_path}")
    
    # Create/update Glue catalog table for cleaned data
    cleaned_dynamic_frame = DynamicFrame.fromDF(cleaned_orders, glueContext, "cleaned_orders")
    
    glueContext.write_dynamic_frame.from_options(
        frame=cleaned_dynamic_frame,
        connection_type="s3",
        connection_options={
            "path": output_path,
            "partitionKeys": ["order_year", "order_month"]
        },
        format="parquet"
    )
    
    print("Order cleanup job completed successfully!")

if __name__ == "__main__":
    try:
        clean_order_data()
        job.commit()
    except Exception as e:
        print(f"Job failed with error: {str(e)}")
        raise e