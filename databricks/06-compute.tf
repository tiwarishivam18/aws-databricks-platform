module "compute" {
  source         = "./modules/compute"
  prefix         = local.prefix
  spark_version  = var.spark_version
  node_type      = var.node_type
  max_workers    = var.max_workers
  create_cluster = var.create_cluster
  group_name     = data.databricks_group.operators.display_name
  depends_on     = [databricks_metastore_assignment.workspace]
}
