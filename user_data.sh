#!/bin/bash
              
# Clone the repository url.
git clone https://github.com/Innovate-Future-Association-Translation/translator-app.git 
cd translator-app
              
# Install dependencies and build.
npm install
npm run build

# ${var.bucket_name}
aws s3 sync ./out s3://{aws_s3_bucket.my_bucket.bucket} --delete 
