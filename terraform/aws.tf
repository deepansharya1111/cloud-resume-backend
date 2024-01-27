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
#LIST EXISTING acm_certificate_arn CERTIFICATES: aws acm list-certificates --query "CertificateSummaryList[*].CertificateArn"
#DELETE EXISTING acm_certificate_arn CERTIFICATES: aws acm delete-certificate --certificate-arn <full-arn-of-certificate>

#The behavior of the code is as follows:

#If default create_acm_certificate is true:
####It checks if there is an existing ACM certificate with a non-empty ARN using the data source.
####If an ACM certificate with a non-empty ARN exists, it does not create a new certificate.
####If ACM certificate with a non-empty ARN does not exists, it creates a new certificate.
#So, If there is an existing ACM certificate, it will not create a new certificate, otherwise it will.

#If default create_acm_certificate is false:
#It will destroy the existing certificate

variable "create_acm_certificate" {
  type    = bool
  default = true
}

data "aws_acm_certificate" "deepansh_app_acm_certificate" {
  # Reference the existing certificate
  domain   = "*.deepansh.app"
  statuses = ["ISSUED"]
  tags     = {}
}

resource "aws_acm_certificate" "deepansh_app_acm_certificate" {
  count = var.create_acm_certificate ? 1 : 0

  domain_name               = "*.deepansh.app"
  key_algorithm             = "RSA_2048"
  subject_alternative_names = ["*.deepansh.app", "deepansh.app"]
  tags                      = {}
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

#----------------AWS CLOUDFRONT CONFIGURATION

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

#AWS DYNAMODB CONFIGURATION
#-------------------------------------------------------------------------------------
#Check existing dynamodb tables:
# aws dynamodb list-tables

#See configuration of your dynamodb table
# aws dynamodb describe-table --table-name your_table_name

# aws_dynamodb_table.cloudresume-table-tf:
resource "aws_dynamodb_table" "cloudresume-table-tf" {
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  hash_key                    = "id"
  name                        = "cloudresume-table"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  tags                        = {}
  tags_all                    = {}
  write_capacity              = 1

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }
  # CHECK TTL STATUS: aws dynamodb describe-time-to-live --table-name cloudresume-table
  # But since our counter should be updated instantly, we do not want to tnable ttl.
  #  ttl {
  #    attribute_name = "your_ttl_attribute_name_here"
  #    enabled = false
  #  }
}

#AWS LAMBDA CONFIGURATION
#-------------------------------------------------------------------------------------

#----------------CREATE A LAMBDA FUNCTION CALLED cloudresume-python-function
resource "aws_lambda_function" "cloudresume-lambda-function" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  function_name    = "cloudresume-lambda-python-function"
  role    = aws_iam_role.iam_of_cloudresume_lambda_creation_role.arn
  handler = "cloudresume-lambdafunction.lambda_handler"
  runtime = "python3.8"
}

#----------------assume_role_policy: IAM POLICY FOR ALLOWING LAMBDA FUNCTION CREATION
resource "aws_iam_role" "iam_of_cloudresume_lambda_creation_role" {
  name = "cloudresume_lambda_creation_role"

  # assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#----------------PATH FOR PYTHON_CODE_FOR_LAMBDA.PY FILE
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-function/"
  output_path = "${path.module}/packed-cloudresume-lambdafunction.zip"
}

#----------------resource access policy: IAM POLICY TO ALLOW LAMBDA TO ACCESS DYNAMODB
resource "aws_iam_policy" "iam_for_cloudresume_lambda_to_access_dynamodb" {
  name        = "aws_iam_policy_for_cloudresume_lambda_creation_role_to_access_dynamodb"
  path        = "/"
  description = "AWS IAM Policy for managing the resume project role"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/cloudresume-table"
      }
    ]
  })
}

#----------------ATTACH BOTH IAM POLICIES = CREATION + DYNAMODB ACCESS
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_of_cloudresume_lambda_creation_role.name
  policy_arn = aws_iam_policy.iam_for_cloudresume_lambda_to_access_dynamodb.arn
}

#----------------ENABLE THE FUNCTION URL OF LAMBDA
resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.cloudresume-lambda-function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}


#AWS LAMBDA@echo CONFIGURATION
#-------------------------------------------------------------------------------------
#LIST ACTIVE LAMBDA FUNCTIONS:
#aws lambda list-functions
#aws lambda get-function --function-name my-function
