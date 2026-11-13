output "catalog" {
  value = module.catalog.name
}

output "compute_policy_id" {
  value = module.compute.policy_id
}

output "secret_scope" {
  value = databricks_secret_scope.applications.name
}

output "folder_path" {
  value = databricks_directory.team.path
}
