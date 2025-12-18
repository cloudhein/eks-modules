# modules/karpenter/helm.tf
# Helm chart deployment for Karpenter

resource "helm_release" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = var.karpenter_namespace

  create_namespace = var.create_namespace_karpenter # Namespace should already exist

  values = [
    yamlencode({
      settings = {
        clusterName = var.cluster_name
        #clusterEndpoint = var.cluster_endpoint
        # ❌ REMOVE interruptionQueue - only needed if using SQS for spot interruption
        # interruptionQueue = var.cluster_name
      }

      serviceAccount = {
        name = "karpenter"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
        }
      }

      controller = {
        resources = {
          requests = {
            cpu    = var.controller_resources.requests.cpu
            memory = var.controller_resources.requests.memory
          }
          limits = {
            cpu    = var.controller_resources.limits.cpu
            memory = var.controller_resources.limits.memory
          }
        }
      }

      # ✅ CORRECTED: Node affinity to run Karpenter on stable node group
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  # Don't run on Karpenter-managed nodes
                  {
                    key      = "karpenter.sh/nodepool"
                    operator = "DoesNotExist"
                  },
                  # Run on stable node group
                  {
                    key      = "node-type"
                    operator = "In"
                    values   = ["stable"]
                  }
                ]
              }
            ]
          }
        }
        # Spread Karpenter pods across different nodes
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              topologyKey = "kubernetes.io/hostname"
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "karpenter"
                }
              }
            }
          ]
        }
      }

      # Additional settings
      replicas = var.karpenter_replicas
      logLevel = var.log_level

    })
  ]

  depends_on = [
    kubectl_manifest.karpenter_nodepool_crd,
    kubectl_manifest.karpenter_ec2nodeclass_crd,
    kubectl_manifest.karpenter_nodeclaim_crd,
    aws_eks_access_entry.karpenter_node,
    aws_eks_node_group.private_nodes
  ]
}