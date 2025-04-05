variable "region" {
  description = "AWS region to deploy resources."
  default     = "ap-southeast-2"  # AWS region
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting."
  default     = "ifa-translator-app-bucket"  # Your S3 Bucket Name
}

variable "index_document" {
  description = "The index document of the static website."
  default     = "index.html"  
}

variable "error_document" {
  description = "The error document of the static website."
  default     = "404.html"  
}
