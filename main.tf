# Define the Provider
provider "aws" {
region = "ap-southeast-2" # All AWS resources created in this Terraform configuration will by default be deployed in the aus region.
}

# Configure the backend to use S3
terraform {
backend "s3" {
bucket         = "ifa-app-bucket"     # Replace with your actual bucket name
key            = "jenkins-server/terraform.tfstate" # Path to the state file inside S3
region         = "ap-southeast-2"
dynamodb_table = "terraform-lock-table" # Locking mechanism
encrypt        = true                   # Enable state encryption
}
}

# declares a new AWS S3 Bucket resource
resource "aws_s3_bucket" "my_bucket" { 
  bucket = "ifa-app-bucket" # Names the S3 bucket.
  acl    = "public-read" # Sets the access control list to public-read, allowing anyone to read the objects in the bucket, which is typical for static website hosting.

  website {
    index_document = var.index_document  # Specifies the homepage for the static website hosted in this bucket.
    error_document = var.error_document  # Specifies the error page that will be displayed when a requested file is not found.
  }
  }

# Sets a bucket policy to explicitly allow public read access to all objects in the bucket. Necessary for hosting public static websites.
  policy = jsonencode({ 
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*", # Allows access to "everyone."
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::ifa-app-bucket/*"
      },
    ]
  })
}

# Configure CloudFront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.website_endpoint # Uses the S3 bucket's website endpoint as the origin for CloudFront. This integrates the S3 static website with CloudFront.
    origin_id   = "S3-my-translator-app" # A unique identifier for the origin within the CloudFront distribution.
  }

  enabled             = true # Enables the CloudFront distribution so it starts serving content.
  default_root_object = "index.html" # Designates the default document for the root URL, usually the homepage of the website.

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"] # Specifies which HTTP methods to allow and cache; typical for static content.
    cached_methods   = ["GET", "HEAD"] # Defines methods for which CloudFront caches responses.
    target_origin_id = "S3-my-translator-app" # Links this cache behavior to the specified origin.

    forwarded_values {
      query_string = false # Specifies not to forward URL query strings to the origin, which can improve caching efficiency for static sites.
      cookies {
        forward = "none" # Indicates that cookies should not be forwarded to the origin, which is typical for static content that doesn't require user sessions.
      }
    }

    viewer_protocol_policy = "redirect-to-https" # Forces HTTP requests to be redirected to HTTPS, securing the communication.
  }

  price_class = "PriceClass_All" # Specifies the price class, using all regions to maximize reach and performance.

  restrictions {
    geo_restriction {
      restriction_type = "none" # Indicates no geographic restrictions on who can access the content, typical for global applications.
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Uses the default SSL/TLS certificate provided by AWS, simplifying HTTPS setup.
  }
}
