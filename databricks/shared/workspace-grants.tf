locals {
  assignments = flatten([
    for workspace_id, groups in var.workspace_grants : [
      for group in groups : { workspace_id = workspace_id, group = group }
    ]
  ])
}

resource "databricks_mws_permission_assignment" "group" {
  provider     = databricks.account
  for_each     = { for a in local.assignments : jsonencode([a.workspace_id, a.group]) => a }
  workspace_id = tonumber(each.value.workspace_id)
  principal_id = local.group_ids[each.value.group]
  permissions  = ["USER"]
}
