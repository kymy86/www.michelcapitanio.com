provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_dynamodb_table" "terraform-state-locking" {
  name         = "${var.app_name}${var.lock_table_name}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${title(var.app_name)} Terraform Lock Table"
  }
}

resource "aws_s3_bucket" "terraform-bucket" {
  force_destroy = true
  tags = {
    Name = "${title(var.app_name)} terraform state bucket"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-encryption-config" {
  bucket = aws_s3_bucket.terraform-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform-bucket-own-control" {
  bucket = aws_s3_bucket.terraform-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform-bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.terraform-bucket-own-control
  ]
  bucket = aws_s3_bucket.terraform-bucket.id
  acl    = "private"
}