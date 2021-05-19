provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_pet" "bucket_name" {}


resource "aws_s3_bucket" "cloudtrail_logging" {
  bucket = "${random_pet.bucket_name.id}-logs"
  acl = "log-delivery-write"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    Name        = "My bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_public_access_block" "access_good_1" {
  bucket = aws_s3_bucket.cloudtrail_logging.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_bucket = true
}