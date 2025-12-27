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

# ✅ ADD THIS: Allow passing extra tags (like Karpenter tags) into the module
variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
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

##############################
# AWS Region where your cluster will deployed
##############################
variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

############################################################
#           Karpenter related input variables              #
############################################################

##############################
# aws-auth ConfigMap Management
##############################
variable "use_access_entries" {
  description = "Use EKS Access Entries (API mode) instead of aws-auth ConfigMap. Set to true if authentication_mode is API or API_AND_CONFIG_MAP"
  type        = bool
  default     = true
}

##############################
# Karpenter Configuration
##############################
variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "1.8.3"
}

variable "karpenter_namespace" {
  description = "Namespace to install Karpenter"
  type        = string
  default     = "kube-system"
}

variable "enable_karpenter" {
  description = "Enable Karpenter installation"
  type        = bool
  default     = true
}

variable "create_namespace_karpenter" {
  description = "Create Karpenter namespace"
  type        = bool
  default     = false
}

##############################
# Controller Resources (Karpenter Helm Values)
##############################
variable "controller_resources" {
  description = "Resource requests and limits for Karpenter controller"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "1"
      memory = "1Gi"
    }
    limits = {
      cpu    = "1"
      memory = "1Gi"
    }
  }
}

variable "karpenter_replicas" {
  description = "Number of Karpenter controller replicas"
  type        = number
  default     = 1
}

variable "log_level" {
  description = "Log level for Karpenter controller"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error"
  }
}

##############################
# Karpenter NodePool Configuration
##############################
variable "create_default_nodepool" {
  description = "Create a default NodePool"
  type        = bool
  default     = true
}

variable "default_nodepool_name" {
  description = "Name of the default NodePool"
  type        = string
  default     = "default"
}

variable "ami_family" {
  description = "AMI family for nodes (e.g., al2023@latest, bottlerocket@latest)"
  type        = string
  default     = "al2023@v20251209"
}

variable "nodepool_requirements" {
  description = "Requirements for node selection"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values   = ["amd64"]
    },
    {
      key      = "kubernetes.io/os"
      operator = "In"
      values   = ["linux"]
    },
    {
      key      = "karpenter.sh/capacity-type"
      operator = "In"
      values   = ["on-demand"] # Free tier doesn't support spot, use on-demand only
    },
    {
      key      = "node.kubernetes.io/instance-type"
      operator = "In"
      values   = ["t3.micro", "t3.small", "c7i-flex.large", "m7i-flex.large"]
      #values  = ["c", "m", "r"]
    },
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values   = ["amd64"]
    }
  ]
}

variable "nodepool_limits" {
  description = "Resource limits for the NodePool"
  type = object({
    cpu    = optional(string)
    memory = optional(string)
  })
  default = {
    cpu = "1000"
  }
}

variable "node_expire_after" {
  description = "Duration after which nodes will be expired (e.g., 720h for 30 days)"
  type        = string
  default     = "720h"
}

variable "consolidation_policy" {
  description = "Consolidation policy (WhenEmpty, WhenEmptyOrUnderutilized)"
  type        = string
  default     = "WhenEmptyOrUnderutilized"
}

variable "consolidate_after" {
  description = "Duration to wait before consolidating"
  type        = string
  default     = "1m"
}

variable "nodepool_weight" {
  description = "Weight of the NodePool for node selection"
  type        = number
  default     = 10
}

variable "user_data" {
  description = "Custom user data for nodes"
  type        = string
  default     = ""
}

variable "block_device_mappings" {
  description = "Block device mappings for nodes"
  type = list(object({
    deviceName = string
    ebs = object({
      volumeSize          = string
      volumeType          = string
      deleteOnTermination = bool
      encrypted           = optional(bool)
    })
  }))
  default = [
    {
      deviceName = "/dev/xvda"
      ebs = {
        volumeSize          = "20Gi"
        volumeType          = "gp3"
        deleteOnTermination = true
        encrypted           = true
      }
    }
  ]
}

variable "nodepool_tags" {
  description = "Additional tags for Karpenter-provisioned nodes"
  type        = map(string)
  default     = {}
}

##########################################
# ALB controller variables
##########################################

variable "alb_controller_version" {
  description = "Version of the AWS Load Balancer Controller to install"
  type        = string
  default     = "1.17.0"
}