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
  region = "ap-southeast-2" Defines the AWS region
}

# Create a new S3 bucket
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Name = "FrontendHosting"
  }
}

# Set Object Ownership Control
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set up public access settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set the S3 bucket policy
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

# Upload static website files
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

# Use an existing Route 53 hosted zone
data "aws_route53_zone" "existing_zone" {
  name = var.domain_name
}

# Route53 DNS Record for Custom Domain
resource "aws_route53_record" "alias_record" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = "${var.subdomain}.${var.domain_name}" # 例如 www.example.com
  type    = "A"

  alias {
    name                   = aws_s3_bucket.frontend_bucket.website_domain
    zone_id                = aws_s3_bucket.frontend_bucket.hosted_zone_id
    evaluate_target_health = true
  }
}




