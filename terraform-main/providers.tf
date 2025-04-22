terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
    local = {
      source  = "hashicorp/local"
      version = ">2.5.0"
    }
  }
}

provider "yandex" {
  #token = var.token
  service_account_key_file = "sa_key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

provider "local" {}

# provider "kubernetes" {
#   config_path = "${path.module}/../kubernetes/kubeconfig.yaml"

# }
provider "kubernetes" {
  config_path = "${path.module}/../kubernetes/kubeconfig.yaml"

}
provider "helm" {
  kubernetes {
    config_path = "${path.module}/../kubernetes/kubeconfig.yaml"
  }
}
