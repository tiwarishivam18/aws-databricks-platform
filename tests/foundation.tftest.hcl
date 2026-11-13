mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}"
    }
  }
}

variables {
  environment              = "dev"
  region                   = "ap-south-1"
  aws_account_id           = "111111111111"
  bucket_name              = "example-dev-analytics-111111111111"
  uc_role_name             = "example-dev-uc"
  flow_log_destination_arn = "arn:aws:s3:::example-network-logs/analytics/dev/"
  tags                     = { Owner = "platform" }
  vpc_cidr                 = "10.10.0.0/16"
  private_subnets = {
    ap-south-1a = "10.10.1.0/24"
    ap-south-1b = "10.10.2.0/24"
  }
}

run "private_subnets_by_zone" {
  command = plan
  assert {
    condition     = toset(keys(output.private_subnet_ids)) == toset(["ap-south-1a", "ap-south-1b"])
    error_message = "The foundation must expose one private subnet per configured zone."
  }
}
