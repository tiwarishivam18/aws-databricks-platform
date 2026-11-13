output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "lake_url" {
  value = "s3://${module.storage.bucket_name}/lake/"
}

output "kms_key_arn" {
  value = module.storage.key_arn
}
