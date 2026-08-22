variable "proxmox_endpoint" {
  description = "Proxmox VE の API エンドポイント"
  type        = string
}

variable "proxmox_apit_token" {
  description = "API トークン(形式: root@pam!<トークンID>=<シークレット>)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "VM を作成する Proxmox ノード名"
  type        = string
  default     = "proxmox_home"
}
