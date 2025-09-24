# Redshift End-to-End Data Pipeline Demo

A comprehensive demonstration of a modern data pipeline using Amazon Redshift, featuring:
- Sample CSV/JSON data loading to S3
- SQL scripts for database setup, staging, and data loading
- dbt models for data transformation (staging + marts with dimensions and facts)
- Optional AWS Glue PySpark job for data cleanup
- Makefile automation for the entire pipeline

## 🏗️ Architecture

```
┌─────────┐    ┌─────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│ CSV/JSON│───▶│   S3    │───▶│   Redshift   │───▶│ dbt Models  │───▶│ Analytics    │
│  Data   │    │ Bucket  │    │ Raw Tables   │    │ (Staging +  │    │ Ready Data   │
└─────────┘    └─────────┘    └──────────────┘    │  Marts)     │    └──────────────┘
                                      ▲           └─────────────┘
                                      │
                               ┌──────────────┐
                               │ Glue PySpark │
                               │ Cleanup Job  │
                               └──────────────┘
```

## 📁 Project Structure

```
redshift-e2e/
├── data/                          # Sample data files
│   ├── csv/                      # CSV data files
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   └── orders.csv
│   └── json/                     # JSON data files
│       ├── order_items.json
│       └── suppliers.json
├── sql/                          # SQL scripts
│   ├── setup/                    # Database setup scripts
│   │   ├── 01_create_schemas.sql
│   │   └── 02_create_raw_tables.sql
│   ├── staging/                  # Staging table scripts
│   │   └── 01_staging_tables.sql
│   ├── copy/                     # COPY commands for S3 to Redshift
│   │   ├── 01_copy_csv_data.sql
│   │   └── 02_copy_json_data.sql
│   └── checks/                   # Data quality checks
│       └── 01_data_quality_checks.sql
├── dbt/                          # dbt project
│   ├── models/
│   │   ├── staging/              # Staging models
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   ├── stg_suppliers.sql
│   │   │   └── schema.yml
│   │   └── marts/                # Analytics marts
│   │       ├── dims/             # Dimension tables
│   │       │   ├── dim_customers.sql
│   │       │   ├── dim_products.sql
│   │       │   └── dim_suppliers.sql
│   │       └── facts/            # Fact tables
│   │           ├── fact_orders.sql
│   │           └── fact_order_items.sql
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── packages.yml
├── glue/                         # AWS Glue jobs
│   └── order_cleanup_job.py      # PySpark job for data cleanup
├── scripts/                      # Helper scripts
│   ├── upload_to_s3.py          # Upload data to S3
│   └── run_sql_scripts.py       # Execute SQL scripts
├── Makefile                      # Automation commands
├── requirements.txt              # Python dependencies
├── .env.example                 # Environment variables template
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites

- AWS Account with Redshift cluster
- S3 bucket for data storage
- IAM role with Redshift and S3 permissions
- Python 3.7+
- Make (optional, for automation)

### 1. Environment Setup

```bash
# Clone the repository
git clone <repository-url>
cd redshift-e2e

# Copy environment template
cp .env.example .env

# Edit .env with your actual values
nano .env
```

### 2. Install Dependencies

```bash
# Using make
make setup

# Or manually
pip install -r requirements.txt
```

### 3. Set Environment Variables

Export your environment variables or source the .env file:

```bash
export S3_BUCKET=your-s3-bucket
export REDSHIFT_HOST=your-redshift-cluster.region.redshift.amazonaws.com
export REDSHIFT_USER=your-username
export REDSHIFT_PASSWORD=your-password
export REDSHIFT_DATABASE=dev
export IAM_ROLE_ARN=arn:aws:iam::account:role/RedshiftRole
```

### 4. Run the Complete Pipeline

```bash
# Run everything with one command
make full-pipeline
```

Or run steps individually:

```bash
# Step 1: Upload sample data to S3
make upload-data

# Step 2: Setup Redshift schemas and tables
make setup-redshift

# Step 3: Load data from S3 to Redshift
make run-copy

# Step 4: Run data quality checks
make run-checks

# Step 5: Run dbt models
make run-dbt

# Step 6: Test dbt models
make test-dbt

# Optional: Run Glue cleanup job
make run-glue
```

## 📊 Data Model

### Raw Layer
- **customers**: Customer information from CSV
- **products**: Product catalog from CSV  
- **orders**: Order transactions from CSV
- **order_items**: Order line items from JSON
- **suppliers**: Supplier information from JSON

### Staging Layer
- **stg_customers**: Cleaned and validated customer data
- **stg_products**: Cleaned product data with supplier info
- **stg_orders**: Processed orders with derived fields
- **stg_order_items**: Validated order items with calculations
- **stg_suppliers**: Standardized supplier information

### Analytics Layer (Marts)

#### Dimensions
- **dim_customers**: Customer dimension with lifetime metrics
- **dim_products**: Product dimension with sales performance
- **dim_suppliers**: Supplier dimension with catalog metrics

#### Facts
- **fact_orders**: Order transactions with business metrics
- **fact_order_items**: Detailed line item transactions

## 🛠️ Available Commands

View all available commands:
```bash
make help
```

Key commands:
- `make validate-env`: Check environment variables
- `make upload-data`: Upload sample data to S3
- `make setup-redshift`: Create schemas and tables
- `make run-copy`: Load data from S3
- `make run-checks`: Run data quality checks
- `make run-dbt`: Execute dbt transformations
- `make test-dbt`: Run dbt tests
- `make full-pipeline`: Complete end-to-end pipeline
- `make clean`: Clean up temporary files
- `make reset-redshift`: Drop all schemas (CAUTION!)

## 🧪 Testing

### dbt Tests
```bash
# Run dbt tests
make test-dbt

# Or manually
cd dbt && dbt test
```

### Data Quality Checks
```bash
# Run SQL-based quality checks
make run-checks
```

### SQL Validation
```bash
# Lint SQL files (requires sqlfluff)
make validate-sql

# Format SQL files
make format-sql
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `S3_BUCKET` | S3 bucket for data storage | `my-data-bucket` |
| `REDSHIFT_HOST` | Redshift cluster endpoint | `cluster.region.redshift.amazonaws.com` |
| `REDSHIFT_USER` | Database username | `admin` |
| `REDSHIFT_PASSWORD` | Database password | `password123` |
| `REDSHIFT_DATABASE` | Database name | `dev` |
| `IAM_ROLE_ARN` | IAM role for Redshift | `arn:aws:iam::123:role/RedshiftRole` |

### dbt Configuration

dbt profiles are configured in `dbt/profiles.yml`. The profile uses environment variables for connection details.

## 🔧 Customization

### Adding New Data Sources

1. Add sample data files to `data/csv/` or `data/json/`
2. Create raw table DDL in `sql/setup/`
3. Add COPY commands in `sql/copy/`
4. Create staging models in `dbt/models/staging/`
5. Update marts as needed

### Modifying Transformations

- Staging transformations: Edit files in `dbt/models/staging/`
- Business logic: Modify marts in `dbt/models/marts/`
- Add tests: Update `schema.yml` files

### AWS Glue Integration

The included Glue job (`glue/order_cleanup_job.py`) demonstrates:
- Data quality validation
- Duplicate removal
- Data standardization
- Partitioned output to S3

## 🔍 Monitoring & Observability

### dbt Docs
```bash
cd dbt && dbt docs generate && dbt docs serve
```

### Query Performance
- Check `stl_query` and `stv_query_summary` in Redshift
- Monitor WLM queues and query slots
- Use dbt model timing for performance analysis

## 🚨 Troubleshooting

### Common Issues

1. **COPY command fails**
   - Verify S3 bucket permissions
   - Check IAM role trust relationship
   - Ensure data files exist in S3

2. **dbt connection errors**
   - Verify Redshift credentials
   - Check security group rules
   - Confirm VPC configuration

3. **Data quality issues**
   - Run `make run-checks` to identify problems
   - Check staging model logic
   - Validate source data format

### Debug Commands
```bash
# Check Redshift connection
psql -h $REDSHIFT_HOST -U $REDSHIFT_USER -d $REDSHIFT_DATABASE

# Validate dbt models without running
make check-dbt

# Test S3 connectivity
aws s3 ls s3://$S3_BUCKET/
```

## 📝 Development

### Adding Tests
- Add dbt tests in `schema.yml` files  
- Create custom SQL tests in `dbt/tests/`
- Add data quality checks in `sql/checks/`

### Code Quality
- Use `sqlfluff` for SQL linting
- Follow dbt style guide
- Document all models and columns

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions or issues:
- Check the troubleshooting section
- Review dbt logs in `dbt/logs/`
- Open an issue in the repository