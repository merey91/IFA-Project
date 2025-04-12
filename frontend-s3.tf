# Specifies the AWS provider for Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2" # Defines the AWS region
}

# Generates a random 4-byte hexadecimal string to append to the bucket name, ensuring uniqueness, S3 bucket names must be globally unique
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Creates an S3 bucket with a unique name for frontend.
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-site-${random_id.bucket_suffix.hex}"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Name = "FrontendHosting"
  }
}

# Sets object ownership to BucketOwnerPreferred, allowing the bucket owner to control all objects without requiring ACLs.
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Disables public access restrictions to allow public access to the website files. This is necessary for hosting a public-facing static website.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy for CloudFront Access
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal: {
          Service: "cloudfront.amazonaws.com"
        },
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

----
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
}

# S3 bucket for static content
resource "aws_s3_bucket" "static_site" {
  bucket = replace(var.student_subdomain, ".", "-")
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  # Request certificate for both specific and wildcard domains
  domain_name               = var.student_subdomain
  subject_alternative_names = ["*.${var.student_subdomain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


