####################################
# 1. IAM policy document: SecretsManager read-only
####################################
data "aws_iam_policy_document" "secretsmanager" {
  statement {
    sid    = "AllowReadSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    # tightened to exactly the ARNs the user provides
    resources = var.allowed_secret_arns
  }
}

resource "aws_iam_policy" "secrets_manager_read" {
  name   = "${var.cluster_name}-SecretsManagerRead"
  policy = data.aws_iam_policy_document.secretsmanager.json
}

############################################
# 2. Trust policy for IRSA (kube-system SA)
############################################
data "aws_iam_policy_document" "secret_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test = "StringEquals"
      # Now scoped to the ServiceAccount in kube-system
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.secret_store_service_account_namespace}:${var.secret_store_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "secrets_irsa_role" {
  name               = "${var.cluster_name}-secrets-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.secret_assume_role.json
}

############################################
# 3. Attach the SecretsManager policy to that IRSA role
############################################
resource "aws_iam_role_policy_attachment" "secrets_irsa_attach" {
  role       = aws_iam_role.secrets_irsa_role.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}
