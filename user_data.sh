#!/bin/bash
# 更新系统
sudo yum update -y
              
# 安装 Git
sudo yum install -y git
              
# 安装 Node.js 20.x（最新LTS版本）
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
              
# 克隆代码仓库（替换为你的实际仓库地址）
git clone https://github.com/Innovate-Future-Association-Translation/translator-app.git /home/ec2-user/app
cd /home/ec2-user/app
              
# 安装依赖并构建
npm install
npm run build
              
# 使用PM2持久化运行
sudo npm install -g pm2
pm2 startup
pm2 start npm --name "app" -- run start
pm2 save

