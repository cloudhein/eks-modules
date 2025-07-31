variable "cluster_name" {
  type        = string
  description = "The K8s Cluster Name"
}

variable "vpc_cidr_range" {
  type        = string
  description = "CIDR range for the instance"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "List of public subnets"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "List of private subnets"
}