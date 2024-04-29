#bastion в зоне d

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  description = "host bastion"
  hostname    = var.bastion_host_name
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
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.secure-bastion-sg.id,
      yandex_vpc_security_group.internal-bastion-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./bastion.yml")}"
  }
  scheduling_policy {
    preemptible = false
  }
}

# Web-host-1 в зоне а
resource "yandex_compute_instance" "web-host-1" {
  name        = "web-host-1"
  description = "веб-сервер 1"
  hostname    = var.web1_host_name
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
    preemptible = false
  }
}

# Web-host-2 в зоне b
resource "yandex_compute_instance" "web-host-2" {
  name        = "web-host-2"
  description = "веб-сервер 2"
  hostname    = var.web2_host_name
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
    preemptible = false
  }
}

# elasticsearch

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  description = "host elasticsearch"
  hostname    = var.elasticsearch_host_name
  zone        = var.zone_a
  platform_id = var.platform
  resources {
    cores         = 4
    core_fraction = 20
    memory        = 4
  }
  boot_disk {
    disk_id = yandex_compute_disk.elasticsearch.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.bastion-internal-segment-1.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.internal-bastion-sg.id,
      yandex_vpc_security_group.elasticsearch-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = false
  }
}

# zabbix

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  description = "host zabbix"
  hostname    = var.zabbix_host_name
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
    security_group_ids = [
      yandex_vpc_security_group.zabbix-sg.id,
      yandex_vpc_security_group.internal-bastion-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = false
  }
}

#kibana

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  description = "host kibanah"
  hostname    = var.kibana_host_name
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
    security_group_ids = [
      yandex_vpc_security_group.internal-bastion-sg.id,
      yandex_vpc_security_group.kibana-sg.id
    ]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = false
  }
}

#https://yandex.cloud/ru/docs/compute/operations/disk-control/create-snapshot#create
#https://terraform-provider.yandexcloud.net/Resources/compute_snapshot_schedule

resource "yandex_compute_snapshot_schedule" "default" {
  name = "disk-snapshot"

  schedule_policy {
    expression = "@midnight"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "daily-snapshot"
    labels = {
      snapshot-label = "my-snapshot-label-value"
    }
  }

  disk_ids = [
    yandex_compute_disk.bastion.id,
    yandex_compute_disk.boot-disk-web-host-1.id,
    yandex_compute_disk.boot-disk-web-host-2.id,
    yandex_compute_disk.elasticsearch.id,
    yandex_compute_disk.zabbix.id,
    yandex_compute_disk.kibana.id
  ]
}
