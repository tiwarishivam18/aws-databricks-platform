# The account team owns role trust, including the credential external ID and self-assume.
data "aws_iam_policy_document" "lake" {
  statement {
    sid       = "LakeBucketMetadata"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
    resources = [var.bucket_arn]
  }

  statement {
    sid = "LakeObjects"
    actions = [
      "s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["${var.bucket_arn}/lake/*"]
  }

  statement {
    sid       = "LakeEncryption"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey*"]
    resources = [var.key_arn]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lake" {
  name   = "${var.prefix}-lake-access"
  role   = var.role_name
  policy = data.aws_iam_policy_document.lake.json
}
