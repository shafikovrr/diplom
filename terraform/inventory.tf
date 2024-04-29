resource "local_file" "inventory" {
  content  = <<EOF

Host ${var.bastion_host_name}
  HostName ${yandex_vpc_address.addr.external_ipv4_address.0.address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}

Host web_server_1.ru-central1.internal
  HostName ${yandex_compute_instance.web-host-1.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}
  
Host web_server_2.ru-central1.internal
  HostName ${yandex_compute_instance.web-host-2.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host zabbix.ru-central1.internal
  HostName ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host kibana.ru-central1.internal
  HostName ${yandex_compute_instance.kibana.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.bastion_host_name}

Host elasticsearch.ru-central1.internal
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
