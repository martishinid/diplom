#######################################
# ANSIBLE VARS
#######################################
## Kubespray Ansible inventory relative path and file
variable "ansible_host_file" {
  type        = string
  description = "Ansible inventory relative path and file"
  default     = "./hosts.yml"
}

#######################################
# KUBERNETES CONFIG VARS
#######################################
## Cluster name
variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "cluster-diplom"
}
variable "k8s_nodegroup_name" {
  type        = string
  description = "Kubernetes nodes group name"
  default     = "node-group"
}
variable "vpc_zones" {
  type        = list(string)
  description = "List of zones (count must be equal to 'var.vpc_zones_count')"
  default     = ["ru-central1-a"]
}
## Kubernetes Min number of Nodes per zone
variable "k8s_nodes_per_zone_min" {
  type        = number
  description = "Kubernetes Min number of Nodes per zone"
  default     = 1
}
## Kubernetes Max number of Nodes per zone
variable "k8s_nodes_per_zone_max" {
  type        = number
  description = "Kubernetes Max number of Nodes per zone"
  default     = 2
}
variable "service_account_id" {
  type        = string
  
}
variable "network_id" {
  type        = string
  
}
variable "public_nets" {
  type        = list(object({
  
    name : string,
    zone : string,
    cidr : string,
    id   : string

  }))
}


variable "vpc_zones_count" {
  type        = number
  description = "Number of zones for cluster"
  default     = 1
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
## Node name
variable "k8s_node_name" {
  type        = string
  description = "K8s node name"
  default     = "node"
}

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
}



