variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnets" {
  type = map(string)
}

variable "flow_log_destination_arn" {
  description = "Central S3 destination authorized for VPC flow log delivery."
  type        = string
}
