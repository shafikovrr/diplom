# https://yandex.cloud/ru/docs/tutorials/routing/bastion
# Внешняя сеть и подсеть

# Внешняя сеть (external_bastion_vpc)
resource "yandex_vpc_network" "network" {
  name = "network"
}

# Подсеть "внешней сети" (external_bastion_vpc_subnet)
resource "yandex_vpc_subnet" "bastion-external-segment" {
  name           = "bastion-external-segment"
  zone           = var.zone_d
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Подсеть "внутренней сети" (internal_bastion_vpc_subnet)
resource "yandex_vpc_subnet" "bastion-internal-segment-1" {
  name           = "bastion-internal-segment-1"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

# Подсеть "внутренней сети" (internal_bastion_vpc_subnet)
resource "yandex_vpc_subnet" "bastion-internal-segment-2" {
  name           = "bastion-internal-segment-2"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Группа безопасности бастионного хоста (только входящий трафик)
resource "yandex_vpc_security_group" "secure-bastion-sg" {
  name       = "secure-bastion-sg"
  network_id = yandex_vpc_network.network.id
  ingress { #входящий
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Группа безопасности для внутренних хостов (входящий и исходящий трафик)
resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name       = "internal-bastion-sg"
  network_id = yandex_vpc_network.network.id
  ingress { #входящий
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["172.16.16.254/32"]
  }
  egress {
    protocol          = "TCP"
    port              = 22
    predefined_target = "self_security_group"
  }
}

# Резервирование ip адреса bastion
resource "yandex_vpc_address" "addr" {
  name = "Bastion ip address"
  external_ipv4_address {
    zone_id = var.zone_b
  }
}
# Диск для bastion
resource "yandex_compute_disk" "bastion" {
  name     = "bastion"
  type     = "network-hdd"
  zone     = var.zone_b
  size     = 10
  image_id = var.bastion_image_id
}

#bastion

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  description = "host bastion"
  hostname    = "bastion-host"
  zone        = var.zone_b
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
    subnet_id          = yandex_vpc_subnet.bastion-external-segment.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.addr.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment.id
    ip_address         = "172.16.16.254"
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
  }



  metadata = {
    user-data = "${file("./bastion.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_disk" "boot-disk-web-host-1" {
  name        = "disk-web-host-1"
  description = "диск для веб-сервера 1"
  type        = "network-hdd"
  zone        = var.zone_b
  size        = 10
  image_id    = var.image_id
}

resource "yandex_compute_instance" "web-host-1" {
  name        = "web-host-1"
  description = "веб-сервер 1"
  hostname    = "web-host-1"
  zone        = var.zone_b
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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}


output "external_ip_bastion" {
  value = yandex_vpc_address.addr.external_ipv4_address.0.address
}

output "external_nat_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}