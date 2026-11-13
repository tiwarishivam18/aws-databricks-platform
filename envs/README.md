# Deployment inputs

Each directory supplies the backend and environment overrides for the AWS root. The wrapper loads root terraform.tfvars automatically and passes exactly one environment file. Use the lake_url output as the storage contract for Databricks.
