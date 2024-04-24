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
  route_table_id = yandex_vpc_route_table.rt.id
}

# Подсеть "внутренней сети" (internal_bastion_vpc_subnet)
resource "yandex_vpc_subnet" "bastion-internal-segment-1" {
  name           = "bastion-internal-segment-1"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

# Подсеть "внутренней сети" (internal_bastion_vpc_subnet)
resource "yandex_vpc_subnet" "bastion-internal-segment-2" {
  name           = "bastion-internal-segment-2"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.12.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
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

# Группа безопасности бастионного хоста (вход только по ssh, выход любой)
resource "yandex_vpc_security_group" "secure-bastion-sg" {
  name       = "secure-bastion-sg"
  network_id = yandex_vpc_network.network.id
  ingress { #входящий
    protocol       = "TCP"
    port           = var.ssh_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Группа безопасности для внутренних хостов (входящий и исходящий трафик)
resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name       = "internal-bastion-sg"
  network_id = yandex_vpc_network.network.id
  ingress { #входящий
    protocol = "TCP"
    port     = var.ssh_port
    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.11.0/24",
      "192.168.12.0/24"
    ]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
#https://yandex.cloud/ru/docs/vpc/concepts/security-groups
resource "yandex_vpc_security_group" "webserver-sg" {
  name       = "webserver-sg"
  network_id = yandex_vpc_network.network.id
  ingress { #входящий
    protocol = "TCP"
    port     = var.http_port
    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.11.0/24",
      "192.168.12.0/24"
    ]
  }
  ingress { #входящий
    protocol = "TCP"
    port     = 10050
    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.11.0/24",
      "192.168.12.0/24"
    ]
  }

  ingress {
    description       = "Health checks from NLB"
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Zabbix
resource "yandex_vpc_security_group" "zabbix-sg" {
  name       = "zabbix-sg"
  network_id = yandex_vpc_network.network.id
  ingress {
    protocol       = "TCP"
    port           = var.http_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #входящий
    protocol = "TCP"
    port     = 10051
    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.11.0/24",
      "192.168.12.0/24"
    ]
  }
  egress {
    protocol  = "ANY"
    from_port = 0
    to_port   = 65535
    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.11.0/24",
      "192.168.12.0/24"
    ]
  }
}

# Резервирование ip адреса bastion
#https://github.com/yandex-cloud/docs/blob/master/ru/compute/operations/vm-control/vm-attach-public-ip.md
resource "yandex_vpc_address" "addr" {
  name = "Bastion ip address"
  external_ipv4_address {
    zone_id = var.zone_d
  }
}









# target-group
resource "yandex_alb_target_group" "web-hosts-group" {
  name = "web-hosts-group"
  target {
    subnet_id  = yandex_vpc_subnet.bastion-internal-segment-1.id
    ip_address = yandex_compute_instance.web-host-1.network_interface.0.ip_address
  }
  target {
    subnet_id  = yandex_vpc_subnet.bastion-internal-segment-2.id
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
    port             = var.http_port
    target_group_ids = ["${yandex_alb_target_group.web-hosts-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      healthcheck_port    = var.http_port
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
      subnet_id = yandex_vpc_subnet.bastion-internal-segment-1.id
    }
    location {
      zone_id   = var.zone_b
      subnet_id = yandex_vpc_subnet.bastion-internal-segment-2.id
    }
  }
  listener {
    name = "web-hosts-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [var.http_port]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}
