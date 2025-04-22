#######################################
# МОДУЛЬ СОЗДАНИЯ СЕТЕВОЙ ИНФРАСТРУКТУРЫ
#######################################
module "net" {
  source = "./network-infrastructure"

  # Переменные модуля

  ## Каталог облака
  folder_id = var.folder_id

  ## Имя сети
  vpc_name = var.vpc_name

  ## Количество зон
  ## (default - 1)
  vpc_zones_count = var.vpc_zones_count # 3

  ## Названия зон (количество должно совпадать с vpc_zones_count)
  ## (default - ["ru-central1-a"])
  vpc_zones = var.vpc_zones

  ## Адреса Public-подсетей в привязке к зонам
  ## (в каждой зоне должно быть не менее одной сети)
  ## (default - [{zone: "ru-central1-a", cidr: ["10.1.1.0/24"]}])
  subnet_public_cidr = var.subnet_public_cidr

  ## Адреса Private-подсетей в привязке к зонам
  ## (в каждой зоне должно быть не менее одной сети)
  ## (default - [{zone: "ru-central1-a", cidr: ["192.168.1.0/24"]}])
  subnet_private_cidr = var.subnet_private_cidr

  ## Имя статической таблицы маршрутизации
  ## (default - 'nat-instance-route')
  route_table_name = "nat-route"

  ## Создание NAT-instance для PRIVATE-подсетей
  ## (подразумевает сождание отдельной ВМ)
  ## (default - TRUE)
  vm_nat_enable = false

  ## Имя ВМ Nat-instance
  ## (default - 'nat')
  vm_nat_name = "nat"

  ## VM NAT OS family 
  ## (default - 'nat-instance-ubuntu')
  vm_nat_os_family = "nat-instance-ubuntu"

  ## VMs resources
  ## using default
  vms_resources = var.vms_resources

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key
}


#######################################
# МОДУЛЬ УСТАНОВКИ KUBERNETES
#######################################
module "kubernetes-deploy" {
  source = "./kubernetes-deploy"

  # Переменные модуля



  ## Cluster name
  ## (default - 'cluster.local')
  #cluster_name = "cluster.local"

network_id = module.net.net.id
public_nets = module.net.public
vms_resources = var.vms_resources


vpc_zones = var.vpc_zones
service_account_id = var.service_account_id
  


vpc_zones_count = length(var.vpc_zones)

  ## Kubespray Ansible inventory relative path and file
  ## (default - './hosts.yml')
  ansible_host_file = "../ansible/hosts.yml"

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = var.ssh_private_key_path

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = var.ssh_private_key_file

  depends_on = [
    module.net,
  ]
}

#######################################
# МОДУЛЬ УСТАНОВКИ prometheus
#######################################
module "prometheus_stack" {
  source = "./kube-prometheus"
  kube_namespace = var.kube_namespace
  depends_on = [
    module.kubernetes-deploy
  ]



}
