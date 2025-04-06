# Define the Provider
provider "aws" {
  region = "ap-southeast-2"
}


# declares a new AWS S3 Bucket resource
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Sets a bucket policy to explicitly allow public read access to all objects in the bucket. Necessary for hosting public static webs
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*", # Allows access to "everyone."
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      },
    ]
  })
}
   
# Configure CloudFront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
  domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  origin_id   = var.bucket_name
  }

  enabled             = true
  default_root_object = var.index_document
       
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
target_origin_id = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
   
forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

 viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
