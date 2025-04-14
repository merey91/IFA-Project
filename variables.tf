variable "bucket_name" {
  description = "The unique name of the S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "Your domain name (e.g., example.com)"
  type        = string
  default     = "miro.aws.jrworkshop.au"
}

variable "subdomain" {
  description = "Your subdomain (e.g., www)"
  type        = string
}
