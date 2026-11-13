resource "databricks_secret_scope" "applications" {
  name = "${local.prefix}-applications"
}

resource "databricks_workspace_conf" "settings" {
  custom_config = var.workspace_settings
}
