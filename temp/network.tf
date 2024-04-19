# vpc

resource "yandex_vpc_network" "network" {
  name = "network"
}

# vpc_subnet

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
/* resource "yandex_vpc_subnet" "subnet-d" {
  name           = "subnet3"
  zone           = var.zone_d
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}
 */
/* # target-group
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

# backend-group
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
      healthcheck_port    = 80
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

# http-router
resource "yandex_alb_http_router" "tf-router" {
  name = "web-hosts-http-router"
}
resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "web-hosts-virtual-host"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "web-hosts-route"
    http_route {
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

# load-balancer
resource "yandex_alb_load_balancer" "web-hosts-balancer" {
  name       = "web-hosts-balancer"
  network_id = yandex_vpc_network.network.id

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
} */