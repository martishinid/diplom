output "net" {
  value = {
    default_security_group_id = yandex_vpc_network.vpc.default_security_group_id
    id                        = yandex_vpc_network.vpc.id
    name                      = yandex_vpc_network.vpc.name
    subnet_ids                = yandex_vpc_network.vpc.subnet_ids
  }
}

output "public" {
  value = [for s in yandex_vpc_subnet.public : {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
  }]
}

output "public_ids" {
  value = { for s in yandex_vpc_subnet.public : s.id => {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
    }
  }
}

output "private" {
  value = [for s in yandex_vpc_subnet.private : {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
  }]
}

output "private_ids" {
  value = { for s in yandex_vpc_subnet.private : s.id => {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
    }
  }
}

output "route_table" {
  value = yandex_vpc_route_table.nat_route
}

output "vm_nat" {
  value = [for s in yandex_compute_instance.nat_instance : {
    name       = s.name,
    zone       = s.zone,
    network_id = s.network_interface[0].subnet_id
    id         = s.id,
    ip         = s.network_interface[0].ip_address,
    nat_ip     = s.network_interface[0].nat_ip_address,
    fqdn       = s.fqdn
  }]
}

output "vm_nat_zone" {
  value = { for k, s in local.vm_nat_zone : k => {
    name       = s.name,
    zone       = s.zone,
    network_id = s.network_interface[0].subnet_id
    id         = s.id,
    ip         = s.network_interface[0].ip_address,
    nat_ip     = s.network_interface[0].nat_ip_address,
    fqdn       = s.fqdn
  } }
}