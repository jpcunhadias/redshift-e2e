# End-to-End Redshift Data Pipeline

This project demonstrates a complete, end-to-end data pipeline using AWS Redshift, S3, and dbt (Data Build Tool). The pipeline ingests raw CSV data, loads it into Redshift, transforms it into a clean, analytics-ready format, and provides a structure for running data quality tests.

## Architecture

The project follows a robust, three-layer data warehousing architecture (ELT - Extract, Load, Transform):

```
+-----------+     +----------------+     +------------------------+     +---------------------+     +-------------------+
| Local CSV | --> |   S3 Bucket    | --> | Redshift `raw_data`    | --> | Redshift `staging`  | --> | Redshift `marts`  |
|   Files   |     | (raw_data/)    |     |         Tables         |     |        Views        |     |      Tables       |
+-----------+     +----------------+     +------------------------+     +---------------------+     +-------------------+
                                                       |                                |                     |
                                                     (make copy)                     (dbt run)             (Analytics)
```

1.  **Extract & Load**: Raw data is uploaded to an S3 bucket. A `COPY` command loads this data into `raw_data` tables in Redshift. These tables are immutable and represent the source data.
2.  **Transform**: dbt reads from the `raw_data` tables, performs transformations, and materializes the results in two layers:
    *   **`staging`**: Views that perform basic cleaning, casting, and renaming of the raw data.
    *   **`marts`**: The final, business-facing tables (facts and dimensions) that are ready for analysis.

## Prerequisites

To run this project, you will need:

*   [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials.
*   [psql](https://www.postgresql.org/docs/current/app-psql.html) (PostgreSQL command-line tool).
*   [dbt Core](https://docs.getdbt.com/docs/core/installation).
*   `make`

## Setup and Configuration

1.  **AWS Infrastructure**:
    *   Create a Redshift Serverless workgroup and namespace.
    *   Create an S3 bucket to store the raw data.
    *   Create an IAM role that has `S3ReadOnlyAccess` and associate it with your Redshift namespace. This allows Redshift to read data from your S3 bucket.

2.  **Makefile Configuration**:
    *   Open the `Makefile` in the root of the project.
    *   Update the following variables with your specific AWS resource names and credentials:
        *   `AWS_BUCKET`: Your S3 bucket name.
        *   `REDSHIFT_HOST`: Your Redshift workgroup host.
        *   The IAM role ARN in `sql/03_copy_stage.sql`.

## How to Run the Pipeline

The entire pipeline can be run using `make`. You will need to set the `PGPASSWORD` environment variable for your Redshift admin user.

```bash
export PGPASSWORD='your_redshift_password'
```

### Pipeline Steps

You can run the entire pipeline at once or step by step.

*   **Run the entire pipeline:**
    ```bash
    make all
    ```

*   **Run step-by-step:**
    1.  **Upload raw data to S3:**
        ```bash
        make upload
        ```
    2.  **Initialize the database (create schemas):**
        ```bash
        make init
        ```
    3.  **Create the raw tables (DDL):**
        ```bash
        make ddl
        ```
    4.  **Copy data from S3 to Redshift:**
        ```bash
        make copy
        ```
    5.  **Run dbt transformations and tests:**
        ```bash
        make dbt
        ```

## Project Structure

*   `data/raw/`: Contains the raw CSV data files.
*   `dbt_project/`: Contains the dbt project, models, and tests.
    *   `models/staging/`: dbt models for cleaning and preparing the data.
    *   `models/marts/`: dbt models for the final fact and dimension tables.
*   `sql/`: Contains the SQL scripts for database setup (schema creation, table creation, data loading).
*   `Makefile`: Automates the pipeline execution.
