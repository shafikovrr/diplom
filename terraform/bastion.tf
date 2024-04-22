#bastion в зоне d

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  description = "host bastion"
  hostname    = "bastion-host"
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
    subnet_id      = yandex_vpc_subnet.bastion-external-segment.id
    nat            = true
    nat_ip_address = yandex_vpc_address.addr.external_ipv4_address[0].address
    ip_address     = "192.168.10.254"
    security_group_ids = [
      yandex_vpc_security_group.secure-bastion-sg.id,
      yandex_vpc_security_group.internal-bastion-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./bastion.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# Web-host-1 в зоне а
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
    subnet_id = yandex_vpc_subnet.bastion-internal-segment-1.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.internal-bastion-sg.id,
      yandex_vpc_security_group.webserver-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# Web-host-2 в зоне b
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
    subnet_id = yandex_vpc_subnet.bastion-internal-segment-2.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.internal-bastion-sg.id,
      yandex_vpc_security_group.webserver-sg.id
    ]
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
    subnet_id = yandex_vpc_subnet.bastion-internal-segment-1.id
    nat       = false
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
  zone        = var.zone_d
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
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
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
  zone        = var.zone_d
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
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
