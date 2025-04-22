locals {
  vms_metadata_linux_only = {
    # type=object({
    #   serial_port_enable: number,
    #   ssh_keys: list(string),
    # })
    # description = "{serial_port_enable=<NUMBER>, ssh_keys: LIST(STRING)}"
    #default = {    
    serial_port_enable = 1,
    ssh_keys           = tolist(["${var.vms_ssh_user}:${var.vms_ssh_root_key}"])
  }

  vms_metadata_public_image = {
    "user-data" : "#cloud-config\nusers:\n  - name: ${var.vms_ssh_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh_authorized_keys:\n      - ${var.vms_ssh_root_key}"
  }

  public_net_zone = { for s in yandex_vpc_subnet.public : s.zone => s.id }

  vm_nat_zone = { for s in yandex_compute_instance.nat_instance : s.zone => s }

}