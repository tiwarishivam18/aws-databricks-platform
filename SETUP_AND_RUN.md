# Set up and run

## 1. Establish the target inventory

Use Terraform CLI 1.13.4, Bash and Git. Identify an existing Databricks workspace for each target, its numeric ID, canonical URL, account UUID and regional metastore ID. The shared provider uses a governance workspace with access to the central securables. It may be an existing environment workspace. Each workspace target must represent a different workspace.

Confirm the AWS account and region, two available AZs, unused CIDRs and globally unique lake bucket names. Have the network team authorize VPC flow log delivery to the central log bucket. The VPC created here has private routes and an S3 gateway endpoint. Connecting a classic workspace to a VPC requires workspace network registration, security groups and a tested transit/NAT or PrivateLink design. This root does not attach or rewire existing workspaces. Import an existing VPC and its managed children if it already provides the desired foundation.

For each environment, supply an existing Databricks UC storage credential backed by a dedicated AWS role in the lake bucket's AWS account. The trust owner configures the Databricks UC principal, credential-specific external ID and required self-assume permissions. The AWS root adds one named inline policy for the dedicated bucket and key. Confirm the credential uses that exact role and is usable in the matching workspace. If the organization uses IdP groups, set managed=false and maintain their memberships in the IdP. Workspace assignment still belongs to the shared root.

## 2. Prepare the remote backends

Create or select a private, versioned state bucket in the region named in backend.hcl. Enable public access blocking, TLS enforcement, encryption and restricted administration. For a customer-managed state key, set kms_key_id in each backend file and grant the corresponding KMS permissions. Use a separate encrypted, private plan bucket with a short expiry on current and noncurrent versions. A saved Terraform plan can contain sensitive values.

Edit all seven backend.hcl files. Keep the seven keys unique. The backend role needs prefix-limited bucket listing, GetObject/PutObject on its state, and GetObject/PutObject/DeleteObject on its matching .tflock object. The plan role also needs lock access. Configure recovery version retention to your organization's standard. Existing states require an ownership review before changing a backend.

## 3. Configure the inputs

1. Update root terraform.tfvars with organizational tags. Edit envs/<target>/environment.tfvars for AWS account, AZs, log destination, role and bucket.
2. Edit databricks/envs/<target>/environment.tfvars with real account, metastore, host and workspace ID. Match the workspace ID to its URL in the account console.
3. Set the external credential and lake URL in storage.tfvars. The lake URL must match the AWS lake_url output. Confirm the SP can create an external location using the credential and create managed storage under the location. Check runtime and node availability before enabling interactive compute.
4. Edit the groups, source users and numeric workspace IDs in databricks/envs/shared/. Account users referenced by email must already exist. Keep central grant maps empty until the central objects exist and the governance workspace can reach them.
5. Review inherited workspace/folder ACLs, workspace entitlements, UC grants and cloud role policies before treating access as environment isolation. The non-prod group is assigned to dev and stg. The prod group is assigned to prd.

## 4. Initialize dependency locks and validate

On a machine with provider-registry access, run from the repository root. Review and commit all three generated .terraform.lock.hcl files with the repository before enabling deployment. Supply your team's approved registry mirror configuration if required.

```bash
for dir in . databricks databricks/shared; do
  terraform -chdir="$dir" providers lock -platform=linux_amd64 -platform=windows_amd64
  terraform -chdir="$dir" init -backend=false -input=false
  terraform -chdir="$dir" validate
done
terraform fmt -recursive
terraform test -filter=tests/foundation.tftest.hcl
```

For existing infrastructure follow the adoption procedure before applying. For a fresh target initialize, inspect and apply each saved plan individually. The wrapper selects the input directory, root and backend together.

```bash
scripts/target.sh aws dev init
scripts/target.sh aws dev plan
scripts/target.sh aws dev apply
scripts/target.sh aws dev output

scripts/target.sh databricks shared init
scripts/target.sh databricks shared plan
scripts/target.sh databricks shared apply

scripts/target.sh databricks dev init
scripts/target.sh databricks dev plan
scripts/target.sh databricks dev apply
scripts/target.sh databricks dev output
```

Use the same sequence for stg and prd AWS and workspace deployments. Run shared once. Local AWS authentication can use a short-lived AWS profile. Databricks providers accept unified authentication. Use an account/workspace-authorized service principal and supply credentials through the environment or an approved federation mechanism.

## 5. Configure GitHub Actions

The PR workflow initializes without a backend and validates all three roots. Deployment runs by manual dispatch from main. Pick a layer and target, then leave Apply unchecked for a plan-only run.

Create two GitHub Environments per deployment target, e.g. aws-dev-plan and aws-dev-apply, databricks-prd-plan and databricks-prd-apply, or databricks-shared-plan and databricks-shared-apply. Restrict deployment branches to main. Require independent reviewers on apply environments and prevent self-review for production. Protect main and changes to workflows, providers, roles and production inputs with required review.

| GitHub Environment variable | Value |
| --- | --- |
| AWS_ROLE_ARN | Short-lived plan or apply role ARN for this target |
| AWS_ACCOUNT_ID | Expected AWS caller account |
| AWS_REGION | Region used by the Actions AWS client |
| PLAN_BUCKET | Private encrypted plan bucket shared by this target's plan and apply roles |
| DATABRICKS_CLIENT_ID | Federated SP application ID for Databricks targets |

Configure AWS IAM OIDC trust for token.actions.githubusercontent.com, audience sts.amazonaws.com and the exact subject repo:ORG/REPO:environment:ENVIRONMENT_NAME. Create the matching Databricks GitHub federation policy for each Databricks job identity and subject, with the audience configured as documented by Databricks. Apply jobs use environment credentials; saved plans contain no literal provider credentials. Grant the plan identity read/list access to managed APIs, state read/locking, and write access to its plan prefix. Grant the apply identity the required resource mutations, state update/locking and read access to the same plan prefix. The plan prefix is plans/ORG/REPO/LAYER/TARGET/. Include KMS permissions for both identities where applicable.

For a deployment dispatch enable Apply. Read the plan job output before approving the apply job. The apply runner verifies the saved plan's SHA-256 and applies that exact file. A stale plan requires a fresh deployment run. For private endpoints use an organization-controlled runner with the required routing and DNS in both jobs. Keep untrusted PR jobs on separate runners.
