#######################################
# Yandex.cloud SECRET VARS
#######################################
## cloud id
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive   = true
}
## cloud-folder id
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
}
variable "service_account_id" {
  type        = string
  
}
#######################################
# Yandex.cloud DEFAULTS
#######################################
## default network zone (used in yandex_vpc_subnet) - 'ru-central1-a'
variable "default_zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
  default     = "ru-central1-a"
}
## default cidr
variable "default_cidr" {
  type        = string
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
  default     = "10.0.1.0/24"
}
## Number of zones
variable "vpc_zones_count" {
  type        = number
  description = "Number of zones for cluster"
  default     = 1
}
## List of zones
variable "vpc_zones" {
  type        = list(string)
  description = "List of zones (count must be equal to 'var.vpc_zones_count')"
  default     = ["ru-central1-a"]
}

#######################################
# Yandex.cloud NETWORK VARS
#######################################
## default network name
variable "vpc_name" {
  type        = string
  description = "VPC network"
  default     = "develop"
}
## default PUBLIC net name
variable "subnet_public_name" {
  type        = string
  description = "VPC public subnet name"
  default     = "public"
}
## default PUBLIC net cidr
variable "subnet_public_cidr" {
  type = list(object({
    zone : string,
    cidr : list(string)
  }))
  description = "VPC public cidr (count must be equal to 'var.vpc_zones_count') (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  default     = [{ zone : "ru-central1-a", cidr : ["10.1.1.0/24"] }]
}
## default PRIVATE net name
variable "subnet_private_name" {
  type        = string
  description = "VPC private subnet name"
  default     = "private"
}
## default PRIVATE net cidr
variable "subnet_private_cidr" {
  type = list(object({
    zone : string,
    cidr : list(string)
  }))
  description = "VPC private cidr (count must be equal to 'var.vpc_zones_count') (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  default     = [{ zone : "ru-central1-a", cidr : ["192.168.1.0/24"] }]
}

#######################################
# KUBERNETES CONFIG VARS
#######################################
## Virtual IP for check group
variable "loadbalancer_ext_ip" {
  type        = string
  description = "Virtual IP for check group"
  default     = null
}
## Virtual Port for check group
variable "loadbalancer_ext_port" {
  type        = number
  description = "Virtual Port for check group (default - 8888)"
  default     = 8888
}
## Inner Port for check group
variable "loadbalancer_int_port" {
  type        = number
  description = "Inner Port for check group (default - 6443)"
  default     = 6443
}
## Proxy liveness healthcheck port (for nginx)
variable "loadbalancer_healthcheck_port" {
  type        = number
  description = "Proxy liveness healthcheck port (for nginx)"
  default     = 8081
}

#######################################
# YANDEX APPLICATION LOAD BALANCER (ALB)
#######################################
## ALB External Ports for listenning (list)
variable "app_balancer_ports" {
  type        = list(number)
  description = "ALB External Ports for listenning (list(number))"
  default = [80]
}

#######################################
# VMs RESOURCES
#######################################
## VMs resources
## Node resources
variable "vms_resources" {
  type = map(object({
    platform_id : string,
    cores : number,
    memory : number,
    core_fraction : number,
    preemptible : bool,
    hdd_size : number,
    hdd_type : string,
    enable_nat : bool,
    ip_address : string,
  }))
  description = "{platform_id=<STRING>, cores=<NUMBER>, memory=<NUMBER>, core_fraction=<NUMBER>, vm_db_preemptible: <BOOL>, hdd_size=<NUMBER>, hdd_type=<STRING>, enable_nat: <BOOL>}"
  default = {
    "server" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 1
      core_fraction = 20
      preemptible   = true
      hdd_size      = 100
      hdd_type      = "network-hdd"
      enable_nat    = true,
      ip_address    = ""
    },
    "node" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
      preemptible   = true
      hdd_size      = 100
      hdd_type      = "network-hdd"
      enable_nat    = true,
      ip_address    = ""
    },
    "nat" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 1
      core_fraction = 20
      preemptible   = true
      hdd_size      = 100
      hdd_type      = "network-hdd"
      enable_nat    = true
      ip_address    = ""
    },
  }
}

#######################################
# SSH vars
#######################################
## ssh user
variable "vms_ssh_user" {
  type        = string
  description = "SSH user"
  default     = "user"
}
## ssh nat port for connecting via nat-instance
variable "vms_ssh_nat_port" {
  type        = number
  description = "ssh nat port for connecting via nat-instance (default - 22000)"
  default     = 22000
}
## ssh root-key
variable "vms_ssh_root_key" {
  type        = string
  description = "ssh-keygen -t ed25519"
}
## ssh private key path
## (without last '/')
variable "ssh_private_key_path" {
  type        = string
  description = "## ssh private key path (without last '/') (default - './.ssh')"
  default     = "./.ssh"
}
## ssh private key filename
variable "ssh_private_key_file" {
  type        = string
  description = "## ssh private key filename (default - 'id_rsa')"
  default     = "id_rsa"
}
#######################################
# Kubernetes vars
#######################################
variable "kube_namespace" {
  type        = string
  description = "K8s namespace"
  default     = "monitoring"
  }