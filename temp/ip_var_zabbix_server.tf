resource "local_file" "ip_vars_zabbix_server" {
  content  = <<EOF
ip_zabbix_server: ${yandex_compute_instance.zabbix.network_interface.0.nat_ip_address}
EOF
  filename = "../ansible/nginx/vars/ip_var_zabbix_server.yml"
}

resource "local_file" "ip_vars_zabbix_agent" {
  content  = <<EOF
agent_web_host_1: ${yandex_compute_instance.web-host-1.network_interface.0.nat_ip_address}
agent_web_host_2: ${yandex_compute_instance.web-host-2.network_interface.0.nat_ip_address}
   
EOF
  filename = "../ansible/zabbix/vars/ip_var_zabbix_agent.yml"
}