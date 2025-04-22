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
      cores         = 4
      memory        = 8
      core_fraction = 20
      preemptible   = true
      hdd_size      = 60
      hdd_type      = "network-hdd"
      enable_nat    = true
      ip_address    = ""
    }
  }
}

#######################################
# SSH vars
#######################################
## ssh user
variable "vms_ssh_user" {
  type        = string
  description = "SSH user"
  default     = "gitlab"
}
## ssh nat port for connecting via nat-instance
variable "vms_ssh_nat_port" {
  type        = number
  description = "ssh nat port for connecting via nat-instance (default - 22000)"
  default     = 22
}
## ssh private key path
## (without last '/')
variable "ssh_private_key_path" {
  type        = string
  description = "## ssh private key path (without last '/') (default - './.ssh')"
  default     = "/home/user/.ssh"
}
## ssh private key filename
variable "ssh_private_key_file" {
  type        = string
  description = "## ssh private key filename (default - 'id_rsa')"
  default     = "id_ed25519"
}
## ssh public key (public key path)
variable "vms_ssh_root_key" {
  type        = string
  description = "Path to the public SSH key (e.g., /home/user/.ssh/id_ed25519.pub)"
  default     = "/home/user/.ssh/id_ed25519.pub"
}
