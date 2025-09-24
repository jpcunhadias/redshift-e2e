# Terraform configuration for Redshift E2E Pipeline Infrastructure
# This is a basic example - adjust according to your needs

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "redshift-e2e"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# S3 Bucket for data storage
resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.project_name}-${var.environment}-data-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket_encryption" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for Redshift
resource "aws_iam_role" "redshift_role" {
  name = "${var.project_name}-${var.environment}-redshift-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "redshift_s3_access" {
  name = "${var.project_name}-${var.environment}-redshift-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.data_bucket.arn,
          "${aws_s3_bucket.data_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = aws_iam_policy.redshift_s3_access.arn
}

# Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for data storage"
  value       = aws_s3_bucket.data_bucket.bucket
}

output "redshift_iam_role_arn" {
  description = "ARN of the IAM role for Redshift"
  value       = aws_iam_role.redshift_role.arn
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}