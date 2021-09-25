provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "redirect_bucket" {
  bucket = var.website_name
  acl    = "private"

  website {
    redirect_all_requests_to = "https://www.${var.website_name}"
  }
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "www.${var.website_name}"
  acl    = "public-read"

  versioning {
    enabled = true
  }
}

resource "aws_acm_certificate" "website_cert" {
  domain_name               = var.website_name
  subject_alternative_names = ["www.${var.website_name}"]
  validation_method         = "EMAIL"
}

resource "aws_acm_certificate_validation" "website_cert" {
  certificate_arn = aws_acm_certificate.website_cert.arn
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.website_name} CloudFront Origin access identity"
}

resource "aws_cloudfront_distribution" "website_distribution" {
  aliases             = ["www.${var.website_name}"]
  default_root_object = "index.html"
  enabled             = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    target_origin_id = "S3-${var.website_name}"
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_domain_name
    origin_id   = "S3-${var.website_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website_cert.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "zone" {
  name         = var.website_name
  private_zone = false
}

resource "aws_route53_record" "naked" {
  type    = "A"
  name    = var.website_name
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = "s3-website-${var.aws_region}.amazonaws.com"
    zone_id                = lookup(var.hosted_ids, var.aws_region)
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  type    = "CNAME"
  zone_id = data.aws_route53_zone.zone.id
  name    = "www.${var.website_name}"
  ttl     = "300"
  records = [aws_cloudfront_distribution.website_distribution.domain_name]
}
