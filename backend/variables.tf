variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "aws_region" {
  type        = string
  description = "The name of the AWS region"
}

variable "profile" {
  type        = string
  description = "The name of the AWS profile"
}

variable "s3_backend_user" {
  type        = string
  description = "The name of the S3 backend user"
}