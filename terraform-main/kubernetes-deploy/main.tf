
#######################################
# KUBERNETES - КЛЮЧИ ШИФРОВАНИЯ
#######################################
## Ключ Yandex Key Management Service для шифрования важной информации, 
## используется в KUBERNETES-кластере
resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}
## Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.service_account_id
  description        = "static access key for object storage"
}

#######################################
# KUBERNETES - КЛАСТЕР
#######################################
## Группа безопасности для Kubernetes
resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "my_diplom_cluster_sg"
  network_id = var.network_id

  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol       = "ANY"
    description    = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks = ["0.0.0.0/0"] #var.subnet_public_cidr
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol       = "ICMP"
    description    = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }
  egress {
    protocol       = "ANY"
    description    = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
## Кластер Kubernetes
resource "yandex_kubernetes_cluster" "regional_cluster" {
  name        = "dcluster"
  description = "Regional Kubernetes cluster"
  network_id  = var.network_id
  master {
    dynamic "master_location" {
      for_each = var.public_nets
      content {
        zone      = master_location.value.zone
        subnet_id = master_location.value.id
      }
    }
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    # для доступа снаружи ко всем мастерам
    public_ip = true

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }


}

#######################################
# KUBERNETES - ГРУППА УЗЛОВ
#######################################
## 3 группы в разных зонах доступности
## из 1 узла каждая с расширением до 2-х
resource "yandex_kubernetes_node_group" "node_group" {
  count = var.vpc_zones_count

  cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  name       = "${var.k8s_nodegroup_name}-${var.vpc_zones[count.index]}-${count.index}"
  # параметры масштабирования группы узлов
  scale_policy {
    auto_scale {
      min     = var.k8s_nodes_per_zone_min
      max     = var.k8s_nodes_per_zone_max
      initial = var.k8s_nodes_per_zone_min
    }
  }
  # шаблон параметров ВМ для узлов кластера
  instance_template {
    name        = "${var.k8s_nodegroup_name}-${var.vpc_zones[count.index]}-{instance.index}"
    platform_id = var.vms_resources["node"].platform_id
    resources {
      memory        = var.vms_resources["node"].memory
      cores         = var.vms_resources["node"].cores
      core_fraction = var.vms_resources["node"].core_fraction
    }
    boot_disk {
      size = var.vms_resources["node"].hdd_size
      type = var.vms_resources["node"].hdd_type
    }
    scheduling_policy {
      preemptible = var.vms_resources["node"].preemptible
    }
    network_interface {
      subnet_ids = [var.public_nets[count.index].id]
      nat        = var.vms_resources["node"].enable_nat
    }
    # тип контейнеров
    container_runtime {
      type = "containerd"
    }
    # данные о SSH доступе
    metadata = local.vms_metadata_public_image
  }

  allocation_policy {
    location {
      zone = var.public_nets[count.index].zone
    }
  }
  depends_on = [yandex_kubernetes_cluster.regional_cluster]
}

#######################################
# KUBECTL - НАСТРОЙКА ДОСТУПА К КЛАСТЕРУ
#######################################
## Создание конфигурационного файла
## из шаблона kubeconfig.tpl
resource "local_file" "kubeconfig" {
  filename = "${path.module}/../../kubernetes/kubeconfig.yaml"
  content = templatefile("${path.module}/../../kubernetes/kubeconfig.tpl", {
    endpoint       = yandex_kubernetes_cluster.regional_cluster.master[0].external_v4_endpoint
    cluster_ca     = base64encode(yandex_kubernetes_cluster.regional_cluster.master[0].cluster_ca_certificate)
    k8s_cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  })
}

