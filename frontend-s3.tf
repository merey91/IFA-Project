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


