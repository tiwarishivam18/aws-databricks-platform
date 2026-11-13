locals {
  prefix = "analytics-${var.environment}"
}

module "storage" {
  source      = "./modules/storage"
  bucket_name = var.bucket_name
  prefix      = local.prefix
}

module "networking" {
  source                   = "./modules/networking"
  prefix                   = local.prefix
  region                   = var.region
  vpc_cidr                 = var.vpc_cidr
  private_subnets          = var.private_subnets
  flow_log_destination_arn = var.flow_log_destination_arn
}

module "iam" {
  source     = "./modules/iam"
  prefix     = local.prefix
  role_name  = var.uc_role_name
  bucket_arn = module.storage.bucket_arn
  key_arn    = module.storage.key_arn
  region     = var.region
}
