## Fetch EKS cluster info from the resource you created
#data "aws_eks_cluster" "cluster" {
#  name = aws_eks_cluster.eks.name
#}

#data "aws_eks_cluster_auth" "cluster" {
#  name = aws_eks_cluster.eks.name
#}

## Configure the Kubernetes provider
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.cluster.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.cluster.token
#}

# Create the Kubernetes ServiceAccount for the ALB Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }
  }

  depends_on = [
    aws_eks_access_policy_association.terraform_admin,
    aws_eks_node_group.private_nodes
  ]
}
