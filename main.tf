# Настройка дисков
resource "yandex_compute_disk" "boot-disk-vm-1" {
  name        = "disk-vm-1"
  description = "диск для веб-сервера 1"
  type        = "network-hdd"
  zone        = var.zone_1
  size        = 10
  image_id    = var.image_id
}

resource "yandex_compute_disk" "boot-disk-vm-2" {
  name        = "disk-vm-2"
  description = "диск для веб-сервера 2"
  type        = "network-hdd"
  zone        = var.zone_2
  size        = 10
  image_id    = var.image_id
}

# Настройка хостов
## Веб-сервера
resource "yandex_compute_instance" "vm-1" {
  name        = "vm-1"
  description = "веб-сервер 1"
  hostname    = "vm-1"
  zone        = var.zone_1
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm-1.id
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

resource "yandex_compute_instance" "vm-2" {
  name        = "vm-2"
  description = "веб-сервер 2"
  hostname    = "vm-2"
  zone        = var.zone_2
  platform_id = var.platform
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm-2.id
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

######################################################################################################
# настройка сети в разных зонах и подсетях https://yandex.cloud/ru/docs/vpc/operations/subnet-create #
######################################################################################################
resource "yandex_vpc_network" "network" {
  name = "network"
}
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}
##############################################
# Вывод полученных ip (внутренних и внешних) #
##############################################
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}


#################################################################################################

# target-group https://yandex.cloud/ru/docs/application-load-balancer/operations/target-group-create#tf_1
# посмотреть https://console.yandex.cloud/folders/b1gltt4aeqoofm7e2pnj/application-load-balancer/target-groups

resource "yandex_alb_target_group" "nginx-group" {
  name = "nginx-group"

  target {
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    ip_address = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    ip_address = yandex_compute_instance.vm-2.network_interface.0.ip_address
  }
}



################################################################################################

# https://yandex.cloud/ru/docs/application-load-balancer/operations/backend-group-create
resource "yandex_alb_backend_group" "backend-group" {
  name = "web-hosts"
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name             = "web"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.nginx-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# https://yandex.cloud/ru/docs/application-load-balancer/operations/http-router-create
resource "yandex_alb_http_router" "tf-router" {
  name = "wh-http-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "wh-virtual"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "wh-router"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "60s"
      }
    }
  }
  #  route_options {
  #    security_profile_id = "enprviu6hrlnjohfth0h"
  #  }
}
