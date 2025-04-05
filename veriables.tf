terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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
