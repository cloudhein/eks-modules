##############################
# Fetch the IAM policy document from the AWS Load Balancer Controller repository
##############################
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json"
}

# Create the IAM policy
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy-Ingress"
  policy = data.http.iam_policy.response_body
}

# Get the current AWS account ID (if you need it elsewhere)
data "aws_caller_identity" "current" {}

##############################
# Trust relationship policy for ALB Controller
##############################
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"
      # point at your EKS cluster OIDC provider resource
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      # service account in kube-system namespace
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# Create the IAM role for ALB Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${var.cluster_name}-AWSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the managed policy to the new role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}
