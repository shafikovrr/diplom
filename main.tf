
# Настройка дисков
# диск для vm-1
resource "yandex_compute_disk" "boot-disk-vm-1" {
  name     = "disk-vm-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = 10
  image_id = var.image_id
}

# диск для vm-2
resource "yandex_compute_disk" "boot-disk-vm-2" {
  name     = "disk-vm-2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = var.image_id
}

# Настройка хостов
# host 1
resource "yandex_compute_instance" "vm-1" {
  name        = "vm-1"
  hostname    = "vm-1"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# host 2
resource "yandex_compute_instance" "vm-2" {
  name        = "vm-2"
  hostname    = "vm-2"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# настройка сети в разных зонах и подсетях https://yandex.cloud/ru/docs/vpc/operations/subnet-create
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_network" "network-2" {
  name = "network2"
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-2.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

# Вывод полученных ip (внутренний и внешние)

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
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
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
