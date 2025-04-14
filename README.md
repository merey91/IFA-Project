# Terraform

variables：定义用户输入的变量

假设你的域名已经在 Route 53 中托管，无需重新创建托管区域，使用 data 资源引用已有的 Route 53 托管区域。

创建一个 A 记录，将子域名（如 www.example.com）指向 S3 静态网站的终端节点。

运行 Terraform 命令 :
初始化 Terraform：
terraform init

检查计划：
terraform plan

应用配置：
terraform apply
