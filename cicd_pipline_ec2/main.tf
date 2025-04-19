provider "aws" {
  region = "ap-southeast-2" 
}

# Specifies the AWS provider for Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 在生产环境中，建议使用远程状态s3存储
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "ec2-environments/terraform.tfstate"
    region = "ap-southeast-2"
    encrypt = true
  }
}

# Variable
variable "vpc_id" {
  description = "VPC ID where instances will be created"
  default     = "vpc-xxxxxxxx"  # change it to your VPC ID
}

variable "subnet_id" {
  description = "Subnet ID where instances will be created"
  default     = "subnet-xxxxxxxx"  # change it to your Subnet ID
}

# Security Group for UAT environment.
resource "aws_security_group" "uat_sg" {
  name        = "ifa-backend-uat-sg"
  description = "Security group for ifa-backend UAT environment"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for UAT environment.
resource "aws_instance" "ifa_backend_uat_instance" {
  ami                    = ”ami-00a929b66ed6e0de6“
  instance_type          = "t2.micro"  # UAT环境使用较小实例
  key_name               = ifa-keypair
  vpc_security_group_ids = [aws_security_group.uat_sg.id]
  subnet_id              = var.subnet_id
  user_data              = local.user_data

  tags = {
    Name = "UAT-Server"
  }
}

# Security Group for production environment
resource "aws_security_group" "prod_sg" {
  name        = "ifa-backend-prod-sg"
  description = "Security group for ifa-backend production environment"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for production environment.
resource "aws_instance" "ifa_backend_prod_instance" {
  ami                    = “ami-00a929b66ed6e0de6”
  instance_type          = "t2.small"  # 生产环境使用更高配置
  key_name               = ifa-keypair
  vpc_security_group_ids = [aws_security_group.prod_sg.id]
  subnet_id              = var.subnet_id
  user_data              = local.user_data

  tags = {
    Name = "Prod-Server"
  }
}

locals {
user_data = <<-EOF
              #!/bin/bash
              # 更新系统
              sudo yum update -y
              
              # 安装 Git
              sudo yum install -y git
              
              # 安装 Node.js 20.x（最新LTS版本）
              curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
              sudo yum install -y nodejs
              
              # 克隆代码仓库（替换为你的实际仓库地址）
              git clone -b devops-miro https://github.com/Innovate-Future-Association-Translation/translator-app.git /home/ec2-user/app
              cd /home/ec2-user/app
              
              # 安装依赖并构建
              npm install
              npm run build
              

              
              # 使用PM2持久化运行
              sudo npm install -g pm2
              pm2 startup
              pm2 start npm --name "app" -- run start
              pm2 save
              EOF
}

# Output
output "uat_instance_id" {
  description = "ID of the UAT EC2 instance"
  value       = aws_instance.ifa_backend_uat_instance.id
}

output "uat_instance_public_ip" {
  description = "Public IP address of the UAT EC2 instance"
  value       = aws_instance.ifa_backend_uat_instance.public_ip
}

output "prod_instance_id" {
  description = "ID of the production EC2 instance"
  value       = aws_instance.ifa_backend_prod_instance.id
}

output "prod_instance_public_ip" {
  description = "Public IP address of the production EC2 instance"
  value       = aws_instance.ifa_backend_prod_instance.public_ip
}
