module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  vpc_cidr_range       = var.vpc_cidr_range
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
}

module "eks" {
  source = "./modules/eks"

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_name                           = var.cluster_name
  kubernetes_version                     = var.kubernetes_version
  node_instance_types                    = var.node_instance_types
  eks_node_desired_size                  = var.eks_node_desired_size
  eks_node_min_size                      = var.eks_node_min_size
  eks_node_max_size                      = var.eks_node_max_size
  eks_cluster_addons                     = var.eks_cluster_addons
  allowed_secret_arns                    = var.allowed_secret_arns
  secret_store_service_account_namespace = var.secret_store_service_account_namespace
  secret_store_service_account_name      = var.secret_store_service_account_name
  create_namespace                       = var.create_namespace
}