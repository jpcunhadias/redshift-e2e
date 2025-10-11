AWS_BUCKET=rs-demo-project
REDSHIFT_HOST=rs-demo-wg.087432099930.us-east-1.redshift-serverless.amazonaws.com
REDSHIFT_PORT=5439
REDSHIFT_DB=dev
SQL=sql

.PHONY: upload init ddl copy dbt all

upload:
	aws s3 cp data/raw/ s3://$(AWS_BUCKET)/raw/ --recursive

init:
	PGPASSWORD=$(PGPASSWORD) psql "host=$(REDSHIFT_HOST) port=$(REDSHIFT_PORT) dbname=$(REDSHIFT_DB) sslmode=require" -U admin -f $(SQL)/00_init.sql
	PGPASSWORD=$(PGPASSWORD) psql "host=$(REDSHIFT_HOST) port=$(REDSHIFT_PORT) dbname=$(REDSHIFT_DB) sslmode=require" -U admin -f $(SQL)/01a_raw_schema.sql

ddl:
	PGPASSWORD=$(PGPASSWORD) psql "host=$(REDSHIFT_HOST) port=$(REDSHIFT_PORT) dbname=$(REDSHIFT_DB) sslmode=require" -U admin -f $(SQL)/02_stage_tables.sql

copy:
	PGPASSWORD=$(PGPASSWORD) psql "host=$(REDSHIFT_HOST) port=$(REDSHIFT_PORT) dbname=$(REDSHIFT_DB) sslmode=require" -U admin -f $(SQL)/03_copy_stage.sql

dbt:
	cd dbt_project && dbt run && dbt test

all: upload init ddl copy dbt
