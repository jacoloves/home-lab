terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
