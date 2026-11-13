terraform {
  required_version = "~> 1.17.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "= 1.109.0"
    }
  }

  backend "s3" {}
}
