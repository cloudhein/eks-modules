
output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API server endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_node_group_name" {
  description = "EKS Node Group Name"
  value       = aws_eks_node_group.private_nodes.node_group_name
}

output "secret_store_service_account_name" {
  description = "The name of the created service account"
  value       = kubernetes_service_account.secret_store_irsa.metadata[0].name
}

output "secret_store_service_account_namespace" {
  description = "The namespace of the service account"
  value       = kubernetes_service_account.secret_store_irsa.metadata[0].namespace
}


##################################################
# EKS Cluster Authentication Outputs
##################################################
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

##############################
# Outputs for karpenter
##############################
output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  description = "Name of the Karpenter node instance profile"
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role (for IRSA)"
  value       = aws_iam_role.karpenter_controller.arn
}