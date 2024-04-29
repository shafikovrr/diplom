resource "local_file" "inventory" {
  content  = <<EOF

Host ${var.bastion_host_name}
  HostName ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}

Host ${var.web1_host_name}
  HostName ${yandex_compute_instance.web-host-1.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}
  
Host ${var.web2_host_name}
  HostName ${yandex_compute_instance.web-host-2.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host ${var.zabbix_host_name}
  HostName ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host ${var.kibana_host_name}
  HostName ${yandex_compute_instance.kibana.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host ${var.elasticsearch_host_name}
  HostName ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

EOF
  filename = "/home/adrin/.ssh/config"
}


# https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand
# https://andrdi.com/blog/terraform-ansible-provisioner.html
# https://discuss.hashicorp.com/t/dynamic-inventory-for-ansible-using-terraform/20411
# https://terraform-provider.yandexcloud.net/Resources/alb_load_balancer  
