resource "local_file" "inventory" {
  content  = <<EOF
[all:children]
zabbix

[zabbix]
${yandex_compute_instance.zabbix.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

EOF
  filename = "../ansible/hosts"
}

# https://andrdi.com/blog/terraform-ansible-provisioner.html
# https://discuss.hashicorp.com/t/dynamic-inventory-for-ansible-using-terraform/20411
# https://terraform-provider.yandexcloud.net/Resources/alb_load_balancer  
#The external_ipv4_address block supports:
# address - (Optional) Provided by the client or computed automatically.
