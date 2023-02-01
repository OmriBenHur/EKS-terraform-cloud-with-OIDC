data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:default:aws-test"]
      variable = "${replace(aws_iam_openid_connect_provider.eks-open-id-conn.url, "https://", "")}:sub"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-open-id-conn.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"
  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-policy-attachment"
  policy_arn = aws_iam_policy.test-policy.arn
  roles      = [aws_iam_role.test_oidc.name]
}