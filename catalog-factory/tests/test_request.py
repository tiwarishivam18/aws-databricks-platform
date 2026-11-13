import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import request


class CatalogTest(unittest.TestCase):
    def test_state_and_aliases(self):
        self.assertEqual(request.inputs("dev", "sales", "ml, bi,ml"),
                         ("catalog-factory/dev/sales", {"ml", "bi"}))
        self.assertNotEqual(request.inputs("prd", "sales", "ml")[0], request.inputs("dev", "sales", "ml")[0])

    def test_invalid_target(self):
        for args in [("dev", "../sales", "ml"), ("prd", "sales", "dev/ml"), ("stg", "sales", "")]:
            with self.assertRaises(ValueError):
                request.inputs(*args)

    def test_environment_boundary(self):
        with self.assertRaises(ValueError):
            request.resolve(["bi"], {}, "analytics", "dev", lambda _: {"environment":"prd","slug":"bi"})

    def test_rejects_removal(self):
        for actions in (["delete"], ["update"], ["delete", "create"]):
            with self.assertRaises(ValueError):
                request.plan_guard({"resource_changes":[{"address":"binding.bi","change":{"actions":actions}}]})

    def test_repeat_and_extend(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            root = base / "catalog-factory"
            (root / "targets").mkdir(parents=True)
            (root / "targets/dev.json").write_text('{"original":111}')
            profiles = base / "workspace-factory/profiles"
            profiles.mkdir(parents=True)
            (profiles / "dev.json").write_text(json.dumps(dict(deployment_prefix="analytics", governance_host="gov",
                account_id="a", access_group="users", managed_base_url="s3://lake/prefix", existing_catalog="analytics_dev")))
            markers = set()
            def mock_aws(op, *args):
                if op == "list-objects-v2":
                    return json.dumps({"Contents":[{"Key":key} for key in markers]})
                if op == "put-object":
                    markers.add(args[-1])
                if op == "get-object":
                    self.assertIn("workspace-factory/dev/reporting/request.json", args)
                    Path(args[-1]).write_text('{"environment":"dev","slug":"reporting"}')
                return "{}"
            env=dict(TARGET="dev", SLUG="sales", RUNNER_TEMP=directory, STATE_BUCKET="state", STATE_REGION="us-east-1")
            with patch("request.ROOT",root), patch("request.aws", side_effect=mock_aws), patch.dict(os.environ,env):
                for target in ["original","reporting","reporting"]:
                    os.environ["WORKSPACES"] = target
                    request.main("prepare")
                    request.main("record")
                config=json.loads((base / "catalog.tfvars.json").read_text())["config"]
                self.assertEqual(config["registered_ids"], {"original":111})
                self.assertEqual(config["workspace_names"], {"reporting":"analytics-dev-reporting"})
                self.assertEqual(config["catalog"], "dev_sales")
                self.assertEqual(len(markers), 2)


if __name__ == "__main__":
    unittest.main()
