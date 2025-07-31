
##### grant required EBS CSI permission for stateful applications
resource "aws_iam_role" "ebs_csi_controller" {
  name               = "${var.cluster_name}-AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.ebs_assume_role_policy.json
}

##### trust relationship policy for ebs csi driver
data "aws_iam_policy_document" "ebs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      # switch from module.eks.oidc_provider_arn → your OIDC provider resource
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

##### attach with required policy to ebs csi driver
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_controller.name
}

##### associate an IAM OIDC provider for your EKS cluster
resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_issuer_cert.certificates[0].sha1_fingerprint]
}

##### (you’ll need the TLS data source for the thumbprint)
data "tls_certificate" "eks_issuer_cert" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
