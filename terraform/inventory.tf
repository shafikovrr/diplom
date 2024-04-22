resource "local_file" "inventory" {
  content  = <<EOF

Host ${var.proxy_jump}
  HostName ${yandex_vpc_address.addr.external_ipv4_address.0.address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}

Host web_server_1
  HostName ${yandex_compute_instance.web-host-1.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.proxy_jump}
  
Host web_server_2
  HostName ${yandex_compute_instance.web-host-2.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.proxy_jump}

Host zabbix
  HostName ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.proxy_jump}

Host kibana
  HostName ${yandex_compute_instance.kibana.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.proxy_jump}

Host elasticsearch
  HostName ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}
  User ${var.ssh_host_user}
  Port ${var.ssh_port}
  IdentityFile ${var.ssh_bastion}
  ProxyJump ${var.proxy_jump}

EOF
  filename = "/home/adrin/.ssh/config"
}


#ansible_ssh_user=${var.ssh_host_user} 
#ansible_ssh_private_key_file=${var.ssh_bastion}
#https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand

# https://andrdi.com/blog/terraform-ansible-provisioner.html
# https://discuss.hashicorp.com/t/dynamic-inventory-for-ansible-using-terraform/20411
# https://terraform-provider.yandexcloud.net/Resources/alb_load_balancer  
#The external_ipv4_address block supports:
# address - (Optional) Provided by the client or computed automatically.


#resource "local_file" "inventory" {
#  content  = <<EOF
#[all:children]
#webservers
#elasticsearch
#zabbix
#kibana
#bastion

#[webservers:children]
#web_host_1
#web_host_2

#[web_host_1]
#${yandex_compute_instance.web-host-1.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[web_host_2]
#${yandex_compute_instance.web-host-2.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[elasticsearch]
#${yandex_compute_instance.elasticsearch.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[zabbix]
#${yandex_compute_instance.zabbix.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[kibana]
#${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[bastion]
#${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} ansible_ssh_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_folder}

#[load_balancer_address]
#${yandex_alb_load_balancer.web-hosts-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}

#EOF
#  filename = "../ansible/hosts"
#}

