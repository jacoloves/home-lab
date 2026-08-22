resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"

  content = join("\n", [
    "# このファイルは OpenTofu が生成する。直接編集しないこと。",
    "# 生成元: k8s/tofu/outputs.tf",
    yamlencode({
      all = {
        vars = {
          ansible_user = var.vm_username
        }
        children = {
          control_plane = {
            hosts = {
              for name, cfg in var.vm_nodes : name => { ansible_host = cfg.ip }
              if cfg.role == "control_plane"
            }
          }
          workers = {
            hosts = {
              for name, cfg in var.vm_nodes : name => { ansible_host = cfg.ip }
              if cfg.role == "worker"
            }
          }
        }
      }
    })
  ])
}

output "node_ips" {
  description = "作成した VM の名前と IP"
  value       = { for name, cfg in var.vm_nodes : name => cfg.ip }
}
