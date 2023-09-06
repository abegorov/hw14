variable "ssh_username" {
  type = string
}
variable "ssh_private_key" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "ssh_config_dir" {
  type = string
}
variable "instances" {
  type = list(string)
}
variable "instance_config" {
  type = map(object({
    zone          = string
    cores         = number
    memory        = number
    core_fraction = number
    preemptible   = bool
    disk_image    = string
    disk_size     = number
    disk_type     = string
    subnet        = string
    nat           = bool
  }))
}
