# Outputting Website URL
output "website_url" {
  description = "The website URL for the S3 bucket"
  value = "https://www.${var.domain_name}" 
}

# 输出静态网站的 URL
output "website_endpoint" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}
