output "Kubernetes_Nodegroups_status" {
  value = yandex_kubernetes_node_group.node_group.*.status
}
output "node_group_names" {
  value = [for i in range(var.vpc_zones_count) : "${var.cluster_name}-${var.vpc_zones[i]}-${i}"]
}
