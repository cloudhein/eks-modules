# Get the current IAM identity running Terraform
#data "aws_caller_identity" "current" {}

# Grant cluster access to the Terraform IAM principal
resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

# Associate admin policy with the access entry
resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = data.aws_caller_identity.current.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.terraform_admin
  ]
}