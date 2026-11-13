resource "databricks_external_location" "lake" {
  name            = "${local.prefix}-lake"
  url             = var.lake_url
  credential_name = var.storage_credential_name
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on      = [databricks_metastore_assignment.workspace]
  lifecycle {
    prevent_destroy = true
  }
}

# Federation uses existing connections. Keep connection secrets outside Terraform.
resource "databricks_catalog" "foreign" {
  for_each        = var.foreign_catalogs
  name            = each.key
  connection_name = each.value.connection_name
  options         = each.value.options
  isolation_mode  = "ISOLATED"
  depends_on      = [databricks_metastore_assignment.workspace]
  lifecycle {
    prevent_destroy = true
  }
}
