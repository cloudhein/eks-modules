
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

// outputs.tf

output "stateful_node_group_labels" {
  description = "The labels applied to the stateful node group"
  value       = try(aws_eks_node_group.stateful_nodes[0].labels, {})
}

output "stateful_node_group_taints" {
  description = "The taints applied to the stateful node group"
  value       = try(aws_eks_node_group.stateful_nodes[0].taint, [])
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