#!/bin/bash
              
# Clone the repository url
git clone https://github.com/Innovate-Future-Association-Translation/translator-app.git /home/ec2-user/app
cd /home/ec2-user/app
              
# Install dependencies and build.
npm install
npm run build

#
aws s3 sync ./out s3://ifa-app-bucket --delete
