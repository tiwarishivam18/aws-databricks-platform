# Ownership and operations

## Adopt existing resources

Record existing backend settings and select the workspace that currently owns the deployment. List its resource addresses with terraform state list and create a protected state backup. Freeze concurrent deployments during a handover. Match existing names, settings and full access lists before importing. Use moved blocks for address changes within one state. For an object crossing states, release the old owner without destroying the real object, import into the new root, and review both plans before resuming deployment. Avoid pointing these roots at empty state for existing deployments.

Typical import addresses include module.networking.aws_vpc.this, module.storage.aws_s3_bucket.lake, databricks_metastore_assignment.workspace, and databricks_group.managed["analytics-prod"]. Import S3 versioning, policy and encryption separately when adopting these resources. Import existing metastore assignments using workspace_id|metastore_id. Read the pinned provider's import syntax for each resource. Reconcile workspace settings and ACLs before applying. A databricks_permissions resource owns the direct permission list for its target.

## Change access

For Terraform-managed groups add an existing account user's login to members in shared/groups.tfvars and apply shared. Removing that entry removes the managed membership. The account user remains. The membership resource tracks individual memberships, so externally added memberships require a separate inventory review. For SCIM-managed groups change the IdP roster. Verify offboarding against other groups, direct grants and tokens.

Each environment owns its catalog-reader and schema-reader grants. The shared grant files apply only to separately delegated central objects. Give each (securable, principal) pair one owner, and never combine an authoritative databricks_grants resource with this per-principal model for the same securable. A central schema grant usually also needs USE_CATALOG on its parent. Operating across multiple metastores requires a separate provider target and state for each governance scope.

## Operate and recover

Read the matching plan before increasing privileges, changing folder ACLs or adding data federation. Existing resource owners and inherited grants can affect the result. The secret scope starts with creator administration. Provision application secret values and narrowly scoped consumer ACLs through the organization's secret rotation process. Never commit secret values or put passwords into foreign_catalogs.options.

Test in Dev with an ordinary group member. Verify the workspace appears, the curated schema is readable, and unrelated catalogs and Prod are inaccessible. Test the opposite direction with a Prod identity. Check S3 versioning, KMS key, private subnet routes, flow log delivery and storage-credential validation. Enabling interactive clusters incurs AWS and Databricks usage charges. A cluster policy bounds cluster shape but does not impose an account spending limit.

For drift, run a new plan from the matching target and reconcile the owner of the change. For a failed apply, inspect the state and remote objects, fix the cause and re-plan. For a lost lock, verify no active job holds it before manual recovery. Restore an S3 state version only during a controlled recovery after comparing its lineage and resources with the live environment. Roll back configuration with a reviewed commit and a fresh plan. Restoring state does not roll back cloud resources.
