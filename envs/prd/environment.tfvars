environment    = "prd"
region         = "ap-south-1"
aws_account_id = "REPLACE_ACCOUNT_ID"
vpc_cidr       = "10.30.0.0/16"
private_subnets = {
  ap-south-1a = "10.30.1.0/24"
  ap-south-1b = "10.30.2.0/24"
}
bucket_name              = "replace-prd-lake-unique-name"
uc_role_name             = "replace-prd-uc-role"
flow_log_destination_arn = "arn:aws:s3:::replace-central-network-logs/analytics/prd/"
