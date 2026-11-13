environment    = "dev"
region         = "ap-south-1"
aws_account_id = "043309323736"
vpc_cidr       = "10.10.0.0/16"
private_subnets = {
  ap-south-1a = "10.10.1.0/24"
  ap-south-1b = "10.10.2.0/24"
}
bucket_name              = "shivam-dbx-dev-lake-043309323736"
uc_role_name             = "databricks-uc-dev-storage"
flow_log_destination_arn = "arn:aws:s3:::shivam-dbx-flowlogs-043309323736-ap-south-1/analytics/dev/"
