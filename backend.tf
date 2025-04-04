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
