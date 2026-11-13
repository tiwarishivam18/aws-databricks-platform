provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
      ManagedBy   = "Terraform"
    })
  }
}
