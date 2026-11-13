resource "databricks_group" "managed" {
  provider     = databricks.account
  for_each     = { for name, group in var.groups : name => group if group.managed }
  display_name = each.key
  lifecycle {
    prevent_destroy = true
  }
}

data "databricks_group" "external" {
  provider     = databricks.account
  for_each     = { for name, group in var.groups : name => group if !group.managed }
  display_name = each.key
}

locals {
  group_ids = merge(
    { for name, group in databricks_group.managed : name => group.id },
    { for name, group in data.databricks_group.external : name => group.id }
  )
  memberships = flatten([
    for name, group in var.groups : [
      for user in group.members : { group = name, user = user }
    ]
  ])
}

data "databricks_user" "employee" {
  provider  = databricks.account
  for_each  = toset([for membership in local.memberships : membership.user])
  user_name = each.key
}

resource "databricks_group_member" "employee" {
  provider  = databricks.account
  for_each  = { for m in local.memberships : jsonencode([m.group, m.user]) => m }
  group_id  = local.group_ids[each.value.group]
  member_id = data.databricks_user.employee[each.value.user].id
}
