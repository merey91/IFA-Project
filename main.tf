provider "aws" {
  region = "ap-southeast-2"
}

module "s3_with_parameter_store" {
  source         = "./modules/s3_with_parameter_store"
  bucket_name    = "my-example-bucket"
  parameter_name = "/example/s3-bucket-name"
}

#########################################

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowFullS3Access"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

#########################################
# IAM policy
#########################################
module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name_prefix = "example-"
  path        = "/"
  description = "My example policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    PolicyDescription = "Policy created using heredoc policy"
  }
}

module "iam_policy_from_data_source" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "example_from_data_source"
  path        = "/"
  description = "My example policy"

  policy = data.aws_iam_policy_document.bucket_policy.json

  tags = {
    PolicyDescription = "Policy created using example from data source"
  }
}

module "iam_policy_optional" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  create_policy = false
}

output "s3_bucket_name" {
  value = module.s3_with_parameter_store.s3_bucket_name
}
