# Redshift E2E Pipeline Makefile
# Usage: make help

.PHONY: help setup upload-data setup-redshift run-copy run-checks run-dbt run-glue clean validate-env

# Default target
help: ## Show this help message
	@echo "Redshift E2E Pipeline Commands:"
	@echo "================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Environment variables
S3_BUCKET ?= your-s3-bucket
REDSHIFT_HOST ?= your-redshift-cluster.region.redshift.amazonaws.com
REDSHIFT_USER ?= your-username
REDSHIFT_PASSWORD ?= your-password
REDSHIFT_DATABASE ?= dev
IAM_ROLE_ARN ?= arn:aws:iam::account:role/RedshiftRole

validate-env: ## Validate required environment variables
	@echo "Validating environment variables..."
	@test -n "$(S3_BUCKET)" || (echo "Error: S3_BUCKET not set" && exit 1)
	@test -n "$(REDSHIFT_HOST)" || (echo "Error: REDSHIFT_HOST not set" && exit 1)
	@test -n "$(REDSHIFT_USER)" || (echo "Error: REDSHIFT_USER not set" && exit 1)
	@test -n "$(REDSHIFT_PASSWORD)" || (echo "Error: REDSHIFT_PASSWORD not set" && exit 1)
	@test -n "$(IAM_ROLE_ARN)" || (echo "Error: IAM_ROLE_ARN not set" && exit 1)
	@echo "✓ Environment variables validated"

setup: ## Install required Python dependencies
	@echo "Installing Python dependencies..."
	pip install boto3 psycopg2-binary dbt-redshift
	@echo "✓ Dependencies installed"

upload-data: validate-env ## Upload sample data to S3
	@echo "Uploading sample data to S3..."
	python scripts/upload_to_s3.py --bucket $(S3_BUCKET) --data-path ./data
	@echo "✓ Data uploaded to s3://$(S3_BUCKET)/"

setup-redshift: validate-env ## Create schemas and raw tables in Redshift
	@echo "Setting up Redshift schemas and tables..."
	python scripts/run_sql_scripts.py \
		--host $(REDSHIFT_HOST) \
		--user $(REDSHIFT_USER) \
		--password $(REDSHIFT_PASSWORD) \
		--database $(REDSHIFT_DATABASE) \
		--sql-path ./sql
	@echo "✓ Redshift setup completed"

update-copy-scripts: validate-env ## Update COPY scripts with actual S3 bucket and IAM role
	@echo "Updating COPY scripts with environment variables..."
	@sed -i 's/your-s3-bucket/$(S3_BUCKET)/g' sql/copy/*.sql
	@sed -i 's/your-iam-role-arn/$(IAM_ROLE_ARN)/g' sql/copy/*.sql
	@echo "✓ COPY scripts updated"

run-copy: validate-env update-copy-scripts ## Load data from S3 to Redshift raw tables
	@echo "Running COPY commands to load data..."
	python scripts/run_sql_scripts.py \
		--host $(REDSHIFT_HOST) \
		--user $(REDSHIFT_USER) \
		--password $(REDSHIFT_PASSWORD) \
		--database $(REDSHIFT_DATABASE) \
		--sql-path ./sql/copy
	@echo "✓ Data copied to Redshift"

run-checks: validate-env ## Run data quality checks
	@echo "Running data quality checks..."
	python scripts/run_sql_scripts.py \
		--host $(REDSHIFT_HOST) \
		--user $(REDSHIFT_USER) \
		--password $(REDSHIFT_PASSWORD) \
		--database $(REDSHIFT_DATABASE) \
		--sql-path ./sql/checks
	@echo "✓ Data quality checks completed"

setup-dbt: ## Setup dbt profile and install dependencies
	@echo "Setting up dbt..."
	cd dbt && dbt deps
	@echo "✓ dbt setup completed"

run-dbt: validate-env setup-dbt ## Run dbt models to create staging and marts
	@echo "Running dbt models..."
	cd dbt && REDSHIFT_HOST=$(REDSHIFT_HOST) \
		REDSHIFT_USER=$(REDSHIFT_USER) \
		REDSHIFT_PASSWORD=$(REDSHIFT_PASSWORD) \
		REDSHIFT_DBNAME=$(REDSHIFT_DATABASE) \
		dbt run
	@echo "✓ dbt models completed"

test-dbt: validate-env ## Run dbt tests
	@echo "Running dbt tests..."
	cd dbt && REDSHIFT_HOST=$(REDSHIFT_HOST) \
		REDSHIFT_USER=$(REDSHIFT_USER) \
		REDSHIFT_PASSWORD=$(REDSHIFT_PASSWORD) \
		REDSHIFT_DBNAME=$(REDSHIFT_DATABASE) \
		dbt test
	@echo "✓ dbt tests completed"

run-glue: validate-env ## Submit Glue job for order cleanup (requires AWS CLI configured)
	@echo "Submitting Glue job for order cleanup..."
	@echo "Note: Make sure you have created the Glue job in AWS console first"
	@echo "Glue job script location: ./glue/order_cleanup_job.py"
	@echo "Job parameters needed:"
	@echo "  --S3_BUCKET=$(S3_BUCKET)"
	@echo "  --DATABASE_NAME=your-glue-database"
	@echo "  --RAW_TABLE_NAME=orders"
	@echo "  --CLEANED_TABLE_NAME=orders_cleaned"
	@echo "Use AWS CLI: aws glue start-job-run --job-name your-cleanup-job --arguments '--S3_BUCKET=$(S3_BUCKET),--DATABASE_NAME=your-db'"

# Full pipeline commands
full-pipeline: validate-env setup upload-data setup-redshift run-copy run-checks run-dbt test-dbt ## Run the complete pipeline
	@echo "🎉 Full pipeline completed successfully!"

reset-redshift: validate-env ## Drop all schemas (CAUTION: This will delete all data!)
	@echo "⚠️  WARNING: This will drop all schemas and data!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "Dropping schemas..."
	python -c "import psycopg2; \
		conn = psycopg2.connect(host='$(REDSHIFT_HOST)', user='$(REDSHIFT_USER)', password='$(REDSHIFT_PASSWORD)', database='$(REDSHIFT_DATABASE)'); \
		cur = conn.cursor(); \
		cur.execute('DROP SCHEMA IF EXISTS analytics CASCADE'); \
		cur.execute('DROP SCHEMA IF EXISTS staging CASCADE'); \
		cur.execute('DROP SCHEMA IF EXISTS raw CASCADE'); \
		conn.commit(); conn.close()"
	@echo "✓ Schemas dropped"

clean: ## Clean up temporary files
	@echo "Cleaning up temporary files..."
	rm -rf dbt/target/
	rm -rf dbt/dbt_packages/
	rm -rf __pycache__/
	find . -name "*.pyc" -delete
	@echo "✓ Cleanup completed"

# Development helpers
validate-sql: ## Validate SQL syntax (requires sqlfluff)
	@echo "Validating SQL syntax..."
	@command -v sqlfluff >/dev/null 2>&1 || (echo "sqlfluff not installed. Run: pip install sqlfluff" && exit 1)
	sqlfluff lint sql/
	@echo "✓ SQL validation completed"

format-sql: ## Format SQL files (requires sqlfluff)
	@echo "Formatting SQL files..."
	@command -v sqlfluff >/dev/null 2>&1 || (echo "sqlfluff not installed. Run: pip install sqlfluff" && exit 1)
	sqlfluff fix sql/
	@echo "✓ SQL formatting completed"

check-dbt: ## Check dbt model compilation without running
	@echo "Checking dbt model compilation..."
	cd dbt && REDSHIFT_HOST=$(REDSHIFT_HOST) \
		REDSHIFT_USER=$(REDSHIFT_USER) \
		REDSHIFT_PASSWORD=$(REDSHIFT_PASSWORD) \
		REDSHIFT_DBNAME=$(REDSHIFT_DATABASE) \
		dbt compile
	@echo "✓ dbt compilation check completed"