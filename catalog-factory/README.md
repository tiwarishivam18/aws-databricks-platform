# Request a catalog for existing Databricks workspaces

## Use the form

In GitHub open Actions → Request catalog → Run workflow on main. Enter the environment, catalog short name, and comma-separated existing workspace aliases. The requester needs workflow-dispatch access.

| Environment | Short name | Workspaces to add | Result |
|---|---|---|---|
| dev | sales | fraudlab | Create dev_sales, dev_sales.curated and the fraudlab binding |
| dev | finance | fraudlab | Create dev_finance for the same workspace |
| dev | sales | reporting | Add reporting to dev_sales while preserving fraudlab |
| dev | sales | fraudlab,reporting | Retry with both bindings already present |

Review the plan and approve deployment when required. The run summary lists the catalog and its consumer workspaces. In the workspace open Catalog Explorer and look for the catalog with your normal user identity. An empty curated schema is expected on first use.

## Install once

1. Overlay the archive on the repository that already contains workspace-factory/. Install .github/workflows/request-catalog.yml at the repo root and catalog-factory/ next to workspace-factory/. The factory reuses workspace-factory/profiles/<env>.json, including governance host, account ID, user group and S3 base. A pre-existing workspace can be used even if the self-service workspace workflow has never run.
2. For workspaces already created by the workspace form, use their short names. The workflow verifies their request records in the same S3 state bucket and looks up their actual workspace IDs using the configured account and environment-qualified names. For workspaces created elsewhere, put their IDs in catalog-factory/targets/<env>.json, for example {"primary": 123456789}. Register only verified workspaces in the correct environment and regional metastore. Use unique names across factory and legacy aliases. The governance workspace retains its implicit creator binding; use consumer workspace aliases in the form.
3. Reserve the <env>_<shortname> namespace for this root (for example dev_sales), and reserve <managed_base_url>/catalog-requests/ for its storage under an authorized external location. Existing catalogs with other state owners need an explicit adoption or separate binding procedure. All consumer workspaces must already be assigned to the governance workspace's metastore. Verify governance access to the external location and group membership/assignment on each target.
4. Create GitHub Environments catalog-dev-plan and catalog-dev-apply (and corresponding stg/prd pairs). Set AWS_ROLE_ARN, EXPECTED_ACCOUNT, STATE_REGION, STATE_BUCKET, PLAN_BUCKET and DATABRICKS_CLIENT_ID. Both jobs use matching region and buckets. Extend AWS and Databricks OIDC trust to the exact new environment subjects, restrict branches to main, and configure apply reviewers. Use catalog-scoped identities with account workspace listing and the governance workspace permissions to create catalogs/schemas, grant privileges, create managed storage at the chosen external location and manage workspace bindings. Workspace creation privileges are unnecessary.
5. In S3 permit listing the catalog-factory/<env>/ prefix, state/lock operations at catalog-factory/<env>/<name>/terraform.tfstate and its .tflock, and reading workspace-factory/<env>/*/request.json. The apply role can write binding marker objects under catalog-factory/<env>/<name>/bindings/. Keep marker deletion restricted, keep S3 versioning and encryption enabled, and include KMS permissions where required. Plan writes and apply reads catalog-plans/ORG/REPO/<env>/ in the private plan bucket. Retain binding markers while their catalog is managed. Enforce prefix-specific permissions for each role.
6. Run these commands on a registry-connected machine and commit the generated catalog-factory/.terraform.lock.hcl before merging to main.

```bash
cd catalog-factory
terraform providers lock -platform=linux_amd64
terraform init -backend=false -input=false
terraform validate
python3 -m unittest discover -s tests -v
```

7. Try the first and third Dev examples. In the second plan expect one additional databricks_workspace_binding.consumer and no removal. Check the bindings in Catalog Explorer and check access with the intended user.

## State, access and recovery

Each catalog has one state (e.g. catalog-factory/dev/sales/terraform.tfstate). This root owns its catalog, starter schema, two grants and consumer bindings. It creates no workspace or metastore assignment. Creating dev_finance uses a separate state. Selecting an existing catalog name owned by a different root does not adopt it automatically.

Requests only add consumers. Before planning, the workflow unions the submitted aliases with previously approved aliases in S3. After approval, it records submitted aliases before applying the verified saved plan. Rerun the same request after a partial apply. Same-catalog runs share one GitHub concurrency group and use Terraform state locking. A canceled pending run or stale plan can be submitted again. Removing bindings, renaming aliases and retiring catalogs require a platform change that reconciles markers and state. The self-service plan guard blocks updates, replacements and deletes.

The baseline gives the environment group USE_CATALOG on the catalog and USE_SCHEMA/SELECT on curated. Consumer bindings are read-only. Workspace login and data privileges remain separate. Catalog owners, administrators and the governance workspace retain administrative access. Any write-enabled team workflow should define an approved writer group and a suitable write-enabled workspace binding. Bindings apply to the catalog across all its schemas.
