#  1) IAM policy for Cluster Autoscaler
# minimally-privileged-ish policy used widely (adjust resource conditions for least privilege)
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "${var.cluster_name}-cluster-autoscaler-policy"
  description = "Policy for Kubernetes Cluster Autoscaler to manage autoscaling groups"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled" : "true",
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : "*"
      }
    ]
  })

}

# 2) IAM Role for the Cluster Autoscaler ServiceAccount (IRSA)
data "aws_iam_policy_document" "ca_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test = "StringEquals"
      # the OIDC issuer host (without https) + :sub should equal this SA's subject
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.cluster_name}-cluster-autoscaler-role"
  assume_role_policy = data.aws_iam_policy_document.ca_assume.json
}

resource "aws_iam_role_policy_attachment" "attach_ca_policy" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

# 4) Kubernetes service account (annotated for IRSA) 
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
    labels = {
      "app.kubernetes.io/name" = "cluster-autoscaler"
    }
  }
}