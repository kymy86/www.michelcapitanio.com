provider "aws" {
  alias   = "cloudfront"
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "main"
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "certs"
  region  = "eu-west-1"
  profile = var.aws_profile
}

resource "aws_acm_certificate" "website_cert" {
  provider                  = aws.cloudfront
  domain_name               = "www.${var.website_name}"
  subject_alternative_names = [var.website_name]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "website_cert" {
  provider        = aws.cloudfront
  certificate_arn = aws_acm_certificate.website_cert.arn
}

resource "aws_cloudfront_origin_access_control" "oac" {
  provider = aws.cloudfront
  name = "${var.website_name}-oac"
  description = "${var.website_name} CloudFront Origin access identity"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

resource "aws_cloudfront_distribution" "website_distribution" {
  provider            = aws.cloudfront
  aliases             = ["www.${var.website_name}", var.website_name]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    target_origin_id       = "S3-www.${var.website_name}"
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_domain_name
    origin_id   = "S3-www.${var.website_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website_cert.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "zone" {
  provider     = aws.cloudfront
  name         = var.website_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  provider = aws.cloudfront
  type     = "A"
  zone_id  = data.aws_route53_zone.zone.id
  name     = "www.${var.website_name}"

  alias {
    name = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = local.cf_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "naked" {
  provider = aws.cloudfront
  type     = "A"
  zone_id  = data.aws_route53_zone.zone.id
  name     = var.website_name

  alias {
    name = "s3-website.${var.aws_region}.amazonaws.com"
    zone_id                = local.s3_zone_id
    evaluate_target_health = false
  }
}

### Certification

resource "aws_acm_certificate" "certs_website_cert" {
  provider                  = aws.cloudfront
  domain_name               = "${var.certs_name}.${var.website_name}"
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "certs_website_cert" {
  provider        = aws.cloudfront
  certificate_arn = aws_acm_certificate.certs_website_cert.arn
}

resource "aws_cloudfront_origin_access_control" "certs_oac" {
  provider = aws.cloudfront
  name = "${var.certs_name}.${var.website_name}-oac"
  description = "${var.website_name} CloudFront Origin access identity for Certs website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

resource "aws_cloudfront_distribution" "certs_distribution" {
  provider            = aws.cloudfront
  aliases             = ["${var.certs_name}.${var.website_name}"]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.certs_name}.${var.website_name}"
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name = aws_s3_bucket.certs_bucket.bucket_domain_name
    origin_id   = "S3-${var.certs_name}.${var.website_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.certs_oac.id
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.certs_website_cert.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "certs" {
  provider = aws.cloudfront
  type     = "A"
  zone_id  = data.aws_route53_zone.zone.id
  name     = "${var.certs_name}.${var.website_name}"

  alias {
    name = aws_cloudfront_distribution.certs_distribution.domain_name
    zone_id                = local.cf_zone_id
    evaluate_target_health = false
  }
}