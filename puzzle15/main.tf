locals {
  ssh_username    = "abegorov"
  ssh_private_key = "D:/AppData/.ssh/amazon"
  ssh_public_key  = "D:/AppData/.ssh/amazon.pub"
  ssh_config_dir  = "D:/AppData/.ssh/yandex"
  build_hostname  = "hw14-build"
  app_hostname    = "hw14-app"
}

variable "yc_token" {
  type      = string
  sensitive = true
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.97"
}

provider "yandex" {
  zone = "ru-central1-b"
}

data "yandex_compute_image" "image" {
  family = "ubuntu-2004-lts"
}

data "yandex_vpc_subnet" "subnet" {
  name = "default-ru-central1-b"
}

data "yandex_container_registry" "registry" {
  name = "abegorov"
}

resource "yandex_compute_instance" "hw14_build" {
  name     = local.build_hostname
  hostname = local.build_hostname
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.subnet.subnet_id
    nat       = true
  }

  metadata = {
    install-unified-agent = 0
    ssh-keys = "${local.ssh_username}:${file(local.ssh_public_key)}"
    user-data = <<-EOT
      #cloud-config
      datasource:
        Ec2:
          strict_id: false
      ssh_pwauth: no
      users:
        - name: ${local.ssh_username}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${file(local.ssh_public_key)}
      runcmd: []
      EOT
  }

  connection {
      type        = "ssh"
      user        = local.ssh_username
      host        = yandex_compute_instance.hw14_build.network_interface.0.nat_ip_address
      private_key = file(local.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -qq update",
      "sudo apt -qq install --yes docker.io",
      "sudo mkdir /build",
      "cd /build",
      <<-EOT
        cat <<"EOF" | sudo tee Dockerfile > /dev/null
        ${file("${path.module}/Dockerfile")}
        EOF
      EOT
      ,
      "sudo docker build . -t cr.yandex/${data.yandex_container_registry.registry.registry_id}/puzzle15:latest"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker login --username iam --password ${var.yc_token} cr.yandex"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker push cr.yandex/${data.yandex_container_registry.registry.registry_id}/puzzle15:latest"
    ]
  }
}

resource "yandex_compute_instance" "hw14_app" {
  depends_on = [ yandex_compute_instance.hw14_build ]

  name     = local.app_hostname
  hostname = local.app_hostname
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.subnet.subnet_id
    nat       = true
  }

  metadata = {
    install-unified-agent = 0
    ssh-keys = "${local.ssh_username}:${file(local.ssh_public_key)}"
    user-data = <<-EOT
      #cloud-config
      datasource:
        Ec2:
          strict_id: false
      ssh_pwauth: no
      users:
        - name: ${local.ssh_username}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${file(local.ssh_public_key)}
      runcmd: []
      EOT
  }

  connection {
      type        = "ssh"
      user        = local.ssh_username
      host        = yandex_compute_instance.hw14_app.network_interface.0.nat_ip_address
      private_key = file(local.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -qq update",
      "sudo apt -qq install --yes docker.io"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker login --username iam --password ${var.yc_token} cr.yandex"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run --name puzzle15 --restart=on-failure --detach --publish 80:8080 cr.yandex/${data.yandex_container_registry.registry.registry_id}/puzzle15:latest"
    ]
  }
}

output "app_address" {
  value = "http://${yandex_compute_instance.hw14_app.network_interface.0.nat_ip_address}/puzzle15/"
}
