environment    = "stg"
region         = "ap-south-1"
aws_account_id = "REPLACE_ACCOUNT_ID"
vpc_cidr       = "10.20.0.0/16"
private_subnets = {
  ap-south-1a = "10.20.1.0/24"
  ap-south-1b = "10.20.2.0/24"
}
bucket_name              = "replace-stg-lake-unique-name"
uc_role_name             = "replace-stg-uc-role"
flow_log_destination_arn = "arn:aws:s3:::replace-central-network-logs/analytics/stg/"
