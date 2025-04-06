output "s3_bucket_name" {
  description = "The name of the bucket used for static website hosting."
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint URL for the S3 bucket"
  value = aws_s3_bucket.s3_bucket.website_endpoint
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
