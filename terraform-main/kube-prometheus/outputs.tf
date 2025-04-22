output "kube_prometheus_stack_name" {
  value = helm_release.kube_prometheus_stack.name
}

output "grafana_external_ip" {
  value = data.kubernetes_service.grafana.status.0.load_balancer.0.ingress.0.ip
  description = "External IP of Grafana Service"
}

