output "s3_bucket_name" {
  description = "The name of the bucket used for static website hosting."
  value       = aws_s3_bucket.my_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "bucket_regional_domain_name" {
  value = "http://${aws_s3_bucket.my_bucket.bucket_regional_domain_name}"
}

output "cloudfront_distribution_domain" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
