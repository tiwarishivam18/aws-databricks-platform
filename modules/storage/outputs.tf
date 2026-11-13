output "bucket_arn" {
  value = aws_s3_bucket.lake.arn
}

output "bucket_name" {
  value = aws_s3_bucket.lake.id
}

output "key_arn" {
  value = aws_kms_key.lake.arn
}
