variable "config" {
  type = object({
    catalog                 = string
    governance_host         = string
    account_id              = string
    group                   = string
    storage_root            = string
    workspace_names         = map(string)
    registered_ids          = map(number)
    governance_workspace_id = optional(number)
  })
}

provider "databricks" {
  host = var.config.governance_host
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.config.account_id
}

data "databricks_mws_workspaces" "account" {
  provider = databricks.account
}

locals {
  targets = merge(var.config.registered_ids, {
    for alias, name in var.config.workspace_names :
    alias => tonumber(data.databricks_mws_workspaces.account.ids[name])
  })
}

resource "databricks_catalog" "requested" {
  name           = var.config.catalog
  storage_root   = var.config.storage_root
  isolation_mode = "ISOLATED"
  force_destroy  = false
  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = length(local.targets) > 0 && length(distinct(values(local.targets))) == length(local.targets)
      error_message = "Use one unambiguous alias per existing workspace."
    }
  }
}

resource "databricks_schema" "curated" {
  name         = "curated"
  catalog_name = databricks_catalog.requested.name
  lifecycle {
    prevent_destroy = true
  }
}

resource "databricks_grant" "catalog_reader" {
  catalog    = databricks_catalog.requested.name
  principal  = var.config.group
  privileges = ["USE_CATALOG"]
}

resource "databricks_grant" "schema_reader" {
  schema     = databricks_schema.curated.id
  principal  = var.config.group
  privileges = ["USE_SCHEMA", "SELECT"]
}

resource "databricks_workspace_binding" "consumer" {
  for_each = {
    for alias, id in local.targets : alias => id
    if id != var.config.governance_workspace_id
  }
  workspace_id   = each.value
  securable_type = "catalog"
  securable_name = databricks_catalog.requested.name
  binding_type   = "BINDING_TYPE_READ_ONLY"
}

output "catalog" {
  value = databricks_catalog.requested.name
}

output "bound_workspaces" {
  value = local.targets
}
