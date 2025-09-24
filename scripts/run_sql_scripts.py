#!/usr/bin/env python3
"""
Script to run SQL scripts against Redshift
Usage: python run_sql_scripts.py --host your-host --user your-user --password your-password --database your-db
"""

import argparse
import psycopg2
import os
from pathlib import Path

def run_sql_file(connection, file_path):
    """Execute SQL file against Redshift"""
    with open(file_path, 'r') as file:
        sql_content = file.read()
    
    # Split by semicolon and execute each statement separately
    statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
    
    cursor = connection.cursor()
    try:
        for statement in statements:
            if statement:
                print(f"Executing: {statement[:100]}...")
                cursor.execute(statement)
                connection.commit()
                print("✓ Success")
    except Exception as e:
        print(f"✗ Error: {e}")
        connection.rollback()
        raise
    finally:
        cursor.close()

def main():
    parser = argparse.ArgumentParser(description='Run SQL scripts against Redshift')
    parser.add_argument('--host', required=True, help='Redshift host')
    parser.add_argument('--user', required=True, help='Database user')
    parser.add_argument('--password', required=True, help='Database password')
    parser.add_argument('--database', required=True, help='Database name')
    parser.add_argument('--port', default=5439, type=int, help='Database port')
    parser.add_argument('--sql-path', default='./sql', help='SQL scripts directory')
    args = parser.parse_args()
    
    # Connect to Redshift
    try:
        connection = psycopg2.connect(
            host=args.host,
            user=args.user,
            password=args.password,
            database=args.database,
            port=args.port
        )
        print("✓ Connected to Redshift")
    except Exception as e:
        print(f"✗ Failed to connect to Redshift: {e}")
        return
    
    sql_path = Path(args.sql_path)
    
    # Run setup scripts
    setup_path = sql_path / 'setup'
    if setup_path.exists():
        print("\n=== Running Setup Scripts ===")
        for sql_file in sorted(setup_path.glob('*.sql')):
            print(f"\nRunning {sql_file.name}:")
            run_sql_file(connection, sql_file)
    
    # Run staging scripts
    staging_path = sql_path / 'staging'
    if staging_path.exists():
        print("\n=== Running Staging Scripts ===")
        for sql_file in sorted(staging_path.glob('*.sql')):
            print(f"\nRunning {sql_file.name}:")
            run_sql_file(connection, sql_file)
    
    # Run copy scripts
    copy_path = sql_path / 'copy'
    if copy_path.exists():
        print("\n=== Running Copy Scripts ===")
        for sql_file in sorted(copy_path.glob('*.sql')):
            print(f"\nRunning {sql_file.name}:")
            print("Note: Make sure to update S3 bucket and IAM role in the copy scripts")
            # run_sql_file(connection, sql_file)  # Uncomment when ready
    
    # Run check scripts
    checks_path = sql_path / 'checks'
    if checks_path.exists():
        print("\n=== Running Data Quality Checks ===")
        for sql_file in sorted(checks_path.glob('*.sql')):
            print(f"\nRunning {sql_file.name}:")
            run_sql_file(connection, sql_file)
    
    connection.close()
    print("\n✓ All SQL scripts completed!")

if __name__ == "__main__":
    main()