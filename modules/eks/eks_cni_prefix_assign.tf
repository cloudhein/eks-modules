# ---------------------------------------------------------
# 3. VPC CNI (Prefix Delegation Config)
# ---------------------------------------------------------
# Defined separately because it needs custom ENV variables for Prefix Delegation

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"

  # Optional: Pin version if needed
  # addon_version = "v1.18.0-eksbuild.1" 

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    env = {
      # ✅ ENABLE THIS: Allows assigning /28 prefixes (16 IPs) instead of 1 IP per slot
      ENABLE_PREFIX_DELEGATION = "true"

      # Recommended: Keep one full block warm to speed up pod starts
      WARM_PREFIX_TARGET = "1"
    }
  })

  # Ensure cluster is ready before installing CNI
  depends_on = [
    aws_eks_cluster.eks
  ]
}