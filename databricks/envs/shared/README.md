# Shared access inputs

Set the governance workspace URL and account UUID in environment.tfvars. Edit groups.tfvars for managed groups/members or external group lookups. Configure workspace USER assignments by numeric workspace ID. Catalog and schema grants are optional maps of existing central object → group → privileges. Example schema keys use catalog.schema. Run scripts/target.sh databricks shared from the repository root with init, plan or apply.
