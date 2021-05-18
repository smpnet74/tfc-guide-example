provider "aws" {
  region = var.aws_region
}

#provider "random" {}

#resource "random_pet" "table_name" {}

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

module "aws_cloudtrail" {
    source             = "trussworks/cloudtrail/aws"
    s3_bucket_name     = "cloudtrail-logs"
    log_retention_days = 15
}
