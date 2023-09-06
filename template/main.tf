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
  for_each = toset(var.instances)

  family = var.instance_config[each.key].disk_image
}

data "yandex_vpc_subnet" "subnet" {
  for_each = toset(var.instances)

  name = var.instance_config[each.key].subnet
}

resource "yandex_compute_instance" "instance" {
  for_each = toset(var.instances)

  name     = each.key
  hostname = each.key
  zone     = var.instance_config[each.key].zone

  resources {
    cores  = var.instance_config[each.key].cores
    memory = var.instance_config[each.key].memory
    core_fraction = var.instance_config[each.key].core_fraction
  }

  scheduling_policy {
    preemptible = var.instance_config[each.key].preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image[each.key].id
      size     = var.instance_config[each.key].disk_size
      type     = var.instance_config[each.key].disk_type
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.subnet[each.key].subnet_id
    nat       = var.instance_config[each.key].nat
  }

  metadata = {
    install-unified-agent = 0
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
    user-data = <<-EOT
      #cloud-config
      datasource:
        Ec2:
          strict_id: false
      ssh_pwauth: no
      users:
        - name: ${var.ssh_username}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${file(var.ssh_public_key)}
      runcmd: []
      EOT
  }
}

resource "local_file" "ssh_config" {
  for_each = toset(var.instances)

  filename = "${var.ssh_config_dir}/${each.key}"
  content  = <<-EOT
    Host ${each.key}
        HostName ${yandex_compute_instance.instance[each.key].network_interface.0.nat_ip_address}
        User ${var.ssh_username}
        IdentityFile ${var.ssh_private_key}
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    EOT
}
