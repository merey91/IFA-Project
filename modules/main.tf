provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = var.parameter_name
  type  = "String"
  value = aws_s3_bucket.example.bucket
}
