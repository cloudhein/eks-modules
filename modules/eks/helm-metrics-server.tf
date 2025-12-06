resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set = [
    {
      name  = "args[0]"
      value = "--kubelet-insecure-tls"
    }
  ]

    depends_on = [
    aws_iam_role_policy_attachment.attach_ca_policy,
    aws_eks_access_policy_association.terraform_admin,
    aws_eks_node_group.private_nodes
  ]
}