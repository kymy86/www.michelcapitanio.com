resource "aws_s3_bucket" "redirect_bucket" {
  provider = aws.main
  bucket   = var.website_name
}

resource "aws_s3_bucket_website_configuration" "redirect-config" {
  provider = aws.main
  bucket   = aws_s3_bucket.redirect_bucket.id
  redirect_all_requests_to {
    host_name = "www.${var.website_name}"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "redirect-encryption-config" {
  provider = aws.main
  bucket   = aws_s3_bucket.redirect_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "redirect-bucket-own-control" {
  provider = aws.main
  bucket   = aws_s3_bucket.redirect_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "redirect-bucket-acl" {
  provider = aws.main
  depends_on = [
    aws_s3_bucket_ownership_controls.redirect-bucket-own-control
  ]
  bucket = aws_s3_bucket.redirect_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "redirect-bucket-public-access" {
  provider = aws.main
  bucket   = aws_s3_bucket.redirect_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################

resource "aws_s3_bucket" "website_bucket" {
  provider = aws.main
  bucket   = "www.${var.website_name}"
}

resource "aws_s3_bucket_versioning" "website-versioning" {
  provider = aws.main
  bucket   = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "werbsite-encryption-config" {
  provider = aws.main
  bucket   = aws_s3_bucket.website_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "website-bucket-own-control" {
  provider = aws.main
  bucket   = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "website-bucket-acl" {
  provider = aws.main
  depends_on = [
    aws_s3_bucket_ownership_controls.website-bucket-own-control
  ]
  bucket = aws_s3_bucket.website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "website-bucket-public-access" {
  provider = aws.main
  bucket   = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "website-bucket-policy" {
    provider = aws.main
    bucket   = aws_s3_bucket.website_bucket.id
    policy = data.aws_iam_policy_document.website-bucket-policy.json
}

data "aws_iam_policy_document" "website-bucket-policy"{
    statement {
      actions = ["s3:*"]
      resources = [aws_s3_bucket.website_bucket.arn, "${aws_s3_bucket.website_bucket.arn}/*"]
      effect = "Deny"
      principals {
        type = "*"
        identifiers = ["*"]
      }
      condition {
        test = "Bool"
        values = ["false"]
        variable = "aws:SecureTransport"
      }
    }
    statement {
        actions = ["s3:GetObject"]
        effect = "Allow"
        resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        condition{
            test = "StringEquals"
            variable="AWS:SourceArn"
            values = [aws_cloudfront_distribution.website_distribution.arn]
        }
    }
}

######################### Certification bucket ############################


resource "aws_s3_bucket" "certs_bucket" {
  provider = aws.certs
  bucket   = "${var.certs_name}.${var.website_name}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "certs_encryption_config" {
  provider = aws.certs
  bucket   = aws_s3_bucket.certs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "certs_bucket_own_control" {
  provider = aws.certs
  bucket   = aws_s3_bucket.certs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "certs_bucket_acl" {
  provider = aws.certs
  depends_on = [
    aws_s3_bucket_ownership_controls.certs_bucket_own_control
  ]
  bucket = aws_s3_bucket.certs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "certs_bucket_public_access" {
  provider = aws.certs
  bucket   = aws_s3_bucket.certs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "certs_bucket_policy" {
    provider = aws.certs
    bucket   = aws_s3_bucket.certs_bucket.id
    policy = data.aws_iam_policy_document.certs_bucket_policy.json
}

data "aws_iam_policy_document" "certs_bucket_policy"{
    statement {
      actions = ["s3:*"]
      resources = [aws_s3_bucket.certs_bucket.arn, "${aws_s3_bucket.certs_bucket.arn}/*"]
      effect = "Deny"
      principals {
        type = "*"
        identifiers = ["*"]
      }
      condition {
        test = "Bool"
        values = ["false"]
        variable = "aws:SecureTransport"
      }
    }
    statement {
        actions = ["s3:GetObject"]
        effect = "Allow"
        resources = ["${aws_s3_bucket.certs_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        condition{
            test = "StringEquals"
            variable="AWS:SourceArn"
            values = [aws_cloudfront_distribution.certs_distribution.arn]
        }
    }
}