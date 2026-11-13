#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
layer=${1:?Specify aws or databricks}
target=${2:?Specify dev, stg, prd or shared}
operation=${3:?Specify init, plan, apply or output}
case "$layer/$target" in
  aws/dev|aws/stg|aws/prd) root="$repo"; config="$repo/envs/$target" ;;
  databricks/dev|databricks/stg|databricks/prd) root="$repo/databricks"; config="$root/envs/$target" ;;
  databricks/shared) root="$repo/databricks/shared"; config="$repo/databricks/envs/shared" ;;
  *) echo "Unknown deployment target: $layer/$target" >&2; exit 2 ;;
esac
export TF_WORKSPACE=default
export TF_DATA_DIR="$repo/.tfdata/$layer/$target"
mkdir -p "$TF_DATA_DIR"
plan="$TF_DATA_DIR/deployment.tfplan"
tf=(terraform "-chdir=$root")
case "$operation" in
  init)
    "${tf[@]}" init -input=false -reconfigure -lockfile=readonly "-backend-config=$config/backend.hcl"
    ;;
  plan)
    rm -f -- "$plan"
    flags=()
    for file in "$config"/*.tfvars; do flags+=("-var-file=$file"); done
    "${tf[@]}" plan -input=false -lock-timeout=5m "${flags[@]}" "-out=$plan"
    ;;
  apply)
    "${tf[@]}" apply -input=false -lock-timeout=5m "$plan"
    rm -f -- "$plan"
    ;;
  output) "${tf[@]}" output ;;
  *) echo "Unsupported operation: $operation" >&2; exit 2 ;;
esac
