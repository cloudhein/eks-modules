resource "aws_iam_user" "tf-s3-state-handler-user" {
  name       = var.s3_backend_user
  depends_on = [aws_s3_bucket.s3_backend]

  tags = {
    name = var.s3_backend_user
  }
}

resource "aws_iam_user_policy" "tf-s3-state-handler-policy" {
  name       = "tf-s3-state-handler-policy"
  user       = aws_iam_user.tf-s3-state-handler-user.name
  depends_on = [aws_s3_bucket.s3_backend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.s3_backend.arn
        Condition = {
          StringEquals = {
            "s3:prefix" = "terraform/dev/terraform.tfstate"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.s3_backend.arn}/terraform/dev/terraform.tfstate"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.s3_backend.arn}/terraform/dev/terraform.tfstate.tflock"
      }
    ]
  })
}

resource "aws_iam_access_key" "tf-s3-state-handler-access-key" {
  user       = aws_iam_user.tf-s3-state-handler-user.name
  depends_on = [aws_s3_bucket.s3_backend]
}