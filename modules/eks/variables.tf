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

variable "authentication_mode" {
  type        = string
  description = "Authentication mode for EKS cluster access"
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

#variable "allowed_secret_arns" {
#  description = "List of SecretsManager secret ARNs that the IRSA role is allowed to read"
#  type        = list(string)
#}

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

##################################################
# Common Tags
##################################################

variable "common_tags" {
  description = "Common tags to attach to resources created by this module."
  type        = map(string)
  default     = {}
}


##################################################
# Secrets Manager Allowed Secret Name (Secret Key)
##################################################
variable "allowed_secret_patterns" {
  description = "List of secret name patterns to allow access"
  type        = list(string)
}

##################################################
# Node group variables
##################################################
variable "node_volume_size" {
  description = "Size of the EKS worker node root volume in GB"
  type        = number
  default     = 80
}

##################################################
# Security Group Variables
##################################################
variable "vpc_id" {
  description = "VPC ID where the EKS cluster and nodes will be deployed"
  type        = string
}

##############################
# Tags
##############################
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

##############################
# AWS Region where your cluster will deployed
##############################
variable "region" {
  type        = string
  description = "AWS region"
}

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
}

variable "karpenter_namespace" {
  description = "Namespace to install Karpenter"
  type        = string
}

variable "enable_karpenter" {
  description = "Enable Karpenter installation"
  type        = bool
}

variable "create_namespace_karpenter" {
  description = "Create Karpenter namespace"
  type        = bool
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
}

variable "karpenter_replicas" {
  description = "Number of Karpenter controller replicas"
  type        = number
}

variable "log_level" {
  description = "Log level for Karpenter controller"
  type        = string
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
}

variable "default_nodepool_name" {
  description = "Name of the default NodePool"
  type        = string
}

variable "ami_family" {
  description = "AMI family for nodes (e.g., al2023@latest, bottlerocket@latest)"
  type        = string
}

variable "nodepool_requirements" {
  description = "Requirements for node selection"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
}

#variable "nodepool_taints" {
#  description = "Taints to apply to nodes"
#  type = list(object({
#    key    = string
#    value  = string
#    effect = string
#  }))
#  default = []
#}

variable "nodepool_limits" {
  description = "Resource limits for the NodePool"
  type = object({
    cpu    = optional(string)
    memory = optional(string)
  })
}

variable "node_expire_after" {
  description = "Duration after which nodes will be expired (e.g., 720h for 30 days)"
  type        = string
}

variable "consolidation_policy" {
  description = "Consolidation policy (WhenEmpty, WhenEmptyOrUnderutilized)"
  type        = string
}

variable "consolidate_after" {
  description = "Duration to wait before consolidating"
  type        = string
}

#variable "disruption_budgets" {
#  description = "Disruption budgets for node disruption"
#  type = list(object({
#    nodes    = string
#    schedule = optional(string)
#    duration = optional(string)
#    reasons  = optional(list(string))
#  }))
#  default = []
#}

variable "nodepool_weight" {
  description = "Weight of the NodePool for node selection"
  type        = number
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
}

variable "nodepool_tags" {
  description = "Additional tags for Karpenter-provisioned nodes"
  type        = map(string)
  default     = {}
}