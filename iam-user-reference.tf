#########################
# AWS Provider
#########################

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

#########################
# IAM User
#########################

resource "aws_iam_user" "iam_user" {
  name = "s3-user"
  tags = {
    Purpose = "S3 access only"
  }
}

#########################
# Programmatic Access (Access Key)
#########################

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name

  # You can optionally output these values
  # Don't hardcode in scripts or commit access keys to version control
}

#########################
# IAM Policy Document
#########################

data "aws_iam_policy_document" "s3_get_put_delete_policy_document" {
  statement {
    sid = "AllowS3Actions"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::your-bucket-name/*"  # Replace with your actual bucket name
    ]
  }
}

#########################
# Attach Inline Policy to User
#########################

resource "aws_iam_user_policy" "s3_get_put_delete_policy" {
  name   = "S3GetPutDeletePolicy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.s3_get_put_delete_policy_document.json
}
