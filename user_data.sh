#!/bin/bash
              
# Clone the repository url
git clone https://github.com/Innovate-Future-Association-Translation/translator-app.git /home/ec2-user/app
cd /home/ec2-user/app
              
# 安装依赖并构建
npm install
npm run build

#
aws s3 sync ./out s3://ifa-app-bucket --delete
