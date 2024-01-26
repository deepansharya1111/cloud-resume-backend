#AWS S3 BUCKET CONFIGURATION FOR STORING STATIC WEBSITE CODE
#-------------------------------------------------------------------------------------
resource "aws_s3_bucket" "deepansh_app_bucket" {
  bucket = "deepansh.app"

  object_lock_enabled = false

  tags = {
    "project" = "Cloud Resume Challenge"
  }
  tags_all = {
    "project" = "Cloud Resume Challenge"
  }
}
resource "aws_s3_bucket_policy" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.bucket

  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "s3:GetObject"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "arn:aws:s3:::deepansh.app/*"
          Sid       = "PublicReadGetObject"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
resource "aws_s3_bucket_request_payment_configuration" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.bucket

  payer = "BucketOwner"
}
#----------------FOR "Objects" with LIST only and no "Bucket ACL" READ
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl#with-private-acl
#resource "aws_s3_bucket_acl" "deepansh_app_bucket" {
#  bucket = aws_s3_bucket.deepansh_app_bucket.bucket
#
#  acl = "public-read"
#}

#----------------FOR "Objects" with LIST and "Bucket ACL" with READ_ACP requires With GRANTS:
data "aws_canonical_user_id" "current" {}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl#with-grants
resource "aws_s3_bucket_acl" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.bucket

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ_ACP"
    }
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}
#----------------
resource "aws_s3_bucket_server_side_encryption_configuration" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "deepansh_app_bucket" {
  bucket = aws_s3_bucket.deepansh_app_bucket.bucket

  versioning_configuration {
    status = "Suspended"
  }
}

#AWS CLOUDFRONT CONFIGURATION
#-------------------------------------------------------------------------------------

#----------------ACM CERTIFICATE FOR YOUR DOMAIN
#Set default = true if first time creting acm certificate, then set to false before second terraform apply.
variable "create_acm_certificate" {
  type    = bool
  default = false
}

data "aws_acm_certificate" "deepansh_app_acm_certificate" {
  # Reference the existing certificate

  domain   = "*.deepansh.app"
  statuses = ["ISSUED"]
  tags     = {}
}
#If importing, Find your full arn by running: aws acm list-certificates --query "CertificateSummaryList[*].CertificateArn"
resource "aws_acm_certificate" "deepansh_app_acm_certificate" {
  count = var.create_acm_certificate ? 1 : (
    length(data.aws_acm_certificate.deepansh_app_acm_certificate.arn) > 0 ? 1 : 0
  )
  domain_name               = "*.deepansh.app"
  key_algorithm             = "RSA_2048"
  subject_alternative_names = ["*.deepansh.app", "deepansh.app"]
  tags                      = {}
  tags_all                  = {}
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}
#----------------

locals {
  enable_subpages_version = 6
}

data "aws_lambda_function" "enable_subpages" {
  function_name = "enable-subpages"
}

resource "aws_cloudfront_distribution" "deepansh_app_s3_distribution" {
  aliases = [
    "deepansh.app",
    "www.deepansh.app",
  ]

  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  staging             = false
  tags                = {}
  tags_all            = {}

  wait_for_deployment = true

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "deepansh.app.s3.us-east-1.amazonaws.com"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "https-only"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = "${data.aws_lambda_function.enable_subpages.arn}:${local.enable_subpages_version}"
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = "deepansh.app.s3.us-east-1.amazonaws.com"
    origin_id           = "deepansh.app.s3.us-east-1.amazonaws.com"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate.deepansh_app_acm_certificate]

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.deepansh_app_acm_certificate.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
#-------------------------------------------------------------------------------------
