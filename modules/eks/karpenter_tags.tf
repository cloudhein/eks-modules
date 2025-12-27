resource "aws_ec2_tag" "karpenter_security_group_tag" {
  resource_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.private_nodes
  ]
}