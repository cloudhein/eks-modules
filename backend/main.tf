# Creating remote s3 backend to store your terraform state files 
resource "aws_s3_bucket" "s3_backend" {
  bucket        = var.s3_bucket_name
  force_destroy = true # setting boolean value to true is dangerous in production environment for it will delete your remote backend s3 immediately without asking your permission

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_backend_ownership_controls" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aws-master-s3-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_backend_ownership_controls]

  bucket = aws_s3_bucket.s3_backend.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_backend_public_access_block" {
  bucket = aws_s3_bucket.s3_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_backend_bucket_versioning" {
  bucket = aws_s3_bucket.s3_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backend_bucket_encryption" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}