#!/bin/bash

# Update your Ubuntu package list.
sudo apt-get update

# Install the AWS CLI using apt-get.
sudo apt-get install awscli

# Check the AWS CLI version to confirm that it was installed correctly.
aws --version

# Configuring AWS CLI
aws configure
          
# Clone the repository url.
git clone https://github.com/Innovate-Future-Association-Translation/translator-app.git 
cd translator-app
              
# Install dependencies and build.
npm install
npm run build

# ${var.bucket_name}
aws s3 sync ./out s3://{aws_s3_bucket.my_bucket.bucket} --delete 
