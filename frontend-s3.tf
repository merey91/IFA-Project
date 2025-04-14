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

# Creates an S3 bucket for frontend.
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = replace(var.domain_name, ".", "-")
}

resource "aws_s3_bucket_website_configuration" "frontend_site" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
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
        Condition: {
          StringEquals: {
            "AWS:SourceArn": aws_cloudfront_distribution.frontend_cdn.arn
          }
      }
    }]
  })
}

# Uploads all files from the local out directory to the S3 bucket.
resource "aws_s3_object" "frontend_files" {
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
}

# Use existing Route53 Hosted Zone
data "aws_route53_zone" "example_com" { # 引用现有的 Route53 托管区域
  name         = var.domain_name # 输入域名，例如 example.com
  private_zone = false           # 确保是公共托管区域
}

# Request an ACM Certificate
resource "aws_acm_certificate" "cert" { 
  domain_name               = var.domain_name # 主域名，例如 www.example.com
  subject_alternative_names = ["*.${var.domain_name}"] # 通配符域名，例如 *.example.com
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate ACM Certificate with DNS Records
resource "aws_route53_record" "cert_validation" { # 新增：为 ACM SSL证书添加 DNS 验证记录
  for_each = { for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => dvo }

  zone_id = aws_route53_zone.example_com.zone_id # 使用现有托管区域的 ID
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation_complete" { # 验证 ACM SSL证书是否有效
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  depends_on = [aws_route53_record.cert_validation]
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend_cdn" { # 修改：使用 ACM SSL证书配置 CloudFront 分发以支持 HTTPS 和自定义域名
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "S3-FrontendBucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["www.${var.domain_name}"] # 使用自定义域名作为别名

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-FrontendBucket"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate_validation.cert_validation_complete.certificate_arn # 使用 ACM 验证完成的证书 ARN
    ssl_support_method              = "sni-only"
    minimum_protocol_version        = "TLSv1.2_2021"
    cloudfront_default_certificate  = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "FrontendDistribution"
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" { # 新增：CloudFront 原点访问身份验证（OAI）
  comment = "OAI for S3 Frontend Bucket"
}

# Route53 DNS Record for Custom Domain
resource "aws_route53_record" "frontend_alias" { # 新增：为自定义域名添加 Route53 A记录指向 CloudFront 分发
  zone_id = data.aws_route53_zone.example_com.zone_id # 使用现有托管区域的 ID
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

----
# 配置 AWS 提供商
provider "aws" {
  region = "ap-southeast-2" # 替换为你的目标区域
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



