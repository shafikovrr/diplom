resource "local_file" "ip_zabbix_server_nginx" {
  content  = <<EOF
ip_zabbix_server: ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
EOF
  filename = "../ansible/nginx/vars/ip_var_zabbix_server.yml"
}

resource "local_file" "ip_zabbix_server_elasticsearch" {
  content  = <<EOF
ip_zabbix_server: ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
EOF
  filename = "../ansible/elasticsearch/vars/ip_var_zabbix_server.yml"
}

resource "local_file" "ip_zabbix_server_kibana" {
  content  = <<EOF
ip_zabbix_server: ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
ip_elasticsearch_server: ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}
ip_all_server: 0.0.0.0
EOF
  filename = "../ansible/kibana/vars/ip_var_zabbix_server.yml"
}

resource "local_file" "ip_vars_zabbix_agent" {
  content  = <<EOF
agent_web_host_1: ${yandex_compute_instance.web-host-1.network_interface.0.ip_address}
agent_web_host_2: ${yandex_compute_instance.web-host-2.network_interface.0.ip_address}
agent_elasticsearch: ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}
agent_kibana: ${yandex_compute_instance.kibana.network_interface.0.ip_address}
EOF
  filename = "../ansible/zabbix/vars/ip_var_zabbix_agent.yml"
}