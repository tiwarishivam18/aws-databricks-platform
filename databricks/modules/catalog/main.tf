resource "databricks_catalog" "this" {
  name           = var.catalog_name
  storage_root   = var.storage_root
  isolation_mode = "ISOLATED"
  force_destroy  = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "databricks_schema" "this" {
  for_each      = var.schemas
  catalog_name  = databricks_catalog.this.name
  name          = each.key
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "databricks_grant" "catalog_reader" {
  catalog    = databricks_catalog.this.name
  principal  = var.reader_group
  privileges = ["USE_CATALOG"]
}

resource "databricks_grant" "schema_reader" {
  for_each   = var.schemas
  schema     = databricks_schema.this[each.key].id
  principal  = var.reader_group
  privileges = ["USE_SCHEMA", "SELECT"]
}

# resource "databricks_grant" "schema_reader" {
#   for_each   = databricks_schema.this
#   schema     = each.value.id
#   principal  = var.reader_group
#   privileges = ["USE_SCHEMA", "SELECT"]
# }
