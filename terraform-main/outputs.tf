
output "Network" {
  value = {
    net : module.net.net,
    public : module.net.public,
    private : module.net.private
  }
}
output "kube_prometheus_stack_name" {
  value = module.prometheus_stack.kube_prometheus_stack_name
}

output "grafana_url" {
  value = "http://${module.prometheus_stack.grafana_external_ip}"
  description = "Grafana access URL"
}
