# ========================================
# Control Plane Security Group
# ========================================
resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_name}-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-control-plane-sg"
      Type = "control-plane"
    }
  )
}

# Control Plane - Outbound Rules
resource "aws_vpc_security_group_egress_rule" "control_plane_egress_all" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow all outbound traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "control-plane-egress-all"
  }
}

# ========================================
# Cluster Security Group
# ========================================
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster communication"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
      Type = "cluster"
    }
  )
}

# Cluster SG - Inbound: Allow all from itself
resource "aws_vpc_security_group_ingress_rule" "cluster_ingress_self" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all traffic from cluster security group to itself"
  
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.cluster.id

  tags = {
    Name = "cluster-ingress-self"
  }
}

# Cluster SG - Inbound: Allow all from node shared security group
resource "aws_vpc_security_group_ingress_rule" "cluster_ingress_from_nodes" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all traffic from node shared security group"
  
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.node_shared.id

  tags = {
    Name = "cluster-ingress-from-nodes"
  }
}

# Cluster SG - Outbound: Allow all to itself
resource "aws_vpc_security_group_egress_rule" "cluster_egress_self" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all traffic to cluster security group itself"
  
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.cluster.id

  tags = {
    Name = "cluster-egress-self"
  }
}

# Cluster SG - Outbound: Allow all IPv4
resource "aws_vpc_security_group_egress_rule" "cluster_egress_all" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all outbound IPv4 traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "cluster-egress-all-ipv4"
  }
}

# ========================================
# Node Shared Security Group (used for future usecases like unmanged node group)
# ========================================
resource "aws_security_group" "node_shared" {
  name        = "${var.cluster_name}-node-shared-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-node-shared-sg"
      Type = "node-shared"
    }
  )
}

# Node Shared SG - Inbound: Allow all from itself (node-to-node communication)
resource "aws_vpc_security_group_ingress_rule" "node_ingress_self" {
  security_group_id = aws_security_group.node_shared.id
  description       = "Allow nodes to communicate with each other"
  
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.node_shared.id

  tags = {
    Name = "node-ingress-self"
  }
}

# Node Shared SG - Inbound: Allow all from cluster security group
resource "aws_vpc_security_group_ingress_rule" "node_ingress_from_cluster" {
  security_group_id = aws_security_group.node_shared.id
  description       = "Allow traffic from cluster security group"
  
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.cluster.id

  tags = {
    Name = "node-ingress-from-cluster"
  }
}

# Node Shared SG - Outbound: Allow all IPv4
resource "aws_vpc_security_group_egress_rule" "node_egress_all" {
  security_group_id = aws_security_group.node_shared.id
  description       = "Allow all outbound IPv4 traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "node-egress-all-ipv4"
  }
}

# ========================================
# Optional: Additional Node Security Group Rules
# ========================================

# SSH access to nodes (optional - controlled by variable)
#resource "aws_vpc_security_group_ingress_rule" "node_ssh" {
#  count = var.enable_ssh_access ? 1 : 0

#  security_group_id = aws_security_group.node_shared.id
#  description       = "Allow SSH access to worker nodes"
  
#  ip_protocol = "tcp"
#  from_port   = 22
#  to_port     = 22
#  cidr_ipv4   = var.ssh_access_cidr

#  tags = {
#    Name = "node-ssh-access"
#  }
#}
