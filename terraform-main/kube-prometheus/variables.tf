variable "kube_namespace" {
  type        = string
  default     = "monitoring"
  description = "Namespace where Prometheus stack will be installed"
}
