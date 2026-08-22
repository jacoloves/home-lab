data "proxmox_virtual_environment_nodes" "available" {}

output "nodes" {
  description = ""
  value       = data.proxmox_virtual_environment_nodes.available.names
}
