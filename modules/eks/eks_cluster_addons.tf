# ---------------------------------------------------------
# 1. Generic Add-on Loop
# ---------------------------------------------------------
# This manages simple addons that don't need custom configuration
# (e.g., coredns, kube-proxy, eks-pod-identity-agent)
resource "aws_eks_addon" "eks_cluster_addon" {
  # ✅ FILTER: We dynamically remove "vpc-cni" and "aws-ebs-csi-driver" from the list
  # because they are defined explicitly below with specific configurations.

  for_each = toset([
    for addon in var.eks_cluster_addons : addon
    if addon != "vpc-cni" && addon != "aws-ebs-csi-driver"
  ])

  cluster_name = aws_eks_cluster.eks.name
  addon_name   = each.value

  depends_on = [aws_eks_cluster.eks]
}

# ---------------------------------------------------------
# 2. EBS CSI Driver (Specific Config)
# ---------------------------------------------------------
# Defined separately because it needs a Service Account Role ARN
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_controller.arn

  depends_on = [
    aws_iam_openid_connect_provider.eks,
    aws_iam_role_policy_attachment.ebs_csi_policy_attachment
  ]
}