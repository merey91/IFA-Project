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

# Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# Uploads all files from the local out directory to the S3 bucket.
resource "aws_s3_bucket_object" "frontend_files" {
  for_each = fileset("out", "**")

  bucket = aws_s3_bucket.frontend_bucket.id
  key    = each.value
  source = "out/${each.value}"
  etag   = filemd5("out/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      json = "application/json"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      svg  = "image/svg+xml"
      ico  = "image/x-icon"
      txt  = "text/plain"
    },
    regex("[^.]+$", each.value),
    "application/octet-stream"
  )

  depends_on = [
    aws_s3_bucket_policy.public_read
  ]
}

# Outputting Website URL
output "website_url" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint #Outputs the S3 static website endpoint, which can be shared or used for further configurations
}
