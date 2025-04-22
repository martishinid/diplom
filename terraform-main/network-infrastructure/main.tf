#######################################
# СЕТЬ
#######################################
## Основная сеть
resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}
## Подсеть PUBLIC
## X шт в разных зонах
resource "yandex_vpc_subnet" "public" {
  count = length(var.subnet_public_cidr)

  name           = "${var.subnet_public_name}-${var.subnet_public_cidr[count.index].zone}-${count.index + 1}"
  zone           = var.subnet_public_cidr[count.index].zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.subnet_public_cidr[count.index].cidr
}

## Подсеть PRIVATE
## X шт в разных зонах
resource "yandex_vpc_subnet" "private" {
  count = length(var.subnet_private_cidr)

  name           = "${var.subnet_private_name}-${var.subnet_private_cidr[count.index].zone}-${count.index + 1}"
  zone           = var.subnet_private_cidr[count.index].zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.subnet_private_cidr[count.index].cidr
  #route_table_id = yandex_vpc_route_table.nat_route[count.index].id
}

#######################################
# NAT - ТАБЛИЦА МАРШРУТИЗАЦИИ
####################################### 
## Таблица маршрутизации и статический маршрут
## Всего X таблиц (по 1й на каждую PRIVATE подсеть)
resource "yandex_vpc_route_table" "nat_route" {
  count = var.vm_nat_enable == true ? length(var.subnet_private_cidr) : 0

  name       = "${var.route_table_name}-${var.subnet_private_cidr[count.index].zone}-${count.index + 1}"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = local.vm_nat_zone[var.subnet_private_cidr[count.index].zone].network_interface[0].ip_address
  }
}

#######################################
# NAT - ВМ NAT INSTANCE
#######################################
## Образ загрузочного диска
data "yandex_compute_image" "nat_boot" {
  count = var.vm_nat_enable == true ? 1 : 0

  family = var.vm_nat_os_family
}
## VM-NAT
resource "yandex_compute_instance" "nat_instance" {
  count = var.vm_nat_enable == true ? length(var.subnet_public_cidr) : 0

  name        = "${var.vm_nat_name}-${var.subnet_private_cidr[count.index].zone}-${count.index + 1}"
  hostname    = "${var.vm_nat_name}-${var.subnet_private_cidr[count.index].zone}-${count.index + 1}"
  platform_id = var.vms_resources["nat"].platform_id
  zone        = var.subnet_private_cidr[count.index].zone
  resources {
    cores         = var.vms_resources["nat"].cores
    memory        = var.vms_resources["nat"].memory
    core_fraction = var.vms_resources["nat"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_boot.0.id
      size     = var.vms_resources["nat"].hdd_size
      type     = var.vms_resources["nat"].hdd_type
    }
  }
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  scheduling_policy {
    preemptible = var.vms_resources["nat"].preemptible
  }

  network_interface {
    index     = 0
    subnet_id = local.public_net_zone[var.subnet_private_cidr[count.index].zone]
    nat       = var.vms_resources["nat"].enable_nat
  }

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}