#!/usr/bin/env python3
"""
Script to upload sample data files to S3
Usage: python upload_to_s3.py --bucket your-bucket-name
"""

import argparse
import boto3
import os
from pathlib import Path

def upload_files_to_s3(bucket_name, local_path, s3_prefix=""):
    """Upload files from local directory to S3 bucket"""
    s3_client = boto3.client('s3')
    
    for root, dirs, files in os.walk(local_path):
        for file in files:
            local_file_path = os.path.join(root, file)
            relative_path = os.path.relpath(local_file_path, local_path)
            s3_key = f"{s3_prefix}/{relative_path}" if s3_prefix else relative_path
            
            try:
                s3_client.upload_file(local_file_path, bucket_name, s3_key)
                print(f"✓ Uploaded {local_file_path} -> s3://{bucket_name}/{s3_key}")
            except Exception as e:
                print(f"✗ Failed to upload {local_file_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description='Upload sample data to S3')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--data-path', default='./data', help='Local data directory path')
    args = parser.parse_args()
    
    # Check if data directory exists
    data_path = Path(args.data_path)
    if not data_path.exists():
        print(f"Error: Data directory {data_path} does not exist")
        return
    
    print(f"Uploading data from {data_path} to s3://{args.bucket}/")
    
    # Upload CSV files
    csv_path = data_path / 'csv'
    if csv_path.exists():
        upload_files_to_s3(args.bucket, str(csv_path), 'data/csv')
    
    # Upload JSON files
    json_path = data_path / 'json'
    if json_path.exists():
        upload_files_to_s3(args.bucket, str(json_path), 'data/json')
    
    print("Upload completed!")

if __name__ == "__main__":
    main()