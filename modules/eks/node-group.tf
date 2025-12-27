##############################
# Launch Template for Private Node Group
##############################
resource "aws_launch_template" "private_nodes" {
  name_prefix = "${var.cluster_name}-private-nodes-"
  description = "Launch template for EKS private node group"

  # EBS Volume Configuration
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_volume_size # Add this variable, default: 80
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      delete_on_termination = true
    }
  }

  # IMDSv2 Configuration (Security Best Practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 2          # Allow pods to access IMDS
    instance_metadata_tags      = "enabled"
  }

  # Network Configuration
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    # No need to define security group,eks cluster sg will automatically associated to managed node group
  }

  # Tag Specifications
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name                                            = "${var.cluster_name}-private-node"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.cluster_name}-private-node-volume"
      }
    )
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.cluster_name}-private-node-eni"
      }
    )
  }

  ############################## create_before_destroy launch template behaviour ##############################
  # create new launch template
  # Update node group to use new template
  # Destroy old launch template 
  ############################## create_before_destroy launch template behaviour ##############################
  lifecycle {
    create_before_destroy = true
  }
}

##############################
# EKS Managed Node Group (Private Subnets)
##############################
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-private-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND" # or "SPOT" for cost savings
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  # Update config for safer rolling updates
  update_config {
    max_unavailable_percentage = 33
  }

  launch_template {
    id      = aws_launch_template.private_nodes.id
    # ✅ FIX: Use the attribute reference. 
    # This resolves to the actual number (e.g. "5") so it matches the AWS state.
    version = aws_launch_template.private_nodes.latest_version
  }

  # ✅ ADD LABELS to identify stable nodes
  labels = {
    "node-type" = "stable"
    "workload"  = "system"
  }

  tags = merge(
    var.common_tags,
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      #"k8s.io/cluster-autoscaler/enabled"             = "true"
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
  )

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_eks_access_policy_association.terraform_admin
  ]
}
