variable "proxmox_url" {
  type    = string
  default = "https://192.168.3.100:8006/api2/json"
}
variable "proxmox_username" {
  type    = string
  default = "packer@pve!packer-token"
}
variable "proxmox_token" {
  type      = string
  sensitive = true
}
variable "proxmox_node" {
  type    = string
  default = "proxmox-home"
}
variable "ssh_password" {
  type      = string
  sensitive = true
}
