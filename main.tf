provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_pet" "bucket_name" {}

/*resource "aws_dynamodb_table" "tfc_example_table" {
  name = "${var.db_table_name}-${random_pet.table_name.id}"

  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }
}*/
module "aws-s3-bucket" {
  source         = "trussworks/s3-private-bucket/aws"
  bucket         = "${random_pet.bucket_name.id}-logs"
  use_account_alias_prefix = false
  enable_analytics = false

  tags = {
    Name        = "cloudtrail logs"
    Environment = "Prod"
    Description = "Logging bucket for cloudtrail s3 bucket"
  }
}
resource "aws_s3_bucket" "private_bucket" {
  acl = "log-delivery-write"
}

module "aws-s3-bucket1" {
  source         = "trussworks/s3-private-bucket/aws"
  bucket         = "${random_pet.bucket_name.id}-clouddtrail"
  logging_bucket = "${random_pet.bucket_name.id}-logs"
  use_account_alias_prefix = false
  enable_analytics = false

  tags = {
    Name        = "cloudtrail bucket"
    Environment = "Prod"
    Description = "Cloudtrail bucket for cloudtrail logs"
  }
}

/*
module "aws_cloudtrail" {
    source             = "trussworks/cloudtrail/aws"
    s3_bucket_name     = "cloudtrail-logs"
    log_retention_days = 90
}*/