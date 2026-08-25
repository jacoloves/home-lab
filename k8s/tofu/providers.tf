provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token

  insecure = true

  ssh {
    # ssh-agent 依存だとエージェントが空のときに apply が失敗するため、
    # 鍵ファイルを直接指定する。パスは terraform.tfvars(gitignore 対象)に置く。
    agent       = false
    username    = "root"
    private_key = file(pathexpand(var.proxmox_ssh_private_key_path))
  }
}
