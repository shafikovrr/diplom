#######
# Настройка дисков
resource "yandex_compute_disk" "boot-disk-web-host-1" {
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
}

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

######################################################################################################
# настройка сети в разных зонах и подсетях https://yandex.cloud/ru/docs/vpc/operations/subnet-create #
######################################################################################################
resource "yandex_vpc_network" "network" {
  name = "network"
}
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet1"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet2"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}


#################################################################################################
# target-group https://yandex.cloud/ru/docs/application-load-balancer/operations/target-group-create#tf_1
# посмотреть https://console.yandex.cloud/folders/b1gltt4aeqoofm7e2pnj/application-load-balancer/target-groups
#######################################################################################################
resource "yandex_alb_target_group" "web-hosts-group" {
  name = "web-hosts-group"
  target {
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    ip_address = yandex_compute_instance.web-host-1.network_interface.0.ip_address
  }
  target {
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    ip_address = yandex_compute_instance.web-host-2.network_interface.0.ip_address
  }
}

################################################################################################
# https://yandex.cloud/ru/docs/application-load-balancer/operations/backend-group-create
##################################################################################################
resource "yandex_alb_backend_group" "backend-group" {
  name = "web-hosts-backend-group"
  session_affinity {
    connection {
      source_ip = true
    }
  }
  http_backend {
    name             = "web-hosts-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.web-hosts-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      healthcheck_port    = 80 #https://terraform-provider.yandexcloud.net/Resources/alb_backend_group
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
###################################################################################################
# https://yandex.cloud/ru/docs/application-load-balancer/operations/http-router-create
################################################################################################
resource "yandex_alb_http_router" "tf-router" {
  name = "web-hosts-http-router"
}
resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "web-hosts-virtual-host"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "web-hosts-route"
    http_route { #как настроить /? https://terraform-provider.yandexcloud.net/Resources/alb_virtual_host / по умолчанию если не задано
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "60s"
      }
    }
  }
}

##################################################################################################
#https://yandex.cloud/ru/docs/application-load-balancer/operations/application-load-balancer-create
##################################################################################################
resource "yandex_alb_load_balancer" "web-hosts-balancer" {
  name       = "web-hosts-balancer"
  network_id = yandex_vpc_network.network.id
  #security_group_ids = ["<список_идентификаторов_групп_безопасности>"]

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.subnet-a.id
    }
    location {
      zone_id   = var.zone_b
      subnet_id = yandex_vpc_subnet.subnet-b.id
    }
  }

  listener {
    name = "web-hosts-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }

  #log_options {
  #  log_group_id = "<идентификатор_лог-группы>"
  #  discard_rule {
  #    http_codes          = ["<HTTP-код>"]
  #    http_code_intervals = ["<класс_HTTP-кодов>"]
  #    grpc_codes          = ["<gRPC-код>"]
  #    discard_percent     = <доля_отбрасываемых_логов>
  #  }
  #}
}


#data "yandex_alb_load_balancer" "tf-alb" {
#  load_balancer_id = "<идентификатор_балансировщика>"
#}

#output "tf-alb-listener" {
#  value = data.yandex_alb_load_balancer.tf-alb.allocation_policy
#}

#https://github.com/yandex-cloud-examples/yc-website-high-availability-with-alb/blob/main/application-load-balancer-website.tf
