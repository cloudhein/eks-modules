resource "aws_eks_addon" "eks_cluster_addon" {
  for_each     = toset(var.eks_cluster_addons)
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = each.value

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_controller.arn

  depends_on = [
    aws_iam_openid_connect_provider.eks, # ensure OIDC exists
    aws_iam_role_policy_attachment.ebs_csi_policy_attachment
  ]
}
