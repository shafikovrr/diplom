##############################################
# Вывод полученных ip (внутренних и внешних) #
##############################################

output "external_ip_bastion" {
  value = yandex_vpc_address.addr.external_ipv4_address.0.address
}

output "internal_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "internal_ip_address_web-host_1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.ip_address
}

output "external_ip_alb_load_balancer" {
  value = yandex_alb_load_balancer.web-hosts-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

output "internal_ip_address_web-host_2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.ip_address
}

output "external_ip_address_elasticsearch" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
} 
output "external_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}
output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
