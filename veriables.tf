variable "key_name" {
description = "Name of the AWS SSH Key Pair"
type        = string
default     = "ifa-Jenkins-keypair"
}

variable "aws_services" {
  description = "AWS Services"
  type        = list(string)
  default     = ["EC2", "S3"]
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "my-unique-bucket-name"
}
