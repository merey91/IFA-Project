# Outputting the static web URL
output "website_endpoint" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}
