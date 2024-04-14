
# Настройка хостов

## Веб-сервера

resource "yandex_compute_instance" "web-host-1" {
  name        = "web-host-1"
  description = "веб-сервер 1"
  hostname    = "web-host-1"
  zone        = var.zone_a
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-web-host-1.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
resource "yandex_compute_instance" "web-host-2" {
  name        = "web-host-2"
  description = "веб-сервер 2"
  hostname    = "web-host-2"
  zone        = var.zone_b
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-web-host-2.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# elasticsearch

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  description = "host elasticsearch"
  hostname    = "elasticsearch"
  zone        = var.zone_a
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.elasticsearch.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# zabbix

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  description = "host zabbix"
  hostname    = "zabbix"
  zone        = var.zone_b
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.zabbix.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

#kibana

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  description = "host kibanah"
  hostname    = "kibana"
  zone        = var.zone_b
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.kibana.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

#bastion

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  description = "host bastion"
  hostname    = "bastion"
  zone        = var.zone_d
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.bastion.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-d.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
