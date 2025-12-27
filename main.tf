module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  vpc_cidr_range       = var.vpc_cidr_range
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr

  # Add this tag for karpenter to find the nodes in eks modules and we pass the Karpenter discovery tag here so the VPC module applies it natively.
  private_subnet_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

module "eks" {
  source = "./modules/eks"

  ############### got the vpc id value & private subnet value from vpc module outputs ###############
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  ############### EKS Cluster input variables ###############
  cluster_name          = var.cluster_name
  kubernetes_version    = var.kubernetes_version
  authentication_mode   = var.authentication_mode
  node_instance_types   = var.node_instance_types
  eks_node_desired_size = var.eks_node_desired_size
  eks_node_min_size     = var.eks_node_min_size
  eks_node_max_size     = var.eks_node_max_size
  eks_cluster_addons    = var.eks_cluster_addons
  #allowed_secret_arns                    = var.allowed_secret_arns
  secret_store_service_account_namespace = var.secret_store_service_account_namespace
  secret_store_service_account_name      = var.secret_store_service_account_name
  create_namespace                       = var.create_namespace

  allowed_secret_patterns = var.allowed_secret_patterns

  node_volume_size = var.node_volume_size

  region = var.region

  alb_controller_version = var.alb_controller_version

  ############### Karpenter input variables ###############
  use_access_entries = var.use_access_entries

  karpenter_version          = var.karpenter_version
  karpenter_namespace        = var.karpenter_namespace
  enable_karpenter           = var.enable_karpenter
  create_namespace_karpenter = var.create_namespace_karpenter

  controller_resources = var.controller_resources
  karpenter_replicas   = var.karpenter_replicas
  log_level            = var.log_level

  create_default_nodepool = var.create_default_nodepool
  default_nodepool_name   = var.default_nodepool_name
  ami_family              = var.ami_family
  nodepool_requirements   = var.nodepool_requirements
  nodepool_limits         = var.nodepool_limits
  node_expire_after       = var.node_expire_after
  consolidation_policy    = var.consolidation_policy
  consolidate_after       = var.consolidate_after
  nodepool_weight         = var.nodepool_weight
  user_data               = var.user_data
  block_device_mappings   = var.block_device_mappings
  nodepool_tags           = var.nodepool_tags
}