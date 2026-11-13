module "catalog" {
  source       = "./modules/catalog"
  catalog_name = var.catalog_name
  storage_root = "${trimsuffix(databricks_external_location.lake.url, "/")}/managed"
  schemas      = var.schemas
  reader_group = data.databricks_group.operators.display_name
}
