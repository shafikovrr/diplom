#############################################
# Вывод полученных ip (внутренних и внешних) #
##############################################

output "external_ip_address_bast" {
  value = yandex_vpc_address.addr.external_ipv4_address.0.address
}

output "internal_ip_address_bast" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "internal_ip_address_web1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.ip_address
}

output "external_ip_address_alb1" {
  value = yandex_alb_load_balancer.web-hosts-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

output "internal_ip_address_web2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.ip_address
}

output "internal_ip_address_elas" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
} 
output "external_ip_address_zabb" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}
output "internal_ip_address_zabb" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}
output "external_ip_address_kiba" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
