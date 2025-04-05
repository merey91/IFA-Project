output "application_url" {
  description = "The Sign up page of the Website"
  value       = "http://${aws_s3_bucket.my_bucket.website_endpoint}" 
}

output "s3_bucket_name" {
  description = "The name of the bucket used for static website hosting."  
  value       = aws_s3_bucket.my_bucket.bucket 
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_domain" {
  description = "The domain name of the CloudFront distribution."  
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}
