# ---------------------------------------------------------
# 1. Remove "Default" status from the legacy gp2 class
# ---------------------------------------------------------
# EKS creates 'gp2' by default. We modify it to stop being the default
# so that our new 'gp3' class can take over.
resource "kubernetes_annotations" "disable_gp2_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  # Use force to overwrite the existing annotation managed by EKS
  force = true

  
  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_addon.ebs_csi_driver
  ]
}

# ---------------------------------------------------------
# 2. Create gp3 and make it the Default
# ---------------------------------------------------------
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  # Ensure we unset gp2 before setting gp3 as default to avoid conflict
  depends_on = [
    kubernetes_annotations.disable_gp2_default
  ]
}