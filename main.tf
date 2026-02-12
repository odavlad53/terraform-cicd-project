terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# S3 Bucket for application assets
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.project_name}-${var.environment}-bucket"
  force_destroy = true
  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to S3 bucket (security best practice)
resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Select the latest Amazon Linux 2023 x86_64 AMI in the current region.
# This avoids hardcoding AMI IDs (which are region-specific and change over time).
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# EC2 Instance with IAM role
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [
      root_block_device
    ]
  }

  # Attach IAM role
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Enable EBS encryption (will be ignored for existing instance)
  root_block_device {
    encrypted = true
  }

  # Disable IMDSv1 (security best practice)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Require IMDSv2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  monitoring = true
}

# pr-test change
