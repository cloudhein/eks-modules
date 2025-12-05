# 5) Helm release: deploy cluster-autoscaler (auto-discovery mode) 
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.cluster_autoscaler_chart_version # e.g. "9.49.0"

  # we use the SA we created (so helm must not create a new SA)
  values = [
    yamlencode({
      rbac = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.cluster_autoscaler.metadata[0].name
        }
      }
      autoDiscovery = {
        clusterName = var.cluster_name
      }
      awsRegion = var.region
      # recommended flags
      extraArgs = {
        v                               = "4" # verbosity
        expander                        = "least-waste"
        "balance-similar-node-groups"   = true
        "skip-nodes-with-local-storage" = false
        stderrthreshold                 = "info"
      }
    })
  ]

  depends_on = [
    kubernetes_service_account.cluster_autoscaler,
    aws_iam_role_policy_attachment.attach_ca_policy,
    aws_eks_access_policy_association.terraform_admin,
    aws_eks_node_group.private_nodes
  ]
}

#provider "helm" {
#  kubernetes = {
#    host                   = data.aws_eks_cluster.cluster.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.cluster.token
#  }
#}