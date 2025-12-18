##############################
# EKS Access Entry for Karpenter Nodes (API mode)
##############################
resource "aws_eks_access_entry" "karpenter_node" {
  count = var.use_access_entries ? 1 : 0

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"

  tags = merge(
    var.tags,
    {
      Name = "karpenter-node-access"
    }
  )

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role.karpenter_node
  ]
}

# Note: EC2_LINUX type automatically gets these Kubernetes groups:
# - system:bootstrappers
# - system:nodes
# No need to manually associate policies - it's handled by the type