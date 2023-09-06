# IMAGES:
# - ubuntu-2004-lts
# SUBNETS:
# - default-ru-central1-a
# - default-ru-central1-b
# - default-ru-central1-c
# DISK TYPES:
# - network-ssd
# - network-hdd
# - network-ssd-nonreplicated
# - network-ssd-io-m3

ssh_username  = "abegorov"
ssh_private_key = "D:/AppData/.ssh/amazon"
ssh_public_key  = "D:/AppData/.ssh/amazon.pub"
ssh_config_dir  = "D:/AppData/.ssh/yandex"
instances = [
  "yandex",
  #"yandex2",
  #"yandex3",
  #"yandex4",
]
instance_config = {
  "yandex" = {
    zone          = "ru-central1-b"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    disk_image    = "ubuntu-2004-lts"
    disk_size     = 20
    disk_type     = "network-hdd"
    subnet        = "default-ru-central1-b"
    nat           = true
  }
  "yandex2" = {
    zone          = "ru-central1-b"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    disk_image    = "ubuntu-2004-lts"
    disk_size     = 20
    disk_type     = "network-hdd"
    subnet        = "default-ru-central1-b"
    nat           = true
  }
  "yandex3" = {
    zone          = "ru-central1-b"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    disk_image    = "ubuntu-2004-lts"
    disk_size     = 20
    disk_type     = "network-hdd"
    subnet        = "default-ru-central1-b"
    nat           = true
  }
  "yandex4" = {
    zone          = "ru-central1-b"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    disk_image    = "ubuntu-2004-lts"
    disk_size     = 20
    disk_type     = "network-hdd"
    subnet        = "default-ru-central1-b"
    nat           = true
  }
}
