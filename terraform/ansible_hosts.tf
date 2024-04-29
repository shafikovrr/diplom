resource "local_file" "hosts" {
  content  = <<EOF

[bastion]
${var.bastion_host_name}

[webservers]
${var.web1_host_name}
${var.web2_host_name}

[elasticsearch]
${var.elasticsearch_host_name}

[kibana]
${var.kibana_host_name}

[zabbix]
${var.zabbix_host_name}

EOF
  filename = "/home/adrin/diplom/ansible/hosts"
}
