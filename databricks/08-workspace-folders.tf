resource "databricks_directory" "team" {
  path = "/${var.folder_name}"
}

resource "databricks_permissions" "team" {
  directory_path = databricks_directory.team.path
  access_control {
    group_name       = data.databricks_group.operators.display_name
    permission_level = "CAN_READ"
  }
}
