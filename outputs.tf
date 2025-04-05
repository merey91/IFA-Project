#
output "application_url" {
  description = "The Sign up page of the Website"
  value       = "http://${aws_s3_bucket.my_bucket.website_endpoint}" 
}
