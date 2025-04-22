# SSH-ключ
data "local_file" "ssh_key" {
  filename = var.vms_ssh_root_key
}

# Использование существующей сети
data "yandex_vpc_network" "existing" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.subnet_public_name
  zone           = var.subnet_public_cidr[0].zone
  network_id     = data.yandex_vpc_network.existing.id
  v4_cidr_blocks = var.subnet_public_cidr[0].cidr
}

# GitLab VM
resource "yandex_compute_instance" "gitlab" {
  name        = "gitlab"
  platform_id = var.vms_resources["server"].platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources["server"].cores
    memory        = var.vms_resources["server"].memory
    core_fraction = var.vms_resources["server"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd84b1mojb8650b9luqd" # Ubuntu 24.04 LTS
      size     = var.vms_resources["server"].hdd_size
      type     = var.vms_resources["server"].hdd_type
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = var.vms_resources["server"].enable_nat
    ip_address = var.vms_resources["server"].ip_address != "" ? var.vms_resources["server"].ip_address : null
  }

  metadata = {
    ssh-keys  = "${var.vms_ssh_user}:${data.local_file.ssh_key.content}"
    user-data = file("${path.module}/cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = var.vms_resources["server"].preemptible
  }

  # Создание директории перед копированием
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.vms_ssh_user}/gitlab"
    ]

    connection {
      type        = "ssh"
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      host        = self.network_interface[0].nat_ip_address
      port        = var.vms_ssh_nat_port
    }
  }

  # Копирование docker-compose.yml без использования шаблона
  provisioner "remote-exec" {
    inline = [
      "cat > /home/${var.vms_ssh_user}/gitlab/docker-compose.yml <<EOF",
      "version: '3.8'",
      "services:",
      "  gitlab:",
      "    image: gitlab/gitlab-ce:16.11.0-ce.0",
      "    hostname: 'gitlab.local'",
      "    restart: always",
      "    environment:",
      "      GITLAB_ROOT_PASSWORD: 'qwe123!@#'",
      "      GITLAB_OMNIBUS_CONFIG: |",
      "        external_url 'http://${self.network_interface[0].nat_ip_address}'",
      "        gitlab_rails['time_zone'] = 'UTC'",
      "    ports:",
      "      - '80:80'",
      "      - '443:443'",
      "      - '2222:22'",
      "    volumes:",
      "      - './config:/etc/gitlab'",
      "      - './logs:/var/log/gitlab'",
      "      - './data:/var/opt/gitlab'",
      "    shm_size: '256m'",
      "EOF"
    ]

    connection {
      type        = "ssh"
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      host        = self.network_interface[0].nat_ip_address
      port        = var.vms_ssh_nat_port
    }
  }

  # Установка Docker и Docker Compose
  provisioner "remote-exec" {
    inline = [
    "sudo apt-get update -y",
    # Установка зависимостей
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      
      # Добавление официального GPG ключа Docker
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      
      # Настройка репозитория Docker
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      
      # Установка Docker
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      
      # Установка Docker Compose V2
      "sudo mkdir -p /usr/local/lib/docker/cli-plugins",
      "sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose",
      "sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose",
      "docker --version",
      "docker compose version",
      "sudo systemctl enable --now docker",
      "sudo usermod -aG docker ${var.vms_ssh_user}",
      "mkdir -p ~/gitlab/config ~/gitlab/logs ~/gitlab/data",
      "cd ~/gitlab && docker compose up -d",
      "timeout 300 bash -c 'while ! docker logs gitlab 2>&1 | grep -q \"gitlab Reconfigured!\"; do sleep 10; echo \"Waiting for GitLab to start...\"; done'",
    ]

    connection {
      type        = "ssh"
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      host        = self.network_interface[0].nat_ip_address
      port        = var.vms_ssh_nat_port
    }
  }

  # Копирование пароля на локальную машину
  provisioner "file" {
    source      = "/home/${var.vms_ssh_user}/gitlab_root_password.txt"
    destination = "${path.module}/.gitlab_root_password.txt"

    connection {
      type        = "ssh"
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      host        = self.network_interface[0].nat_ip_address
      port        = var.vms_ssh_nat_port
    }
  }
}
