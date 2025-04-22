#######################################
# KUBERNETES - prometheus
#######################################
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = var.kube_namespace
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.0"

  values = [
    file("${path.module}/kube-prometheus-values.yaml")
  ]
}
data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = var.kube_namespace
  }
}
