# Define the Provider
provider "aws" {
  region = "ap-southeast-2" # All AWS resources created in this Terraform configuration will by default be deployed in the aus region.
}


# declares a new AWS S3 Bucket resource
resource "aws_s3_bucket" "my_bucket" { 
  bucket = var.bucket_name 

  website {
    index_document = var.index_document  # Specifies the homepage for the static website hosted in this bucket.
    error_document = var.error_document  # Specifies the error page that will be displayed when a requested file is not found.
   }
 }
  resource "aws_s3_bucket_acl" "my_bucket_acl" {
    bucket = aws_s3_bucket.my_bucket.id
    acl    = "public-read"
  }

# Sets a bucket policy to explicitly allow public read access to all objects in the bucket. Necessary for hosting public static websites.
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

policy = jsonencode({ 
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*", # Allows access to "everyone."
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
      },
    ]
  })
}

# Configure CloudFront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.website_endpoint # Uses the S3 bucket's website endpoint as the origin for CloudFront. This integrates the S3 static website with CloudFront.
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled             = true # Enables the CloudFront distribution so it starts serving content.
  default_root_object = var.index_document # Designates the default document for the root URL, usually the homepage of the website.

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"] # Specifies which HTTP methods to allow and cache; typical for static content.
    cached_methods   = ["GET", "HEAD"] # Defines methods for which CloudFront caches responses.
    target_origin_id = "S3-${var.bucket_name}" # Links this cache behavior to the specified origin.
    viewer_protocol_policy = "redirect-to-https" 

    forwarded_values {
      query_string = false # Specifies not to forward URL query strings to the origin, which can improve caching efficiency for static sites.
      cookies {
        forward = "none" # Indicates that cookies should not be forwarded to the origin, which is typical for static content that doesn't require user sessions.
      }
    } 
  }

  price_class = "PriceClass_All" # Specifies the price class, using all regions to maximize reach and performance.

  restrictions {
    geo_restriction {
      restriction_type = "none" # Indicates no geographic restrictions on who can access the content, typical for global applications.
    }
  }
}

# Deploy static files to S3 Bucket
resource "aws_s3_bucket_object" "website_files" {
  bucket = aws_s3_bucket.my_bucket.id  # Specifies the ID of the S3 bucket where files will be stored.
  key    = "out/"                      # The key path under which the file will be stored in the bucket.
  source = "out/"  # The local path to the directory where your output files are stored that you want to upload.
  etag   = filemd5("/out/index.html")  # The MD5 hash of the local file to manage file integrity.
}

