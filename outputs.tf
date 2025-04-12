# Outputting Website URL (修改)
output "website_url" {
  description = "The website URL for the S3 bucket"
  value = "https://www.${var.domain_name}" 
}
