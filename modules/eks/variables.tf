##############################
# EKS Cluster Variables
##############################

variable "cluster_name" {
  type        = string
  description = "Name of the EKS Cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes to use for the EKS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS cluster and node group"
}

variable "node_instance_types" {
  type        = list(string)
  description = "List of EC2 instance types for the EKS node group"
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "eks_cluster_addons" {
  type        = list(string)
  description = "EKS cluster add-ons to install"
}

variable "allowed_secret_arns" {
  description = "List of SecretsManager secret ARNs that the IRSA role is allowed to read"
  type        = list(string)
}

variable "secret_store_service_account_namespace" {
  description = "Namespace where the Kubernetes Secret Store ServiceAccount lives"
  type        = string
  default     = "default"
}

variable "secret_store_service_account_name" {
  description = "Name of the Kubernetes Secret Store ServiceAccount"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create a Kubernetes namespace for secret store csi"
  type        = bool
  default     = false
}