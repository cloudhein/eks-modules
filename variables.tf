####### profile to authenticate to aws #######

variable "aws_auth_profile" {
  type        = string
  description = "AWS profile to use for authentication"
  default     = "admin-cli"
}

variable "aws_auth_region" {
  type        = string
  description = "AWS region to use for authentication"
  default     = "ap-southeast-1"
}

####### VPC variables #########

variable "cluster_name" {
  type        = string
  description = "The K8s Cluster Name"
  default     = "dev-eks-cluster"
}

variable "vpc_cidr_range" {
  type        = string
  description = "CIDR range for the instance"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "List of public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "List of private subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

####### EKS variables #########
variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes to use for the EKS cluster"
  default     = "1.33"
}

variable "node_instance_types" {
  type        = list(string)
  description = "List of EC2 instance types for the EKS node group"
  default     = ["c7i-flex.large"]
}

variable "authentication_mode" {
  type        = string
  description = "Authentication mode for EKS cluster access"
  default     = "API_AND_CONFIG_MAP"
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 1
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "eks_cluster_addons" {
  description = "EKS cluster add-ons to install"
  type        = list(string)
  default = [
    "coredns",
    "eks-pod-identity-agent",
    "kube-proxy",
    "vpc-cni"
  ]
}

variable "secret_store_service_account_namespace" {
  description = "Namespace where the Kubernetes Secret Store ServiceAccount lives"
  type        = string
  default     = "default"
}

variable "secret_store_service_account_name" {
  description = "Name of the Kubernetes Secret Store ServiceAccount"
  type        = string
  default     = "secret-store-sa"
}

variable "create_namespace" {
  description = "Whether to create a Kubernetes namespace for secret store csi"
  type        = bool
  default     = false
}

################# stateful node group variables #################

variable "create_stateful_node_group" {
  type        = bool
  description = "Whether to create a stateful node group"
  default     = true
}

variable "eks_node_desired_size_statefulset" {
  type        = number
  description = "Desired number of worker nodes for statefulset"
  default     = 1
}

variable "eks_node_min_size_statefulset" {
  type        = number
  description = "Minimum number of worker nodes for statefulset"
  default     = 1
}

variable "eks_node_max_size_statefulset" {
  type        = number
  description = "Maximum number of worker nodes for statefulset"
  default     = 2
}

variable "node_instance_types_statefulset" {
  type        = list(string)
  description = "List of EC2 instance types for the EKS node group for statefulset"
  default     = ["c7i-flex.large"]
}

###############################################
# EKS Cluster Autoscaler Variables
###############################################
variable "cluster_autoscaler_chart_version" {
  type        = string
  description = "Version of the Cluster Autoscaler Helm chart to deploy"
  default     = "9.49.0"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

###############################################
# Secrets Manager allowed patterns
###############################################
variable "allowed_secret_patterns" {
  description = "List of secret name patterns to allow access"
  type        = list(string)
  default = [
    "mongodb-credentials-*"
  ]
}

##################################################
# Node group variables
##################################################
variable "node_volume_size" {
  description = "Size of the EKS worker node root volume in GB"
  type        = number
  default     = 80
}

variable "stateful_node_volume_size" {
  description = "Size of the EKS stateful worker node root volume in GB"
  type        = number
  default     = 100
}