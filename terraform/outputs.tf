##############################################
# Вывод полученных ip (внутренних и внешних) #
##############################################

output "internal_ip_address_web-host_1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.ip_address
}
output "internal_ip_address_web-host_2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.ip_address
}
output "external_ip_address_web-host_1" {
  value = yandex_compute_instance.web-host-1.network_interface.0.nat_ip_address
}
output "external_ip_address_web-host_2" {
  value = yandex_compute_instance.web-host-2.network_interface.0.nat_ip_address
}
#output "yandex_vpc_load_balancer_address" {
#  value = yandex_alb_load_balancer.web-hosts-balancer.listener.0.endpoint.0.address.0.external_ipv4_address
#}
