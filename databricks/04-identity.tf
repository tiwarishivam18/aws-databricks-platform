# The shared root assigns this account group to the workspace before this lookup.
data "databricks_group" "operators" {
  display_name = var.access_group
}
