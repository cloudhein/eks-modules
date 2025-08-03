resource "kubernetes_service_account" "secret_store_irsa" {
  metadata {
    name      = var.secret_store_service_account_name
    namespace = var.secret_store_service_account_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.secrets_irsa_role.arn
    }
  }

  depends_on = [
    kubernetes_namespace.optional_ns
  ]

}

resource "kubernetes_namespace" "optional_ns" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.secret_store_service_account_namespace
  }
}
