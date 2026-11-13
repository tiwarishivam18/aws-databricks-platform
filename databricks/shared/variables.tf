variable "workspace_host" {
  type = string
  validation {
    condition     = can(regex("^https://[a-z0-9-]+\\.cloud\\.databricks\\.com$", var.workspace_host)) && !strcontains(var.workspace_host, "replace")
    error_message = "Set the canonical AWS workspace HTTPS URL without a trailing slash."
  }
}

variable "databricks_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F-]{27}$", var.databricks_account_id))
    error_message = "Supply the actual Databricks account UUID."
  }
}

variable "groups" {
  type = map(object({ managed = bool, members = optional(set(string), []) }))
  validation {
    condition     = alltrue([for g in values(var.groups) : g.managed || length(g.members) == 0])
    error_message = "Maintain membership of external groups in the identity provider."
  }
}

variable "catalog_grants" {
  type = map(map(set(string)))
}

variable "schema_grants" {
  type = map(map(set(string)))
}

variable "workspace_grants" {
  type = map(set(string))
}
