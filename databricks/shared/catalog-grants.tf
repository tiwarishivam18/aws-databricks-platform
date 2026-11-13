locals {
  catalog_access = flatten([
    for object_name, principals in var.catalog_grants : [
      for group, privileges in principals : {
        object_name = object_name
        group       = group
        privileges  = privileges
      }
    ]
  ])
}

resource "databricks_grant" "catalog" {
  for_each   = { for a in local.catalog_access : jsonencode([a.object_name, a.group]) => a }
  catalog    = each.value.object_name
  principal  = each.value.group
  privileges = each.value.privileges
  lifecycle {
    precondition {
      condition     = contains(keys(local.group_ids), each.value.group)
      error_message = "Declare the grant principal in groups.tfvars."
    }
  }
  depends_on = [databricks_group.managed, databricks_mws_permission_assignment.group]
}
