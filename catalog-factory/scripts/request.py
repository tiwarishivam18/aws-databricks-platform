"""Build an additive catalog request from reviewed environment profiles."""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def inputs(env, slug, csv):
    if env not in ("dev", "stg", "prd") or not re.fullmatch("[a-z][a-z0-9_]{0,39}", slug):
        raise ValueError("Choose a valid environment and a short lowercase catalog name (max 40 characters).")
    aliases = {s.strip() for s in csv.split(",")}
    if not all(re.fullmatch("[a-z][a-z0-9-]{0,31}", s) for s in aliases):
        raise ValueError("Specify one or more workspace aliases separated by commas.")
    return f"catalog-factory/{env}/{slug}", aliases


def aws(*args):
    return subprocess.check_output(["aws", "s3api", *args], text=True)


def load_members(bucket, prefix):
    # AWS CLI automatically paginates list-objects-v2.
    data = json.loads(aws("list-objects-v2", "--bucket", bucket, "--prefix", prefix + "/bindings/"))
    return {entry["Key"].removeprefix(prefix + "/bindings/") for entry in data.get("Contents", [])}


def resolve(aliases, registry, prefix, env, lookup):
    names, ids = {}, {}
    for alias in sorted(aliases):
        if alias in registry:
            ids[alias] = int(registry[alias])
            if ids[alias] <= 0:
                raise ValueError("Workspace ID must be positive.")
        else:
            record = lookup(alias)
            if record.get("environment") != env or record.get("slug") != alias:
                raise ValueError("Workspace request does not match the selected environment.")
            names[alias] = f"{prefix}-{env}-{alias}"
    return names, ids


def plan_guard(plan):
    for change in plan.get("resource_changes", []):
        if set(change["change"]["actions"]) - {"read", "create", "no-op"}:
            raise ValueError("Platform review required for " + change["address"])


def main(command):
    if command == "check-plan":
        plan_guard(json.load(sys.stdin))
        return
    env, slug = os.environ["TARGET"], os.environ["SLUG"]
    prefix, requested = inputs(env, slug, os.environ["WORKSPACES"])
    tmp, bucket = Path(os.environ["RUNNER_TEMP"]), os.environ["STATE_BUCKET"]
    if command == "record":
        # A marker's key is its complete meaning. Rewriting it on retry is idempotent.
        for alias in sorted(requested):
            aws("put-object", "--bucket", bucket, "--key", f"{prefix}/bindings/{alias}")
        return
    if command != "prepare":
        raise ValueError("Unknown command")
    profiles = ROOT.parent / "workspace-factory" / "profiles"
    profile = json.loads((profiles / f"{env}.json").read_text())
    if "replace" in json.dumps(profile).lower():
        raise ValueError("Complete the environment workspace-factory profile first.")
    registry = json.loads((ROOT / "targets" / f"{env}.json").read_text())
    def lookup(alias):
        file = tmp / "workspace-request.json"
        aws("get-object", "--bucket", bucket, "--key", f"workspace-factory/{env}/{alias}/request.json", str(file))
        return json.loads(file.read_text())
    aliases = requested | load_members(bucket, prefix)
    names, ids = resolve(aliases, registry, profile["deployment_prefix"], env, lookup)
    catalog = f"{env}_{slug}"
    if catalog == profile["existing_catalog"]:
        raise ValueError("This catalog already belongs to the environment root.")
    config = dict(
        catalog=catalog,
        governance_host=profile["governance_host"],
        governance_workspace_id=profile.get("governance_workspace_id"),
        account_id=profile["account_id"],
        group=profile["access_group"],
        storage_root=profile["managed_base_url"].rstrip("/") + "/catalog-requests/" + catalog,
        workspace_names=names,
        registered_ids=ids,
    )
    (tmp / "catalog.tfvars.json").write_text(json.dumps({"config": config}))
    (tmp / "backend.hcl").write_text("\n".join([
        f"bucket = {json.dumps(bucket)}", f"region = {json.dumps(os.environ['STATE_REGION'])}",
        f"key = {json.dumps(prefix + '/terraform.tfstate')}", "encrypt = true", "use_lockfile = true"
    ]) + "\n")


if __name__ == "__main__":
    try:
        main(sys.argv[1])
    except (ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
