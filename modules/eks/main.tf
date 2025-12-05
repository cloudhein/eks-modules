##############################
# EKS Cluster
##############################
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.kubernetes_version
  
  access_config {
    authentication_mode = var.authentication_mode
  }

  vpc_config {
    subnet_ids             = var.private_subnet_ids
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name                                        = "${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

##############################
# IAM Role for EKS Cluster
##############################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

##############################
# IAM Role for EKS Nodes
##############################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
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

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  tags = merge(
    var.common_tags,
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
      "k8s.io/cluster-autoscaler/enabled"             = "true",
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
  )

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy
  ]
}

#################################################

resource "aws_eks_node_group" "stateful_nodes" {
  count           = var.create_stateful_node_group ? 1 : 0
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-stateful-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # ONLY this one subnet → ensures all pods in this NG stay in the same AZ
  subnet_ids = [var.private_subnet_az1]

  instance_types = var.node_instance_types_statefulset

  scaling_config {
    desired_size = var.eks_node_desired_size_statefulset
    max_size     = var.eks_node_max_size_statefulset
    min_size     = var.eks_node_min_size_statefulset
  }


  # label & taint these nodes so only your stateful workloads land here
  labels = {
    "role" = "stateful"
  }

  taint {
    key    = "stateful"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = merge(
    var.common_tags,
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
      "k8s.io/cluster-autoscaler/enabled"             = "true",
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
  )

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy
  ]
}
