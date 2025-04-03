# Define the Provider
provider "aws" {
region = "ap-southeast-2" # All AWS resources created in this Terraform configuration will by default be deployed in the aus region
}

# Configure the backend to use S3
terraform {
backend "s3" {
bucket         = "terraform-state-storage"     # Replace with your actual bucket name
key            = "jenkins-server/terraform.tfstate" # Path to the state file inside S3
region         = "ap-southeast-2"
dynamodb_table = "terraform-lock-table" # Locking mechanism
encrypt        = true                   # Enable state encryption
}
}

# Create an S3 bucket resource
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-shuotestbucket"
  acl    = "private"

user_data = file("${path.module}/user-data.sh") # ? a bootstrapping script that automates the installation of software and system configuration upon instance launch.

tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Allocate an Elastic IP. Elastic IPs are static IP addresses designed for dynamic cloud computing, providing a fixed IP address for your instance.?

resource "aws_eip" "jenkins_eip" {
domain   = "vpc"
}

# Associate the Elastic IP with the Jenkins EC2 instance?

resource "aws_eip_association" "jenkins_eip_assoc" {
instance_id   = aws_instance.jenkins.id
allocation_id = aws_eip.jenkins_eip.id
}
