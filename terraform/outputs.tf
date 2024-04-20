##############################################
# Вывод полученных ip (внутренних и внешних) #
##############################################

output "external_ip_bastion" {
  value = yandex_vpc_address.addr.external_ipv4_address.0.address
}

output "internal_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "external_ip_address_web-host_1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.nat_ip_address
}

output "internal_ip_address_web-host_1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.ip_address
}

output "external_ip_address_web-host_2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.nat_ip_address
}

output "internal_ip_address_web-host_2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.ip_address
}
