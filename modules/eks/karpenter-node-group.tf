##############################
# System Node Group (Karpenter & Critical Addons)
##############################
resource "aws_eks_node_group" "karpenter_system_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-karpenter-system-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  # Use a stable, general-purpose instance. 
  # t3.medium (4GB RAM) is usually the minimum for system components.
  instance_types = var.karpenter_system_instance_types
  capacity_type  = "ON_DEMAND" # Use On-Demand for stability of the control plane
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = var.karpenter_system_node_desired_size
    max_size     = var.karpenter_system_node_max_size
    min_size     = var.karpenter_system_node_min_size
  }

  # Update config for safer rolling updates
  update_config {
    max_unavailable_percentage = 33
  }

  # ✅ REUSE: Reference the existing Private Node Launch Template
  launch_template {
    id      = aws_launch_template.private_nodes.id
    version = aws_launch_template.private_nodes.latest_version
  }

  # Prevent update loops
  lifecycle {
    ignore_changes = [
      launch_template[0].version
    ]
  }

  # ✅ CRITICAL: Taint this node so regular apps CANNOT schedule here
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  # Label so we can explicitly target it if needed
  labels = {
    "role" = "system"
    "type" = "karpenter"
  }

   tags = merge(
    var.common_tags,
    {
      "Name"                                          = "${var.cluster_name}-karpenter-system-node-group"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      #"k8s.io/cluster-autoscaler/enabled"             = "true"
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
  )

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_access_policy_association.terraform_admin
  ]
}