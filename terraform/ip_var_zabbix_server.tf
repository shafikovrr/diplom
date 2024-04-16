resource "local_file" "ip_vars_zabbix_server" {
  content  = <<EOF
ip_vars_ansibl=${yandex_compute_instance.zabbix.network_interface.0.nat_ip_address}
EOF
  filename = "../ansible/nginx/vars/ip_var_zabbix_server.yml"
}
