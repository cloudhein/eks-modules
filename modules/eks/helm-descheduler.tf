# resource "helm_release" "descheduler" {
#   name       = "descheduler"
#   repository = "https://kubernetes-sigs.github.io/descheduler/"
#   chart      = "descheduler"
#   version    = var.descheduler_version
#   namespace  = "kube-system"
#
#   values = [
#     yamlencode({
#       # Run as a CronJob every 3 minutes to check node health
#       kind = "CronJob"
#       schedule = "*/3 * * * *"
#
#       # ✅ Resource requests optimized for c7i-flex.large system node
#       # Keeping these low ensures it schedules easily alongside Karpenter/CoreDNS
#       resources = {
#         requests = {
#           cpu    = "50m"
#           memory = "128Mi"
#         }
#         limits = {
#           cpu    = "100m"
#           memory = "256Mi"
#         }
#       }
#
#       deschedulerPolicy = {
#         profiles = [
#           {
#             name = "production-profile"
#             pluginConfig = [
#               {
#                 # ✅ STRATEGY: LowNodeUtilization
#                 # Goal: Evict pods from nodes that are "Too Full" (High Utilization)
#                 # to nodes that are "Empty enough" (Low Utilization).
#                 # If no empty nodes exist, Karpenter will see the Pending pods and create one.
#                 name = "LowNodeUtilization"
#                 args = {
#                   thresholds = {
#                     # "Target" thresholds: Nodes with usage BELOW this are considered "Underutilized"
#                     # and valid targets for rescheduling.
#                     "memory" = 50
#                     "cpu"    = 50
#                     "pods"   = 50
#                   }
#                   targetThresholds = {
#                     # "Source" thresholds: Nodes with usage ABOVE this are "Overutilized".
#                     # Pods will be evicted from these nodes.
#                     "memory" = 80 # Evict if Memory > 80%
#                     "cpu"    = 85 # Evict if CPU > 85%
#                     "pods"   = 85
#                   }
#                 }
#               }
#             ]
#
#             plugins = {
#               balance = {
#                 enabled = [
#                   "LowNodeUtilization"
#                 ]
#               }
#               # deschedule plugins are commented out in your request
#             }
#           }
#         ]
#       }
#
#       # Run on your System Node Group (so it doesn't get evicted itself!)
#       nodeSelector = {
#         role = "system"
#       }
#       tolerations = [
#         {
#           key      = "CriticalAddonsOnly"
#           operator = "Exists"
#           effect   = "NoSchedule"
#         }
#       ]
#     })
#   ]
#
#   depends_on = [
#     aws_eks_node_group.karpenter_system_nodes
#   ]
# }
