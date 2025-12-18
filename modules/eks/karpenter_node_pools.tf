# modules/eks/nodepool.tf
# Default NodePool and EC2NodeClass for Karpenter

##############################
# EC2NodeClass
##############################
resource "kubectl_manifest" "ec2nodeclass_default" {
  count = var.create_default_nodepool ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = var.default_nodepool_name
    }
    spec = {
      role = aws_iam_role.karpenter_node.name

      amiSelectorTerms = [
        {
          alias = var.ami_family
        }
      ]

      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]

      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]

      userData = var.user_data != "" ? var.user_data : null

      tags = merge(
        var.tags,
        var.nodepool_tags,
        {
          "karpenter.sh/discovery" = var.cluster_name
        }
      )

      blockDeviceMappings = var.block_device_mappings

      metadataOptions = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 2
        httpTokens              = "required"
      }
    }
  })

  depends_on = [
    aws_eks_node_group.private_nodes,
    helm_release.karpenter,
    kubectl_manifest.ec2nodeclass_default,
    kubectl_manifest.karpenter_nodepool_crd,
    kubectl_manifest.karpenter_ec2nodeclass_crd
  ]
}

##############################
# NodePool
##############################
resource "kubectl_manifest" "nodepool_default" {
  count = var.create_default_nodepool ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = var.default_nodepool_name
    }
    spec = {
      template = {
        spec = {
          requirements = var.nodepool_requirements

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = var.default_nodepool_name
          }

          expireAfter = var.node_expire_after

          #taints = var.nodepool_taints
        }
      }

      limits = var.nodepool_limits

      disruption = {
        consolidationPolicy = var.consolidation_policy
        consolidateAfter    = var.consolidate_after

        #budgets = var.disruption_budgets
      }

      weight = var.nodepool_weight
    }
  })

  depends_on = [
    helm_release.karpenter,
    aws_eks_node_group.private_nodes,
    kubectl_manifest.ec2nodeclass_default,
    kubectl_manifest.karpenter_nodepool_crd,
    kubectl_manifest.karpenter_ec2nodeclass_crd
  ]
}