# Define the Provider
provider "aws" {
region = "us-west-2" # All AWS resources created in this Terraform configuration will by default be deployed in the US West (Oregon) region
}

# Terraform Backend
terraform {
backend "s3" {
bucket         = "terraform-state-storage"     # Replace with your actual bucket name
key            = "jenkins-server/terraform.tfstate" # Path to the state file inside S3
region         = "us-west-2"
dynamodb_table = "terraform-lock-table" # Locking mechanism
encrypt        = true                   # Enable state encryption
}
}

# Main resources. Defines an AWS EC2 instance for Jenkins
resource "aws_instance" "jenkins-server" {  
ami                    = "ami-" # replace / Amazon Linux 2023 AMI
instance_type          = "t2.micro"
key_name               = var.key_name #?
vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

user_data = file("${path.module}/user-data.sh") # ? a bootstrapping script that automates the installation of software and system configuration upon instance launch.

tags = {
Name  = "Jenkins-Server" # aws ec2  instance name
Usage = "pipeline" #?
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
