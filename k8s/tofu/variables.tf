variable "proxmox_endpoint" {
  description = "Proxmox VE の API エンドポイント"
  type        = string
}

variable "proxmox_api_token" {
  description = "API トークン(形式: root@pam!<トークンID>=<シークレット>)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "VM を作成する Proxmox ノード名"
  type        = string
  default     = "proxmox_home"
}

variable "network_bridge" {
  description = "VM を接続するブリッジ"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "デフォルトゲートウェイ"
  type        = string
  default     = "192.168.3.1"
}

variable "dns_servers" {
  description = "VM に設定する DNS サーバ"
  type        = list(string)
  default     = ["192.168.3.11", "1.1.1.1"]
}

variable "dns_domain" {
  description = "検索ドメイン"
  type        = string
  default     = "shooonng.com"
}

variable "vm_username" {
  description = "cloud-init で作成するユーザ名"
  type        = string
  default     = "shotaro"
}

variable "ssh_public_key_path" {
  description = "VM に登録する SSH 公開鍵のパス"
  type        = string
}

variable "ubuntu_image_url" {
  description = "ベースとする Ubuntu cloud image の URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "enable_qemu_agent" {
  description = <<-EOT
    qemu-guest-agent との連携を有効にするか。
    cloud image には agent が入っていないため初回は false で作成し、
    Ansible で導入したあとに true へ切り替えて再適用する。
  EOT
  type        = bool
  default     = false
}

variable "vm_nodes" {
  description = "作成する VM の定義"
  type = map(object({
    vmid   = number
    role   = string
    ip     = string
    cores  = number
    memory = number
    disk   = number
  }))
}
