packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  vm_id                = 9001
  vm_name              = "ubuntu-2404-template"
  template_description = "Built with Packer"

  iso_file    = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
  unmount_iso = true

  qemu_agent      = true
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
    discard      = true
    ssd          = true
  }

  cores  = 2
  memory = 2048

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot_wait          = "10s"
  boot_keygroup_interval = "150ms"   # デフォルトより遅くして取りこぼし防止

  boot_command = [
    "<wait5s>",
    "c<wait3s>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait1s><enter><wait3s>",
    "initrd /casper/initrd<wait1s><enter><wait3s>",
    "boot<wait1s><enter>"
  ]
  boot      = "c"
  boot_wait = "10s"

  http_directory = "http"

  ssh_username = "ubuntu"
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting cloud-init...'; sleep 2; done",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y install qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      # ★ クローン時に再生成させるためのクリーン処理
      "sudo cloud-init clean --logs --machine-id",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo apt-get clean"
    ]
  }
}
