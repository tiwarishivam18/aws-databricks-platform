# AWS and Databricks analytics platform

Terraform source for three environments on AWS. This repository configures **existing Databricks workspaces**. Each deployment uses the default Terraform CLI workspace, an explicit S3 key and an isolated local initialization directory.

| Root | Targets | Ownership |
| --- | --- | --- |
| Repository root | dev, stg, prd | Environment VPC, private subnets, S3 gateway endpoint, flow logs, encrypted lake bucket and a scoped policy on the UC role |
| databricks/ | dev, stg, prd | Workspace metastore assignment, isolated catalog and external location, schemas, reader grants, compute policy, optional cluster, team folder, secret scope, workspace settings and optional foreign catalogs |
| databricks/shared/ | shared | Account groups and selected memberships, workspace assignments and explicitly delegated grants on central Unity Catalog objects |

**Start with [SETUP_AND_RUN.md](SETUP_AND_RUN.md).** For the ownership boundaries and adoption procedure, see [docs/operations.md](docs/operations.md).

Reusable modules are under modules/ for AWS and databricks/modules/ for catalog and compute. Root files wire the modules together. The numbered Databricks filenames group related resources for readers. Terraform derives execution order from references and dependencies.

No credentials belong in environment files. Example IDs, names and URLs must be replaced before planning. The template assumes AWS commercial regions, identity-federated workspaces, Unity Catalog and classic compute policy support. Cluster creation defaults to disabled.
