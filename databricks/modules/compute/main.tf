resource "databricks_cluster_policy" "bounded" {
  name = "${var.prefix}-standard"
  definition = jsonencode({
    "spark_version"                       = { type = "fixed", value = var.spark_version }
    "node_type_id"                        = { type = "fixed", value = var.node_type }
    "driver_node_type_id"                 = { type = "fixed", value = var.node_type }
    "data_security_mode"                  = { type = "fixed", value = "USER_ISOLATION" }
    "autotermination_minutes"             = { type = "fixed", value = 20 }
    "autoscale.min_workers"               = { type = "fixed", value = 1 }
    "autoscale.max_workers"               = { type = "range", minValue = 1, maxValue = var.max_workers }
    "num_workers"                         = { type = "forbidden" }
    "aws_attributes.instance_profile_arn" = { type = "forbidden" }
  })
}

resource "databricks_permissions" "policy" {
  cluster_policy_id = databricks_cluster_policy.bounded.id
  access_control {
    group_name       = var.group_name
    permission_level = "CAN_USE"
  }
}

resource "databricks_cluster" "interactive" {
  count                   = var.create_cluster ? 1 : 0
  cluster_name            = "${var.prefix}-interactive"
  policy_id               = databricks_cluster_policy.bounded.id
  spark_version           = var.spark_version
  node_type_id            = var.node_type
  driver_node_type_id     = var.node_type
  data_security_mode      = "USER_ISOLATION"
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = var.max_workers
  }
}

resource "databricks_permissions" "cluster" {
  count      = var.create_cluster ? 1 : 0
  cluster_id = databricks_cluster.interactive[0].id
  access_control {
    group_name       = var.group_name
    permission_level = "CAN_ATTACH_TO"
  }
}
