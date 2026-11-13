locals {
  schema_access = flatten([
    for object_name, principals in var.schema_grants : [
      for group, privileges in principals : {
        object_name = object_name
        group       = group
        privileges  = privileges
      }
    ]
  ])
}

resource "databricks_grant" "schema" {
  for_each   = { for a in local.schema_access : jsonencode([a.object_name, a.group]) => a }
  schema     = each.value.object_name
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
