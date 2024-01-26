#AWS S3 BUCKET FOR STORING CODE OF MY WEBSITE
#--------------------------------------------------
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
#------------------------------------
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
#--------------------------------------------------------------------------------




