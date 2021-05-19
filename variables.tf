variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "use_account_alias_prefix" {
  description = "Whether to prefix the bucket name with the AWS account alias."
  type        = string
  default     = false
}
