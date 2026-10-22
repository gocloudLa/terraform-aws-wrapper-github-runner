# Permisos que tendra el rol asumible (from-central) una vez que el runner
# central lo asuma en ESTA cuenta. Para la prueba: listar RDS y S3.
data "aws_iam_policy_document" "assumed_permissions" {
  statement {
    sid    = "WhoAmI"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ListRds"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ListS3"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]
    resources = ["*"]
  }
}
