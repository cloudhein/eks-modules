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
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 3
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 3
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 5
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
