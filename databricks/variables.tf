variable "workspace_host" {
  type = string
  validation {
    condition     = can(regex("^https://[a-z0-9-]+\\.cloud\\.databricks\\.com$", var.workspace_host)) && !strcontains(var.workspace_host, "replace")
    error_message = "Set the canonical AWS workspace HTTPS URL without a trailing slash."
  }
}

variable "databricks_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F-]{27}$", var.databricks_account_id))
    error_message = "Supply the actual Databricks account UUID."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Select dev, stg or prd."
  }
}

variable "workspace_id" {
  type = number
}

variable "metastore_id" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "schemas" {
  type = set(string)
}

variable "storage_credential_name" {
  type = string
}

variable "lake_url" {
  type = string
  validation {
    condition     = can(regex("^s3://[a-z0-9.-]+/lake/$", var.lake_url))
    error_message = "Use the lake_url output of the matching AWS root."
  }
}

variable "access_group" {
  type = string
}

variable "spark_version" {
  type = string
}

variable "node_type" {
  type = string
}

variable "max_workers" {
  type = number
  validation {
    condition     = var.max_workers >= 1 && floor(var.max_workers) == var.max_workers
    error_message = "max_workers must be a positive integer."
  }
}

variable "create_cluster" {
  type = bool
}

variable "folder_name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.folder_name))
    error_message = "Use a single folder name for the team workspace directory."
  }
}

variable "workspace_settings" {
  type = map(string)
}

variable "foreign_catalogs" {
  type    = map(object({ connection_name = string, options = map(string) }))
  default = {}
}
