# variable for key pair name
variable "key_name" {
description = "Name of the AWS SSH Key Pair"
type        = string
default     = "ifa-Jenkins-keypair"
}

# variable for AWS services name
variable "aws_services" {
  description = "AWS Services"
  type        = list(string)
  default     = ["EC2", "S3"]
}

# variable for region name
variable "region" {
  description = "AWS region"
  default     = "ap-southeast-2"
}

# variable for bucket name
variable "bucket_name" {
  description = "S3 bucket name"
  default     = "my-unique-bucket-name"
}

# variable for instance name
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "zxu-2025"
}

# variable for instance class
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}
