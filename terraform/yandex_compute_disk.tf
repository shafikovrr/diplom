#######
# Настройка дисков
/* resource "yandex_compute_disk" "boot-disk-web-host-1" {
  name        = "disk-web-host-1"
  description = "диск для веб-сервера 1"
  type        = "network-hdd"
  zone        = var.zone_a
  size        = 10
  image_id    = var.image_id
}
resource "yandex_compute_disk" "boot-disk-web-host-2" {
  name        = "disk-web-host-2"
  description = "диск для веб-сервера 2"
  type        = "network-hdd"
  zone        = var.zone_b
  size        = 10
  image_id    = var.image_id
} */
resource "yandex_compute_disk" "zabbix" {
  name        = "zabbix"
  description = "диск для zabbix"
  type        = "network-hdd"
  zone        = var.zone_b
  size        = 10
  image_id    = var.image_id
}
/* resource "yandex_compute_disk" "elasticsearch" {
  name        = "elasticsearch"
  description = "диск для elasticsearch"
  type        = "network-hdd"
  zone        = var.zone_a
  size        = 10
  image_id    = var.image_id
}
resource "yandex_compute_disk" "kibana" {
  name        = "kibana"
  description = "диск для kibana"
  type        = "network-hdd"
  zone        = var.zone_b
  size        = 10
  image_id    = var.image_id
}
resource "yandex_compute_disk" "bastion" {
  name        = "bastion"
  description = "диск для bastion"
  type        = "network-hdd"
  zone        = var.zone_d
  size        = 10
  image_id    = var.image_id
} */
