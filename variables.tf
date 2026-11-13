variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Select dev, stg or prd."
  }
}

variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "Enter the real 12-digit AWS target account ID."
  }
}

variable "tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnets" {
  type = map(string)
  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "Provide subnet CIDRs in at least two availability zones."
  }
}

variable "bucket_name" {
  type = string
}

variable "uc_role_name" {
  type = string
}

variable "flow_log_destination_arn" {
  description = "Central S3 destination authorized for VPC flow log delivery."
  type        = string
}
