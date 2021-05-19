provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_pet" "bucket_name" {}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS Key for cloudtrail buckets"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
  enable_key_rotation    = true
  tags = {
    Name        = "My cloudtrail key"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket" "cloudtrail_logging" {
  bucket = "${random_pet.bucket_name.id}-logs"
  acl = "log-delivery-write"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.cloudtrail.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    Name        = "My cloud trail logging bucket"
    Environment = "Prod"
    Automation  = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "access_good_1" {
  bucket = aws_s3_bucket.cloudtrail_logging.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${random_pet.bucket_name.id}-cloudtrail"
  acl = "log-delivery-write"
  logging {
    target_bucket = aws_s3_bucket.cloudtrail_logging.id
    target_prefix = "log/${random_pet.bucket_name.id}-cloudtrail"
  }
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.cloudtrail.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    Name        = "Primary cloudtrail bucket"
    Environment = "Prod"
    Automation  = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "access_good_2" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::myBucketName"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::myBucketName/[optional prefix]/AWSLogs/myAccountID/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
  })
}
/*
module "aws_cloudtrail" {
    source             = "trussworks/cloudtrail/aws"
    s3_bucket_name     = aws_s3_bucket.cloudtrail_logging.id
    log_retention_days = 90
    tags = {
      Name        = "Cloudtrail configuration"
      Environment = "Prod"
      Automation  = "Terraform"
  }
}
*/
