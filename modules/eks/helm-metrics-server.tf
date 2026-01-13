resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    =  var.metrics_server_version

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls"
      ]

      # ✅ Deploy on System Node Group
      nodeSelector = {
        role = "system"
      }
      
      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
    })
  ]

  depends_on = [
    aws_eks_access_policy_association.terraform_admin,
    aws_eks_node_group.private_nodes
  ]
}