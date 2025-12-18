# modules/eks/main.tf
# Main Karpenter resources - tagging and configuration

##############################
# Tag Subnets for Karpenter Discovery
##############################
resource "aws_ec2_tag" "subnet_tags" {
  count = length(var.private_subnet_ids)

  resource_id = var.private_subnet_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name

  depends_on = [
    aws_eks_node_group.private_nodes
  ]
}


##############################
# Karpenter CRDs
##############################
data "http" "karpenter_nodepool_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodepools.yaml"

  request_headers = {
    Accept = "application/x-yaml"
  }
}

resource "kubectl_manifest" "karpenter_nodepool_crd" {
  yaml_body = data.http.karpenter_nodepool_crd.response_body

  depends_on = [
    aws_iam_role.karpenter_node,
    aws_iam_role.karpenter_controller,
    aws_eks_node_group.private_nodes
  ]
}

# Fetch EC2NodeClass CRD from GitHub
data "http" "karpenter_ec2nodeclass_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"

  request_headers = {
    Accept = "application/x-yaml"
  }
}

resource "kubectl_manifest" "karpenter_ec2nodeclass_crd" {
  yaml_body = data.http.karpenter_ec2nodeclass_crd.response_body

  depends_on = [
    aws_iam_role.karpenter_node,
    aws_iam_role.karpenter_controller,
    aws_eks_node_group.private_nodes
  ]
}

# Fetch NodeClaim CRD from GitHub
data "http" "karpenter_nodeclaim_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"

  request_headers = {
    Accept = "application/x-yaml"
  }
}


resource "kubectl_manifest" "karpenter_nodeclaim_crd" {
  yaml_body = data.http.karpenter_nodeclaim_crd.response_body

  depends_on = [
    aws_iam_role.karpenter_node,
    aws_iam_role.karpenter_controller,
    aws_eks_node_group.private_nodes
  ]
}