# --------------------------------------------------------
# 2. Install the AWS Load Balancer Controller via Helm
# --------------------------------------------------------
# This replicates the "helm install" command from the docs.
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_version

  # 1. Use the existing Service Account we created above
  set = [
    {
    name  = "serviceAccount.create"
    value = "false"
  },
  {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  },
  # 2. Cluster Name (Required)
  {
    name  = "clusterName"
    value = var.cluster_name
  },
  # 3. Explicitly set VPC and Region (Best Practice for v2.5+)
  {
    name  = "vpcId"
    value = var.vpc_id
  },
  {
    name  = "region"
    value = var.region
  }
  ]

  # 4. Wait for the Service Account to be ready
  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}