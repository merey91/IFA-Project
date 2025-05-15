# Create the main S3 bucket (for hosting the static website)
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name  # Bucket name passed in via variable
  force_destroy = true      # Force deletion even if the bucket is not empty

  tags = {
    "Project"   = "miro.click"
    "ManagedBy" = "Terraform"
  }

  logging {
    target_bucket = aws_s3_bucket.logging_bucket.id  # Target bucket for access logs
    target_prefix = "ifa-s3-log/"              # Prefix for stored log files
  }
}

# create S3 bucket for logging bucket (to receive access logs)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
  acl    = "private"

  lifecycle_rule {
    enabled = true
    expiration {
      days = 30  # log files will be automatically deleted after 30 days

    }
  }
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# Ownership control configuration (to resolve ACL compatibility issues)
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create bucket ACL: configure ACL (Access Control List)
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# create S3 website hosting:
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# add bucket policy to let the CloudFront OAI get objects:
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

# data source to generate bucket policy to let OAI get objects:
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [var.oai-iam-arn]
    }
  }
}
